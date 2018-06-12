$sites = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().Sites
 
$sitesubnets = @()
 
foreach ($site in $sites)
{
	foreach ($subnet in $site.subnets){
	   $temp = New-Object PSCustomObject -Property @{
	   'Site' = $site.Name
	   'Subnet' = $subnet; }
	    $sitesubnets += $temp
	}
}
 
$sitesubnets | Sort-Object Site