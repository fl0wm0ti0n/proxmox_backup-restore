#!/bin/bash

# setze Variablen
# Datum
_now=$(date +%Y-%m-%d.%H.%M.%S)
# Backup Verzeichnis
_bdir="/mnt/Proxmox-Backup-Destination"
# Tar Dateiname
_tarfilename="$_bdir/proxmox-minimalbackup_$_now.tar"
#rsync Verzeichnisname
_rsyncdirname="$_bdir/proxmox-minimalbackup_synced"
# max Aufbewahrung
_maxdays="+30"

# rsync
echo "Starte rsync von /etc nach $_rsyncdirname ..." >> "$_bdir/proxmox_backup_log_$_now.log"
sudo rsync -aAXvlL --safe-links --delete --exclude="lost+found" --exclude=".ecryptfs" /etc/pve /etc/network/interfaces /etc/vzdump.conf /etc/resolv.conf /etc/hosts /etc/hostname /etc/passwd /etc/fstab /etc/cifspasswd /etc/cifspasswd-flomv $_rsyncdirname
if [ $? -ne 0 ]; then
    echo "rsync gescheitert" >> "$_bdir/proxmox_backup_log_$_now.log"
    exit
else
    echo "rsync erfolgreich beendet" >> "$_bdir/proxmox_backup_log_$_now.log"
fi

# tar
echo "Archiviere $_rsyncdirname nach $_tarfilename ..." >> "$_bdir/proxmox_backup_log_$_now.log"
sudo tar -cvf $_tarfilename -C $_rsyncdirname/ .
if [ $? -ne 0 ]; then
    echo "Archivieren gescheitert" >> "$_bdir/proxmox_backup_log_$_now.log"
    exit
else
    echo "Archivieren erfolgreich beendet" >> "$_bdir/proxmox_backup_log_$_now.log"
fi


# entfern/en alter Dateien
echo "Suche Dateien weche älter sind als $_maxdays und entferne diese" >> "$_bdir/proxmox_backup_log_$_now.log"
sudo find "$_bdir" -name "*.tar" -type f -mtime $_maxdays -exec rm -f {} \;
if [ $? -ne 0 ]; then
    echo "Keine alten Archive gefunden" >> "$_bdir/proxmox_backup_log_$_now.log"
else
    echo "Alte Archive konnten gelöscht werden" >> "$_bdir/proxmox_backup_log_$_now.log"
fi

sudo find "$_bdir" -name "*.log" -type f -mtime $_maxdays -exec rm -f {} \;
if [ $? -ne 0 ]; then
    echo "Keine alten Logdateien gefunden" >> "$_bdir/proxmox_backup_log_$_now.log"
else
    echo "Alte Logdateien  konnten gelöscht werden" >> "$_bdir/proxmox_backup_log_$_now.log"
fi