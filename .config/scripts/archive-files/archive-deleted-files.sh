#!/usr/bin/bash

TRASH_DIR=/home/$USER/.local/share/Trash/files
ARCHIVE_DIR=/home/$USER/.local/share/Trash/archive
LOG_FILE=$TRASH_DIR/../archive.log

FILES_LIST=/tmp/trash_files.txt
EXCLUDED_LIST=/tmp/excluded_files.txt
FILES_TO_APPEND_LIST=/tmp/files_to_append_list.txt

ARCHIVE_TAR_GZ=$ARCHIVE_DIR/trash-$(date +%Y-%m).tar.gz
ARCHIVE_TAR=$ARCHIVE_DIR/trash-$(date +%Y-%m).tar

remove_file_if_exists() {
  if [ -f $1 ]; then
    rm $1
  fi
}

archive_files() {
  find $TRASH_DIR -maxdepth 1 -ctime +30 >$FILES_LIST
  cat $FILES_LIST >>$LOG_FILE
  if [ ! -f $ARCHIVE_TAR_GZ ]; then
    tar -czvf $ARCHIVE_TAR_GZ -T $FILES_LIST
  else
    echo "Archive already exists, appending files to it" >>$LOG_FILE
    gunzip $ARCHIVE_TAR_GZ
    echo "gunzip done:? "$? >>$LOG_FILE

    excluded_files=$(tar -tf $ARCHIVE_TAR | sort | uniq)
    echo "$excluded_files" >$EXCLUDED_LIST

    write_uniq_files_list
    echo "files_to_append_list" >>$LOG_FILE
    cat $FILES_TO_APPEND_LIST >>$LOG_FILE

    tar -rf $ARCHIVE_TAR -T $FILES_TO_APPEND_LIST
    echo "tar done:? "$? >>$LOG_FILE

    gzip $ARCHIVE_TAR
    echo "gzip done:? "$? >>$LOG_FILE
  fi
}

write_uniq_files_list() {
  if [ ! -f $FILES_TO_APPEND_LIST ]; then
    touch $FILES_TO_APPEND_LIST
  fi
  while IFS= read -r file_to_archive; do
    file_exists=0
    while IFS= read -r excluded_file; do
      excluded_file="/${excluded_file#/}" # adding leading / to the file path
      if [ "$excluded_file" = "$file_to_archive" ]; then
        file_exists=1
        break
      fi
    done <$EXCLUDED_LIST

    if [ $file_exists -eq 0 ]; then
      echo "file to archive: "$file_to_archive >>$LOG_FILE
      echo "$file_to_archive" >>$FILES_TO_APPEND_LIST
    fi
  done <$FILES_LIST
}

cleanup() {
  # check if the archive was created successfully and remove files older than 30 days
  result=$?
  if [ $result -eq 0 ]; then
    while IFS= read file_to_delete; do
      if [ -f "$file_to_delete" ]; then
        echo "Deleting file: "$file_to_delete >>$LOG_FILE
        rm "$file_to_delete"
        echo "  Deleted file?: "$? >>$LOG_FILE
      else
        if [ -d "$file_to_delete" ]; then
          echo "Deleting directory: "$file_to_delete >>$LOG_FILE
          rm -r "$file_to_delete"
          echo "  Deleted directory?: "$? >>$LOG_FILE
        fi
      fi
    done <$FILES_LIST
  else
    echo "Archive creation failed" >>$LOG_FILE
  fi
  rm $FILES_LIST
  rm $EXCLUDED_LIST
  rm $FILES_TO_APPEND_LIST
  echo "["$(date)"] Archiving deleted files completed."
}

echo "
["$(date)"] Archiving deleted files..." >>$LOG_FILE

# Check if the archive directory exists
if [ ! -d $ARCHIVE_DIR ]; then
  mkdir -p $ARCHIVE_DIR
fi

# we need to remove all archives that is older than 12 months
find $ARCHIVE_DIR -type f -name "trash-*.tar.gz" -mtime +365 -exec rm {} \;

# remove the files list if it exists
remove_file_if_exists $FILES_LIST
remove_file_if_exists $EXCLUDED_LIST
remove_file_if_exists $FILES_TO_APPEND_LIST

cd $TRASH_DIR/..

# we need to archive all files that is older than 30 days. To do so lets define a function
archive_files
cleanup

