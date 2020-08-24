#!/bin/bash

# WARNING: /bin/bash (Linux) vs. /usr/local/bin/bash (FreeBSD)

##### Constants

#

##### Functions

# FYI: use a full path to every built-in executable (e.g., "/bin/echo" vs. "echo") to
# have a high chance of using an OS built-in, as opposed to an alias or a replacement

clear_line()
{
	if [ $# -ne 0 ]; then
		/bin/echo "internal script error at line ${LINENO}, function: '${FUNCNAME}', args: '$@'" 1>&2
		exit 190
	fi

	# clear the entire line

	# -n do not output the trailing newline
	# -e enable interpretation of backslash escapes
	/bin/echo -ne "\\033[2K"; /usr/bin/printf "\\r"
}

get_file_size()
{
	if [ $# -ne 1 ]; then
		/bin/echo "internal script error at line ${LINENO}, function: '${FUNCNAME}', args: '$@'" 1>&2
		exit 190
	fi

	# %s total size, in bytes
	/usr/bin/stat --format="%s" "$1"
}

get_file_size_bsd()
{
	if [ $# -ne 1 ]; then
		/bin/echo "internal script error at line ${LINENO}, function: '${FUNCNAME}', args: '$@'" 1>&2
		exit 190
	fi

	# The size of file in bytes (st_size).
	/usr/bin/stat -f "%z" "$1"
}

get_dir_free()
{
	if [ $# -ne 1 ]; then
		/bin/echo "internal script error at line ${LINENO}, function: '${FUNCNAME}', args: '$@'" 1>&2
		exit 190
	fi

	# -f display file system status instead of file status
	# %a free blocks available to non-superuser
	# %S fundamental block size (for block counts)	
	local formula=$(stat --file-system --format="%a*%S" "$1")
	/bin/echo $(($formula)) # arithmetic expansion, free blocks times fundamental block size, e.g., "188363*131072"
}

get_dir_free_compat001() # unused, FYI
{	
	if [ $# -ne 1 ]; then
		/bin/echo "internal script error at line ${LINENO}, function: '${FUNCNAME}', args: '$@'" 1>&2
		exit 190
	fi

	# --output[=FIELD_LIST] use the output format defined by FIELD_LIST
	# -B scale sizes by SIZE before printing them
	/bin/df --output=avail --block-size=1 "$1" | /usr/bin/tail --lines=1
}

get_dir_free_bsd()
{
	if [ $# -ne 1 ]; then
		/bin/echo "internal script error at line ${LINENO}, function: '${FUNCNAME}', args: '$@'" 1>&2
		exit 190
	fi

	# -b Explicitly use 512-byte blocks
	# TODO: check sanity, i.e. the "Avail" column ordinal
	local blocks=$(/bin/df -b "$1" | /usr/bin/cut -w -f 4 | /usr/bin/tail -n 1)
	/bin/echo $(($blocks*512))
}

format_h()
{
	if [ $# -ne 1 ]; then
		/bin/echo "internal script error at line ${LINENO}, function: '${FUNCNAME}', args: '$@'" 1>&2
		exit 190
	fi

	# --to=UNIT auto-scale output numbers to UNITs; see UNIT below
	# iec accept optional single letter suffix
	/usr/bin/numfmt --to=iec "$1"
}

format_h_bsd()
{
	if [ $# -ne 1 ]; then
		/bin/echo "internal script error at line ${LINENO}, function: '${FUNCNAME}', args: '$@'" 1>&2
		exit 190
	fi

	if [ "$1" -gt $((1024 * 1024 * 1024)) ]; then
		local num=$(/bin/echo "scale=1; $1 / (1024 * 1024 * 1024)" | /usr/bin/bc)
		/bin/echo "${num}G"
	elif [ "$1" -gt $((1024 * 1024)) ]; then
		local num=$(/bin/echo "scale=1; $1 / (1024 * 1024)" | /usr/bin/bc)
		/bin/echo "${num}M"
	elif [ "$1" -gt 1024 ]; then
		local num=$(/bin/echo "scale=1; $1 / 1024" | /usr/bin/bc)
		/bin/echo "${num}K"
	else
		/bin/echo "${1}"
	fi
}

gen_uuid()
{
	if [ $# -ne 0 ]; then
		/bin/echo "internal script error at line ${LINENO}, function: '${FUNCNAME}', args: '$@'" 1>&2
		exit 190
	fi

	/usr/bin/uuidgen
}

gen_uuid_bsd()
{
	if [ $# -ne 0 ]; then
		/bin/echo "internal script error at line ${LINENO}, function: '${FUNCNAME}', args: '$@'" 1>&2
		exit 190
	fi

	/bin/uuidgen
}

force_rm()
{
	if [ $# -ne 1 ]; then
		/bin/echo "internal script error at line ${LINENO}, function: '${FUNCNAME}', args: '$@'" 1>&2
		exit 190
	fi

	/bin/rm --force "$1"
}

force_rm_bsd()
{
	if [ $# -ne 1 ]; then
		/bin/echo "internal script error at line ${LINENO}, function: '${FUNCNAME}', args: '$@'" 1>&2
		exit 190
	fi

	/bin/rm -f "$1"
}

cp_preserved()
{
	if [ $# -ne 2 ]; then
		/bin/echo "internal script error at line ${LINENO}, function: '${FUNCNAME}', args: '$@'" 1>&2
		exit 190
	fi

	/bin/cp --preserve=all "$1" "$2" # preserve all attributes
}

cp_preserved_bsd()
{
	if [ $# -ne 2 ]; then
		/bin/echo "internal script error at line ${LINENO}, function: '${FUNCNAME}', args: '$@'" 1>&2
		exit 190
	fi

	/bin/cp -p "$1" "$2" # preserve all attributes
}

silent_cmp()
{
	if [ $# -ne 2 ]; then
		/bin/echo "internal script error at line ${LINENO}, function: '${FUNCNAME}', args: '$@'" 1>&2
		exit 190
	fi

	/usr/bin/cmp --silent "$1" "$2"
}

silent_cmp_bsd()
{
	if [ $# -ne 2 ]; then
		/bin/echo "internal script error at line ${LINENO}, function: '${FUNCNAME}', args: '$@'" 1>&2
		exit 190
	fi

	/usr/bin/cmp -s "$1" "$2"
}

force_mv()
{
	if [ $# -ne 2 ]; then
		/bin/echo "internal script error at line ${LINENO}, function: '${FUNCNAME}', args: '$@'" 1>&2
		exit 190
	fi

	/bin/mv --force "$1" "$2"
}

force_mv_bsd()
{
	if [ $# -ne 2 ]; then
		/bin/echo "internal script error at line ${LINENO}, function: '${FUNCNAME}', args: '$@'" 1>&2
		exit 190
	fi

	/bin/mv -f "$1" "$2"
}

usage()
{
	if [ $# -ne 0 ]; then
		/bin/echo "internal script error at line ${LINENO}, function: '${FUNCNAME}', args: '$@'" 1>&2
		exit 190
	fi

	/bin/echo "usage: $(/usr/bin/basename "$0") [[[-f, --folder FOLDER ] [-d, --dry-run] ] | [-h, --help]]"
}

##### Main

#
# args

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

#
# platformize

platform=$(uname) # WARNING: /bin/uname (Linux) vs. /usr/bin/uname (FreeBSD)

if [ "$platform" = "Linux" ]; then # avoid "eval" function redeclare
	FN_GET_FILE_SIZE=get_file_size
	FN_GET_DIR_FREE=get_dir_free
	FN_FORMAT_H=format_h
	FN_GEN_UUID=gen_uuid
	FN_FORCE_RM=force_rm
	FN_CP_PRESERVED=cp_preserved
	FN_SILENT_CMP=silent_cmp
	FN_FORCE_MV=force_mv
elif [ "$platform" = "FreeBSD" ] || [ "$platform" = "FreeNAS" ]; then
	FN_GET_FILE_SIZE=get_file_size_bsd
	FN_GET_DIR_FREE=get_dir_free_bsd
	FN_FORMAT_H=format_h_bsd
	FN_GEN_UUID=gen_uuid_bsd
	FN_FORCE_RM=force_rm_bsd
	FN_CP_PRESERVED=cp_preserved_bsd
	FN_SILENT_CMP=silent_cmp_bsd
	FN_FORCE_MV=force_mv_bsd
else
	/bin/echo "unsupported platform '$platform'" 1>&2
	exit 180
fi

#
# setup the root processing folder

if [ -z "$folder" ]; then # intentionally: unset or empty
	folder="$(pwd)"
fi

#
# search

# WARNING: processes regular files only, see "LIMITATIONS" in the "README.md" document
/usr/bin/printf "searching..."

unset files i

while IFS= read -r -d '' file # SC2044: while vs. for
do
	files[i++]="$file"
done <	<(/usr/bin/find "$folder" -type f -links 1 -print0) # process substitution

#
# process

for ((i=0,count_of_files=${#files[@]}; i<count_of_files; i++)) # SC2004: $/${} is unnecessary on arithmetic variables
do
	file=${files[$i]}

	#

	if [ ! -f "$file" ]; then
		continue # a previously enumerated file might have been deleted in the meantime
	fi

	if [ ! -r "$file" ]; then
		/bin/echo "'$file' is not readable" 1>&2 # otherwise, "cp: cannot open '...' for reading: Permission denied"
		exit 110
	fi

	# WARNING: create the replica in the same directory as the source, in order to to avoid free space race conditions (deleted the source, but suddenly can't copy the replica back in)
	
	file_dir=$(/usr/bin/dirname "$file")
	dir_free=$($FN_GET_DIR_FREE "$file_dir")

	#
	
	file_size=$($FN_GET_FILE_SIZE "$file")

	if [ "$file_size" -gt "$dir_free" ]; then
		file_size_fmt=$($FN_FORMAT_H "$file_size")
		dir_free_fmt=$($FN_FORMAT_H "$dir_free")

		/bin/echo "'$file' too large to replicate ($file_size_fmt, $dir_free_fmt free)"
		exit 120
	fi

	#

	if [ $(((i+1) % 10)) -eq 0 ] || [ "$file_size" -gt $((25*1024*1024)) ]; then # show progress on every n-th (performance) or anything larger than x-MB (responsiveness)
		file_size_fmt=$($FN_FORMAT_H "$file_size")
	
		clear_line
		/usr/bin/printf "processing %d of $count_of_files (%d%%): '%s' ($file_size_fmt)" "$((i+1))" "$(((i+1)*100/count_of_files))" "$(/usr/bin/basename "$file")"
	fi

	# TO-DO: possibly detect whether already compressed (with the same ZFS compression algorithm) and skip

	repl="$file.$($FN_GEN_UUID).tmp" # "file.tmp" might already exist, use a unique identifier (with a searchable extension)

	# replicate

	finalize()
	{
		$FN_FORCE_RM "$repl" # might not even exist

		/bin/echo
		exit 200
	}

	trap finalize SIGHUP SIGINT SIGTERM # trap Ctrl-C

	if [ ! -z "$dry_run" ]; then
		/usr/bin/touch "$repl"

		if [ ! -f "$repl" ]; then
			/bin/echo "'$repl' empty replica could not be created" 1>&2 # some kind of special character in the name of the file?
			exit 170
		fi
	else
		$FN_CP_PRESERVED "$file" "$repl" # preserve all attributes
		rc=$? # (assuming) 0 for success, an error otherwise

		if [ $rc -ne 0 ]; then
			$FN_FORCE_RM "$repl" # might not even exist

			/bin/echo "'$file' replica creation failed, could not copy" 1>&2
			exit 130
		fi

		if [ ! -f "$repl" ]; then
			/bin/echo "'$repl' replica could not be created" 1>&2 # some kind of special character in the name of the file?
			exit 140
		fi

		# verify

		$FN_SILENT_CMP "$file" "$repl"
		rc=$? # 0 if (...) same, 1 if different, 2 if trouble

		if [ $rc -ne 0 ]; then
			$FN_FORCE_RM "$repl" # might not even exist

			/bin/echo "'$file' replica verification failed, different from the original" 1>&2
			exit 150
		fi
	fi

	# run riot...

	if [ ! -z "$dry_run" ]; then
		$FN_FORCE_RM "$repl" # might not even exist
	else
		# prepare
		/bin/sync "$repl"

		# WARNING: after the removal of the source, the replica is the only surviving copy - never clean it up
		trap '' SIGHUP SIGINT SIGTERM # disable Ctrl-C

		$FN_FORCE_RM "$file" # do not give ZFS a chance to somehow optimize the two operations away as a noop		
		$FN_FORCE_MV "$repl" "$file"

		if [ ! -f "$file" ]; then
			/bin/echo "'$repl' replica could not be renamed back as '$file', MUST RESOLVE MANUALLY" 1>&2
			exit 160
		fi

		# commit
		/bin/sync "$file"
	fi

	trap - SIGHUP SIGINT SIGTERM # un-trap Ctrl-C

	# ... (Def Leppard, 1987)

	# TO-DO: possibly undo containing folder timestamp change to avoid throwing tools like rsync into confusion

	if [ $((i+1)) -eq $count_of_files ]; then
		clear_line
		/bin/echo "processed $((i+1)) files. done."
	fi

	#

done
