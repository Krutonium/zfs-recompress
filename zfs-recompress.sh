#!/bin/bash

##### Constants

#

##### Functions

clear_line()
{
	# clear the entire line
	echo -ne "\\033[2K"; printf "\\r"
}

usage()
{
	echo "usage: $(basename "$0") [[[-f, --folder FOLDER ] [-d, --dry-run]] | [-h, --help]]"
}

##### Main

unset folder dry_run

while [ "$1" != "" ]; do
	case $1 in
		-f | --folder)			shift
								folder=$1
								;;
		-d | --dry-run)			dry_run=1
								;;
		-h | --help)			usage
								exit
								;;
		*)						usage
								exit 1
	esac
	shift
done

if [ -z "$folder" ]; then # intentionally: unset or empty
	folder="$(pwd)"
fi

# WARNING: processes regular files only, see "LIMITATIONS" in the "README.md" document
printf "searching..."

unset files i

while IFS= read -r -d '' file # SC2044: while vs. for
do
	files[i++]="$file"
done <	<(find "$folder" -type f -links 1 -print0) # process substitution

#

for ((i=0,count_of_files=${#files[@]}; i<count_of_files; i++)) # SC2004: $/${} is unnecessary on arithmetic variables
do
	file=${files[$i]}

	#

	if [ ! -f "$file" ]; then
		continue # a previously enumerated file might have been deleted in the meantime
	fi

	if [ ! -r "$file" ]; then
		echo "'$file' is not readable" 1>&2 # otherwise, "cp: cannot open '...' for reading: Permission denied"
		exit 110
	fi

	# WARNING: create the replica in the same directory as the source, in order to to avoid free space race conditions (deleted the source, but suddenly can't copy the replica back in)

	file_size=$(stat -c%s "$file")

	file_dir=$(dirname "$file")
	dir_free=$(($(stat -f --format="%a*%S" "$file_dir"))) # arithmetic expansion, free blocks times fundamental block size, e.g., "188363*131072"

	if [ "$file_size" -gt "$dir_free" ]; then
		file_size_fmt=$(numfmt --to=iec "$file_size")
		dir_free_fmt=$(numfmt --to=iec "$dir_free")

		echo "'$file' too large to replicate ($file_size_fmt, $dir_free_fmt free)"
		exit 120
	fi

	#

	if [ $(((i+1) % 10)) -eq 0 ] || [ "$file_size" -gt $((25*1024*1024)) ]; then # show progress on every n-th (performance) or anything larger than x-MB (responsiveness)
		file_size_fmt=$(numfmt --to=iec "$file_size")
	
		clear_line
		printf "processing %d of $count_of_files (%d%%): '%s' ($file_size_fmt)" "$((i+1))" "$(((i+1)*100/count_of_files))" "$(basename "$file")"
	fi

	# TO-DO: possibly detect whether already compressed (with the same ZFS compression algorithm) and skip

	repl="$file.$(uuidgen).tmp" # "file.tmp" might already exist, use a unique identifier (with a searchable extension)

	# replicate

	finalize()
	{
		rm --force "$repl" # might not even exist

		echo
		exit 200
	}

	trap finalize SIGHUP SIGINT SIGTERM # trap Ctrl-C

	if [ ! -z "$dry_run" ]; then
		touch "$repl"

		if [ ! -f "$repl" ]; then
			echo "'$repl' empty replica could not be created" 1>&2 # some kind of special character in the name of the file?
			exit 170
		fi
	else
		cp --preserve=all "$file" "$repl" # preserve all attributes
		rc=$? # (assuming) 0 for success, an error otherwise

		if [ $rc -ne 0 ]; then
			rm --force "$repl" # might not even exist

			echo "'$file' replica creation failed, could not copy" 1>&2
			exit 130
		fi

		if [ ! -f "$repl" ]; then
			echo "'$repl' replica could not be created" 1>&2 # some kind of special character in the name of the file?
			exit 140
		fi

		# verify

		cmp --silent "$file" "$repl"
		rc=$? # 0 if (...) same, 1 if different, 2 if trouble

		if [ $rc -ne 0 ]; then
			rm --force "$repl" # might not even exist

			echo "'$file' replica verification failed, different from the original" 1>&2
			exit 150
		fi
	fi

	# run riot...

	if [ ! -z "$dry_run" ]; then
		rm --force "$repl" # might not even exist
	else
		# prepare
		sync "$repl"

		# WARNING: after the removal of the source, the replica is the only surviving copy - never clean it up
		trap '' SIGHUP SIGINT SIGTERM # disable Ctrl-C

		rm --force "$file" # do not give ZFS a chance to somehow optimize the two operations away as a noop
		mv --force "$repl" "$file"

		if [ ! -f "$file" ]; then
			echo "'$repl' replica could not be renamed back as '$file', MUST RESOLVE MANUALLY" 1>&2
			exit 160
		fi

		# commit
		sync "$file"
	fi

	trap - SIGHUP SIGINT SIGTERM # un-trap Ctrl-C

	# ... (Def Leppard, 1987)

	# TO-DO: possibly undo containing folder timestamp change to avoid throwing tools like rsync into confusion

	if [ $((i+1)) -eq $count_of_files ]; then
		clear_line
		echo "processed $((i+1)) files. done."
	fi

	#

done
