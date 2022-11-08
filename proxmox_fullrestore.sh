#!/bin/bash

# setze Variablen
_bdir="/mnt/Proxmox-Backup-Destination"
_tarfilename="$_bdir/proxmox-fullbackup_2019-11-17.17.38.43.tar"
_tarextractdir="$_bdir/temp"

# tar
echo "Erstelle temporäres Verzeichnis $_tarextractdir ..." >> "$_bdir/proxmox_restore_log.log"
mkdir $_tarextractdir
if [ $? -ne 0 ]; then
    echo "Verzeichnis konnte nicht erstellt werden." >> "$_bdir/proxmox_backup_log_$_now.log"
    exit
else
    echo "Verzeichnis erfolgreich erstellt." >> "$_bdir/proxmox_backup_log_$_now.log"
fi

echo "Extrahiere $_tarfilename ..." >> "$_bdir/proxmox_restore_log.log"
tar -C $_tarextractdir -xvf $_tarfilename
if [ $? -ne 0 ]; then
    echo "Archiv konnte nicht entpackt werden." >> "$_bdir/proxmox_backup_log_$_now.log"
    exit
else
    echo "Archiv erfolgreich entpackt." >> "$_bdir/proxmox_backup_log_$_now.log"
fi

# rsync 
echo "Starte rsync von $_tarextractdir/etc nach / ..." >> "$_bdir/proxmox_restore_log.log"
sudo rsync -aAXv --delete --exclude="lost+found" $_tarextractdir/etc /
if [ $? -ne 0 ]; then
    echo "Rsync erfolgreich beendet." >> "$_bdir/proxmox_backup_log_$_now.log"
    exit
else
    echo "Rsync Fehler." >> "$_bdir/proxmox_backup_log_$_now.log"
fi

#loesche temp
echo "Entferne temporäres Verzeichnis $_tarextractdir ..." >> "$_bdir/proxmox_restore_log.log"
sudo rm -rf $_tarextractdir
if [ $? -ne 0 ]; then
    echo "Temporäres Verzeichnis konnte nicht entfernt werden." >> "$_bdir/proxmox_backup_log_$_now.log"
else
    echo "Temporäres Verzeichnis erfolgreich entfernt." >> "$_bdir/proxmox_backup_log_$_now.log"
fi