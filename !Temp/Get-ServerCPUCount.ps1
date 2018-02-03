# $Servers = Get-ADComputer -LDAPFilter “(&(objectcategory=computer)(OperatingSystem=*server*))” -Properties OperatingSystem

# $Servers | select name, Operatingsystem 
# $Servers.Count
# $Servers = Get-ADComputer {(-LDAPFilter “(&(objectcategory=computer)(OperatingSystem=*server*))”)} -and (enabled -eq "true") -Properties OperatingSystem



$Servers = 'wincrddc01','wincrddc02'
$CompModel = gwmi -ComputerName $Servers -Query "select Model from Win32_computerSystem"
$CompCores = gwmi -ComputerName $Servers -Query "select NumberOfCores from Win32_processor"

$Array = $Servers,$CompModel.Model,$CompCores.NumberofCores



# $Model = gwmi win32_computersystem -Property model | Select-Object Model

#foreach ($server in $Servers)
#{gwmi win32_computersystem -Property model | Select-Object Model
#}
# $Servers
#$Servers,$CompModel.Model,$CompCores.NumberofCores
$Array