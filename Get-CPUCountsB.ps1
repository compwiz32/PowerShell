[array]$fullCompObject     = $null

$ServerList = Import-Csv "C:\Scripts\Output\ServerList.csv"

# [array]$Servers            = @($ServerList) 
$path                      = Split-Path -Path $MyInvocation.MyCommand.Path
Write-Output $ServerList


foreach ($server in $ServerList)

{

$CompModel = Get-WMIObject -Computer $server -Class Win32_computerSystem
Write-Output $CompModel

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