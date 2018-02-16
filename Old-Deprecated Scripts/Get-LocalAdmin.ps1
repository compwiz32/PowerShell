#
# Get local admins group user list
# Created: 2016-01-05 - Mike Kanakos
# ----------------------------------

# Unused input - uncomment to prompt users for domain input
# $DomainName = Read-Host "Domain name"


# Prompt User for computer name
$ComputerName = Read-Host "Computer Name"

#List current group membership of local admin group
invoke-command {net localgroup administrators} -comp $computername