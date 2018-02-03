ipmo activedirectory 
$ErrorActionPreference = "SilentlyContinue" 
$DCS=(Get-addomain).ReplicaDirectoryServers 
ForEach($DC in $DCS){ 
$DNS=GET-WMIobject -Computername $DC -Namespace "Root\MicrosoftDNS" -Class "MicrosoftDNS_server" 


if($DNS.ScavengingInterval -gt 0){ 
Write-host $DC  -ForegroundColor Green
  
$output = dnscmd $DC /info  
$Ageint= $output |Select-String "ScavengingInterval" 
$Agedefaultstate= $output |Select-String "DefaultAgingState" 
$Agedefaultint= $output |Select-String "DefaultRefreshInterval" 
$agedNorefresh= $output |Select-String "DefaultNoRefreshInterval" 
Write-Host "" 
Write-host "Aging Configuration:" 
Write-host $Ageint 
Write-Host $Agedefaultstate 
Write-Host $Agedefaultint 
Write-Host $agedNorefresh 
} 
Else { Write-Host "No Domain Controllers with DNS Scavenging enabled"} 
}