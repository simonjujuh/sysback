#!/bin/bash
# name: snapshot.sh
# author: novam
# description: simple snapshot backup script based one
# https://wiki.archlinux.org/index.php/Rsync#Snapshot_backup

# directories to backup
src[0]="/opt"
src[1]="/var/log"
src[2]="/etc"
src[3]="/home/simon"
src[4]="/root"
# src[5]="/var/www"

# directories to exclude from snapshot
exclude[0]="/home/simon/.cache"
exclude[1]="/home/simon/VirtualBox VMs"

# check if no parameters are set
if [ $# -eq 0 ]; then
  echo "Usage: $(basename $0) <backup dir>"
  exit 1
fi

# check if root is running the script
if [ "$EUID" -ne 0 ]; then 
  echo "Error: This script requires root privileges"
  exit 1
fi

# checking if backup dir is set and is a directory
if [ ! -d "$1" ]; then
  echo "Error: '$1': Not a directory"
  exit 1
fi

# script variables
snap_dir="${1%/}/backups/snapshots/"
snap_last="${1%/}/backups/snapshots/last"
date=$(date "+%Y%m%d-%H%M%S")
lnk="--link-dest=${1%/}/backups/snapshots/last/"
excopt="--exclude-from=.rsyncignore"
opts="-q -avz --relative"

[ -d "${snap_dir}" ] || mkdir -p "${snap_dir}"

# building exclusion option list
echo > .rsyncignore
for exc in "${exclude[@]}"; do
  echo "${exc}" >> .rsyncignore
done

echo "[*] Started the system snapshot process (dst: ${snap_dir}${date})"
for s in "${src[@]}"; do
  echo "[*] Running rsync on '${s}' directory"
  rsync ${opts} ${excopt} ${lnk} ${s} "${snap_dir}${date}"
done

# rsync part
# rsync ${opts} ${lnk} ${src} "${dst}${date}"
echo "[*] Update the last snapshot link"
rm -f "${snap_last}"
ln -s "${snap_dir}${date}" "${snap_last}"

rm .rsyncignore
echo "[*] Done"
