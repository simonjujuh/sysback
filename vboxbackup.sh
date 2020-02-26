#!/bin/bash
# name: vboxbackup.sh
# author: novam
# description: TODO

# check if no parameters are set
if [ $# -eq 0 ]; then
  echo "Usage: $(basename $0) <backup dir> [vm_name...]"
  echo ""
  echo "Get vms list: vboxmanage list vms"
  exit 1 
fi

# checking if backup dir is set and is a directory
if [ ! -d "$1" ]; then
  echo "Error: '$1': Not a directory"
  exit 1
fi

# script variables
vbox_dir="${1%/}/backups/vboxvms/" && shift
vbox_full_list="$(vboxmanage list vms | awk  '{gsub("\"", "", $1); print $1 }' | tr '\n' ' ')"

# check if any vm are specified for the backup
if [ -z "$1" ]; then
  vbox_list="${vbox_full_list}"
else 
  # sort uniq the vbox list send via command arguments
  vbox_uniq=$(echo "${@}" | tr ' ' '\n' | sort -u | tr '\n' ' ')
  for vbox in ${vbox_uniq}; do
    # add only existing vbox to vbox_list
    if echo "${vbox_full_list}" | grep -qw "${vbox}" 2>/dev/null; then
      vbox_list="${vbox_list} ${vbox}"
    fi
    # trim leading and trailing whitespaces
    vbox_list="$(echo "${vbox_list}" | awk '{$1=$1};1')"
  done
fi

echo -n "[*] Virtualbox vms to backup: " 
echo ${vbox_list} | sed 's/ /, /g' 

# prompt for confirmation
read -p "Do you want to continue? " yn
case $yn in
  [Yy]* ) echo;;
  [Nn]* ) exit;;
  * ) echo "Invalid choice"; exit 2;;
esac

date=$(date "+%Y%m%d-%H%M%S")
backup_dir="${vbox_dir}${date}/"

[ -d "${backup_dir}" ] || mkdir -p "${backup_dir}"

echo "[*] Started the virtual machines backup process (dst: ${vbox_dir})"

for vbox in ${vbox_list}; do
  echo "[*] Exporting ${vbox} to ${backup_dir}"
  vboxmanage export ${vbox} -o ${backup_dir}${vbox}.ova 
done

echo "[*] Done"
