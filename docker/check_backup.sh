#!/bin/bash

# Get yesterday's date in YYYYMMDD format
APP="__APPVAR__"
HOSTDIR="/host"

if [ "$APP" == "bitbucket" ]; then
    DATEYESTERDAY=$(date -ud "yesterday" +%Y%m%d)
    BACKUPFILEPATH="${HOSTDIR}/opt/backup/${APP}-backups/*${DATEYESTERDAY}*.tar.gz"
elif [ "$APP" == "bamboo" ]; then
    DATEYESTERDAY=$(date -ud "yesterday" +%Y%m%d)
    BACKUPFILEPATH="${HOSTDIR}/opt/backup/${APP}-backups/*${DATEYESTERDAY}*.tar.gz"
elif [ "$APP" == "jira" ]; then
    DATEYESTERDAY=$(date -ud "yesterday" +%Y-%m-%d)
    BACKUPFILEPATH="${HOSTDIR}/opt/backup/${APP}-backups/*${DATEYESTERDAY}*.tar.gz"
elif [ "$APP" == "confluence" ]; then
    DATEYESTERDAY=$(date -ud "yesterday" +%Y%m%d)
    BACKUPFILEPATH="${HOSTDIR}/opt/backup/${APP}-backups/*${DATEYESTERDAY}*.tar.gz"
else
    echo "Backup APP variable value not set properly: $APP"
    exit 1
fi


# Check if any .tar.gz files from yesterday exist in /opt/backup/
if ls ${BACKUPFILEPATH} 1> /dev/null 2>&1; then
  exit 0
else
  echo "Backup file from yesterday does not exist"
  exit 1
fi
