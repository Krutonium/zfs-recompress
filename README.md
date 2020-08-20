# zfs-recompress.sh

## NAME

*zfs-recompress.sh* - trigger ZFS compression on a set of files

## SYNOPSIS

	zfs-recompress.sh [OPTION1], [OPTION2], ...

## DESCRIPTION

Call the *zfs-recompress.sh* script to replicate, verify and overwrite all files in the current working directory and all its descendant directories in order to trigger ZFS compression.

	-f, --folder FOLDER
		process the specified FOLDER instead of the current working directory

	-d, --dry-run
		test every source file for readability/size and try to create an empty file in every destination directory (fast) instead of a full replicate, verify and overwrite cycle (slow)

	--compat001
		compatibility option; use `df` instead of `stat` to determine disk space available

	-h, --help
		display usage help and exit

Examples:

- running `zfs-recompress.sh` in the `/mnt/files/foo/` directory will process all files in `/mnt/files/foo/`, `/mnt/files/foo/bar/`, `/mnt/files/foo/bar/baz/` and so on, but will not process files in `/mnt/files/`

- running `zfs-recompress.sh --folder /mnt/files/` in the `/mnt/files/foo/` directory will process all files in `/mnt/files/`, `/mnt/files/foo/`, `/mnt/files/foo/bar/`, `/mnt/files/foo/bar/baz/` and so on

## LIMITATIONS

Files that are hard-linked (as well as all their hard links) are skipped. You must process those files manually. In order to [find all files with one or more hard links](http://superuser.com/questions/485919/how-can-i-find-all-hardlinked-files-on-a-filesystem), try: `find . -type f -links +1 -printf '%i %n %p\n'`.

## REPORTING BUGS

Please report *zfs-recompress.sh* bugs through [GitHub](https://github.com/gary17/zfs-recompress).

## WARNING

**ALWAYS MAKE A BACKUP BEFORE BATCH-PROCESSING COMPUTER FILES IN ANY WAY.**

## COPYRIGHT

This is free software: you are free to change and redistribute it. There is NO WARRANTY, to the extent permitted by law.

## SEE ALSO

Further information is available through comments within the *zfs-recompress.sh* script itself, readable with any text editor.