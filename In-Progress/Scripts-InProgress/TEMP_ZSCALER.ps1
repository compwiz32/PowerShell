$ZScalerGrp = (Get-ADGroup 'Sg-Zscaler-Test').DistinguishedName
$OU = "OU=Users,OU=Cary,OU=North_America,DC=LORD,DC=LOCAL"
$SiteCount = (Get-ADUser -filter * -SearchBase $OU).count
$NotMembers = Get-ADUser -SearchBase $OU -Filter { -not (memberof -eq $ZScalerGrp) }


Write-host " Total # of Users: " $SiteCount

foreach ($member in $notmembers)
{
 $StrippedOU = ($NotMembers.DistinguishedName -split “OU=Users,”,2)[1]
 $member.SamAccountName
 }
