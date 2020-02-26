# Sysback

Utilities to backup personal folders and files

## Description

This repository contains a set of tools performing

* Incremental backups
* VirtualBox VMs exports and backups

## Snapshot

To do a system snapshot (i.e. incremental backup), use the tool `snapshot.sh`.

Before running, edit the paths you want to include and the ones you want to exclude from your backup.

```
# directories to backup
src[0]="/opt"
src[1]="/var/log"
...

# directories to exclude from snapshot
exclude[0]="/home/USER/.cache"
```

By default, snapshots are saved in `<backup_dir>/backups/snapshots/`. The backup directory is specified on the command line, for example:

```
sudo ./snapshots.sh /mnt/disk
```

## VirtualBox backup

Coming soon...
