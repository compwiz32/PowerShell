# Get-CurrentADMode
#
# 2016-02-09 - Mike Kanakos


# Get Current AD Modes
$ForestMode = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().ForestMode
$DomainMode = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().DomainMode

#Display Results
Write-Host "The current Active Directory Forest Mode is: " -NoNewline
Write-Host $ForestMode -foregroundcolor Yellow

Write-Host "The current Active Directory Domain Mode is: " -NoNewline
Write-Host $DomainMode -foregroundcolor Yellow

