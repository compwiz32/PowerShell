## Get-ZscalerMissingUsers
## ---------------------------
## Mike Kanakos - 2016-09-28
## 
## Script gets count of total users for an OU and a count
## of users not in the Zscaler group for that OU
## -------------------------------------------------------

$ZScalerGrp = (Get-ADGroup 'Sg-Zscaler-Test').DistinguishedName
$OU = "OU=Users,OU=Erie,OU=North_America,DC=LORD,DC=LOCAL"
$SiteCount = (Get-ADUser -filter * -SearchBase $OU).count
$NotMembers = Get-ADUser -SearchBase $OU -Filter { -not (memberof -eq $ZScalerGrp) }
cls
Write-host " Total # of Users: " $SiteCount
Write-host " Total # of Users not in Zscaler Group: " $NotMembers.Count