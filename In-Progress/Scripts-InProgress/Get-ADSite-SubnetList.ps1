$siteDescription=@{}
$siteSubnets=@{}
$subnetDescription=@{}
$sitesDN="LDAP://CN=Sites," + $([adsi] "LDAP://RootDSE").Get("ConfigurationNamingContext")
$subnetsDN="LDAP://CN=Subnets,CN=Sites," + $([adsi] "LDAP://RootDSE").Get("ConfigurationNamingContext")

#get the site names and descriptions
foreach ($site in $([adsi] $sitesDN).psbase.children){
 if($site.objectClass -eq "site"){
  $siteName=([string]$site.cn).toUpper()
  $siteDescription[$siteName]=$site.description[0]
  $siteSubnets[$siteName]=@()
 }
}

#get the subnets and associate them with the sites
foreach ($subnet in $([adsi] $subnetsDN).psbase.children){
 $subnetDescription[[string]$subnet.cn]=$subnet.description[0]
 $site=[adsi] "LDAP://$($subnet.siteObject)"
 if($site.cn -ne $null){
  $siteName=([string]$site.cn).toUpper()
  $siteSubnets[$siteName] += $subnet.cn
 }else{
  $siteDescription["Orphaned"]="Subnets not associated with any site"
  if($siteSubnets["Orphaned"] -eq $null){ $siteSubnets["Orphaned"] = @() }
  $siteSubnets["Orphaned"] += $subnet.cn
 }
}

#write output to screen
foreach ($siteName in $siteDescription.keys | sort){
 "$siteName  $($siteDescription[$siteName])"
 foreach ($subnet in $siteSubnets[$siteName]){
  "`t$subnet $($subnetDescription[$subnet])"
 }
}