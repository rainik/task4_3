#!/bin/bash

# This script should receive two arguments: backup_dir and amount of backups.
# If one of the arguments is missing or second argument is not a number
# the script interrupts.
# Author: Serhii  itrainik@gmail.com
# script launch parameters: ./backup.sh [/path/to/backup/folder] [number of backups]

###
# checks if we have passed all arguments
###
# more than 2 parameters
if [ $# -gt 2 ]; then echo -e "More than 2 arguments supplied\nscript launch parameters: ./backup.sh [/path/to/backup/folder] [number of backups]" 1>&2 & exit 1; fi
# empty parameters
if [ -z $(echo '$1' | sed 's/^[ \t]*//') ] || [ -z $(echo $2 | sed 's/^[ \t]*//') ]; then echo -e "At least one of the arguments is empty\nscript launch parameters: ./backup.sh [/path/to/backup/folder] [number of backups]" 1>&2 & exit 1; fi
# existance of backup folder
if [ ! -d "$1" ]; then echo -e "Backup folder doesn't exist" 1>&2 && exit 1; fi
# if amount of backups is a number
if [[ $2 != ?(-)+([0-9]) ]]; then echo -e "Second argument is not a number\nscript launch parameters: ./backup.sh [/path/to/backup/folder] [number of backups]" 1>&2 & exit 1; fi

#if [ $# -gt 2 ]
#  then
#    echo -e "More than 2 arguments supplied\nscript launch parameters: ./backup.sh [/path/to/backup/folder] [number of backups]" 1>&2
#    exit 1
#  else#
#    if [ -z $(echo $1 | sed 's/^[ \t]*//') ] || [ -z $(echo $2 | sed 's/^[ \t]*//') ]; then
#	echo -e "At least one of the arguments is empty\nscript launch parameters: ./backup.sh [/path/to/backup/folder] [number of backups]" 1>&2
#	exit 1
#     else
#	[[ $2 != ?(-)+([0-9]) ]] && echo -e "Second argument is not a number\nscript launch parameters: ./backup.sh [/path/to/backup/folder] [number of backups]" 1>&2 && exit 1
#    fi
#fi

###
# Print backuped directory and stored backup numbers
###
echo -e "\nBackup directory is = $1\n"
echo -e "Amount of rotating archives = $2\n"

###
# Set backup dir (may be changed to the third argument)
###
BACKUP_DIR="/tmp/backup"

###
# this sction creates backup directory and if it is file, script removes file and creates directory
###
if [ -f "$BACKUP_DIR" ]
  then
    echo -e "ERROR: directory ${BACKUP_DIR} is a file\nso we will delete it and create directory instead\n" 1>&2
    rm -f $BACKUP_DIR && mkdir -p $BACKUP_DIR
    echo -e "Directory $BACKUP_DIR was created\n"
  else
    if [ -d $BACKUP_DIR ]
    then
        echo -e "Backup directory $BACKUP_DIR exists\n"
    else
        mkdir -p $BACKUP_DIR
        echo -e "Directory $BACKUP_DIR was created\n"
    fi
fi

# appendix to backup file
date_daily=`date +%Y-%m-%d.%H:%M:%S`

# modify backup name according to task
backup_name=$(echo "$1" | sed 's/\//-/g;s/^[-]//;s/[-]*$//')

echo -e "Creating backup $BACKUP_DIR/$backup_name-$date_daily.tar.gz\n"
# create archive
tar -cvzf "$BACKUP_DIR/$backup_name-$date_daily.tar.gz" "$1" > /dev/null 2>&1
# remove older archives
find $BACKUP_DIR -name "$backup_name*" -type f | sort -r | sed "1,$2d" | sed 's/ /\\ /g' | xargs rm -rf
