# zfs-recompress.sh

## NAME
*zfs-recompress.sh* - trigger ZFS compression on a set of files

## SYNOPSIS
	zfs-recompress.sh [OPTION1], [OPTION2], ...

## DESCRIPTION
Call the *zfs-recompress.sh* script to replicate, verify and overwrite all files in the current working directory and all its descendant directories in order to trigger ZFS compression.

	--folder FOLDER
		process the specified FOLDER instead of the current working directory

	--dry-run
		test every source file for readability/size and try to create an empty file in every destination directory (fast) instead of a full replicate, verify and overwrite cycle (slow)

	--help
		display usage help and exit
	   
## REPORTING BUGS
Please report *zfs-recompress.sh* bugs through [GitHub](https://github.com/gary17/zfs-recompress).

## COPYRIGHT
This is free software: you are free to change and redistribute it. There is NO WARRANTY, to the extent permitted by law.

**ALWAYS MAKE A BACKUP BEFORE BATCH-PROCESSING COMPUTER FILES IN ANY WAY.**

## SEE ALSO
Further information is available through comments within the *zfs-recompress.sh* script itself, readable with any text editor.
