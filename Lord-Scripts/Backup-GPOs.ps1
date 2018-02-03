# MK Script created 2017-04-10

# Script created from GPOBackupSamp.PS1 script found online at:
# https://gallery.technet.microsoft.com/scriptcenter/Backup-All-GPOs-Powershell-bcdb7b5e#content
# This script will Backup all GPOs and save it to a network folder named as the current date.

# Load GroupPolicy module
Import-Module grouppolicy

# Set the date format
$date = get-date -format yyyy.MM.dd

# Create new directory
New-Item -Path \\lord\americas\IT\Infrastructure\Backups\Group-Policy\$date -ItemType directory

# Backup GPO's to new directory
Backup-Gpo -All -Path \\lord\americas\IT\Infrastructure\Backups\Group-Policy\$date