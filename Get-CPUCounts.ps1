#$Servers1 = Get-ADComputer -LDAPFilter “(&(objectcategory=computer)(OperatingSystem=*server*))” | Select-Object name
$serverlist = Import-Csv "C:\Scripts\Output\ServerList.csv"

[array]$fullCompObject     = $null
#$Servers = Import-Csv "C:\Scripts\Output\ServerList.csv"

[array]$Servers            = @Import-Csv "C:\Scripts\Output\ServerList.csv"



# $path                      = Split-Path -Path $MyInvocation.MyCommand.Path

foreach ($server in $Servers)



{
Write-Output $server

$CompModel = Get-WMIObject -Computer $server -Class Win32_computerSystem
$CompCores = Get-WMIObject -Computer $server -Class Win32_processor

$compProperty   = @{Name=$server}
$compProperty   += @{Model=$compModel.Model}
$compProperty   += @{TotalCores=$compCores.Count}
$compObject     = New-Object PSObject -Property $compProperty
$fullCompObject += $compObject

}



if ($fullCompObject)
{

foreach ($comp in $fullCompObject)
{

    Write-Output "Name: $($comp.Name), Model: $($comp.Model), Total Cores: $($comp.TotalCores)"

}

if ((Read-Host "Export to CSV?") -like '*y*')
{

    $fullCompObject | Select-Object Name,Model,TotalCores | Export-CSV -Path "$path\wmi.csv" -NoTypeInformation
    Write-Output "CSV exported to: $path\wmi.csv"      

}

} else {

Write-Output 'Something went wrong!'

}