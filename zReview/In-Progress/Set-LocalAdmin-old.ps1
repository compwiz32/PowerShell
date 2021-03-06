﻿# Set-LocalAdmin.ps1
# Add users to local admin group
# Created: 2016-01-05 - Mike Kanakos
# ----------------------------------

# Unused input - uncomment to prompt users for domain input
# $DomainName = Read-Host "Domain name"


# Prompt User for computer name
$ComputerName = Read-Host "Computer Name"

#List current group membership of local admin group
Write-Host ""
Write-Host "Current Group Membership" -ForegroundColor Yellow
Write-Host "------------------------"
invoke-command {net localgroup administrators} -comp $computername

# Prompt user for user to add
$UserName = Read-Host "Who would you like to add to the group?"

# Create reference object for the local Administrators group of the remote computer
$AdminGroup = [ADSI]"WinNT://$ComputerName/Administrators,group"

# Associate user input with A/D object
$User = [ADSI]"WinNT://lord.local/$UserName,user"

# Add user to local admin group
$AdminGroup.Add($User.Path)

# List updated group membership of local admin group
Write-Host ""
Write-Host "Updated Group Membership" -ForegroundColor Green
Write-Host "------------------------"
invoke-command {net localgroup administrators} -comp $computername