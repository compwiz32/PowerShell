<# 
  .Synopsis 
  Exports information about servers at all North America sites.

  .Description 
  Will gather information on servers from all North American sites (there are 12). The information
  is exported to a preformatted HTML page. The formatting of the HTML table has alternating row
  colors which facilitates reading quickly
  This script was written to pull a report for Mike Kanakos.

  .Example 
  DomainControllers
  Asks the user to input a filepath to save the CSV to and then returns a variety of information on 
  servers at all North America sites.

#>

#Change the format of the HTML file
$Style = "
<style>
    BODY{background-color:#b0c4de;}
    TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}
    TH{border-width: 1px;padding: 3px;border-style: solid;border-color: black;background-color:#778899}
    TD{border-width: 1px;padding: 3px;border-style: solid;border-color: black;}
    tr:nth-child(odd) { background-color:#d3d3d3;} 
    tr:nth-child(even) { background-color:white;}
</style>
"

$Computers = Get-ADComputer -Searchbase "OU=Servers,OU=North_America,DC=LORD,DC=LOCAL" -Filter {description -like "*-*"} -properties * | select name, description

#Large loop to collect information from each server in an array
$CompInfo = ForEach ($Computer in $Computers)
{

function GetComputerInfo{
    Param($mc)
    # Ping the machine to see if it is online
    $online=PingMachine $mc
    if ($online -eq $true)
    {
        # Ping Success

        # ComputerSystem info
        $CompInfo = Get-WmiObject Win32_ComputerSystem -comp $mc

        # OS info
        $OSInfo = Get-WmiObject Win32_OperatingSystem -comp $mc

        # Serial No
        $BiosInfo = Get-WmiObject Win32_BIOS -comp $mc

        # CPU Info
        $CPUInfo = Get-WmiObject Win32_Processor -comp $mc

        #OS Build Info
        #$OSBuildInfo = (Get-WmiObject Win32_OperatingSystem -computernam -comp $mc

        # Create custom Object
        $myobj = "" | Select-Object Name,Domain,Model,MachineSN,OS,ServicePack,WindowsSN,Uptime,RAM,Disk,CPU,Architecture,InstallDate,Description
        $myobj.Name = $CompInfo.Name
        $myobj.Domain = $CompInfo.Domain
        $myobj.Model = $CompInfo.Model
        $myobj.MachineSN = $BiosInfo.SerialNumber
        $myobj.OS = $OSInfo.Caption
        $myobj.Description = $OSInfo.Description
        $myobj.ServicePack = $OSInfo.servicepackmajorversion
        $myobj.WindowsSN = $OSInfo.SerialNumber
        $myobj.uptime = (Get-Date) - [System.DateTime]::ParseExact($OSInfo.LastBootUpTime.Split(".")[0],'yyyyMMddHHmmss',$null)
        $myobj.uptime = "$($myobj.uptime.Days) days, $($myobj.uptime.Hours) hours," +`
          " $($myobj.uptime.Minutes) minutes, $($myobj.uptime.Seconds) seconds" 

        $myobj.RAM = "{0:n2} GB" -f ($CompInfo.TotalPhysicalMemory/1gb)
        $myobj.Disk = GetDriveInfo $mc
        $myobj.CPU = $CPUInfo.Name
        $myobj.Architecture = $OSInfo.OSArchitecture
        $myobj.InstallDate = ([WMI]'').ConvertToDateTime($OSinfo.InstallDate)
        
        #Return Custom Object
        $myobj
    }
    else
    {
        # Ping Failed!
        Write-Host "Error: $mc not Pingable" -fore RED
    }
}

function GetDriveInfo{
    Param($comp)
    # Get disk sizes
    $logicalDisk = Get-WmiObject Win32_LogicalDisk -Filter "DriveType=3" -ComputerName $comp
    foreach($disk in $logicalDisk)
    {
        $diskObj = "" | Select-Object Disk,Size,FreeSpace
        $diskObj.Disk = $disk.DeviceID
        $diskObj.Size = "{0:n0} GB" -f (($disk | Measure-Object -Property Size -Sum).sum/1gb)
        $diskObj.FreeSpace = "{0:n0} GB" -f (($disk | Measure-Object -Property FreeSpace -Sum).sum/1gb)

        $text = "{0}  {1}  Free: {2}" -f $diskObj.Disk,$diskObj.size,$diskObj.Freespace
        $msg += $text + [char]13 + [char]10 
    }
    $msg
}

function PingMachine {
   Param([string]$machinename)
   $pingresult = Get-WmiObject win32_pingstatus -f "address='$machinename'"
   if($pingresult.statuscode -eq 0) {$true} else {$false}
}

$Description = $Computer.description

#Determine which site it is at
If ($Description -like '*ACO*'){
$Site = "Amherst Commerce"
}
ElseIf ($Description -like '*ACR*'){
$Site = "Amherst Creekside"
}
ElseIf ($Description -like '*BGP*'){
$Site = "Bowling Green"
}
ElseIf ($Description -like '*CSP*'){
$Site = "Cambridge Springs"
}
ElseIf ($Description -like '*CRD*'){
$Site = "Cary"
}
ElseIf ($Description -like '*COL*'){
$Site = "Columbus"
}
ElseIf ($Description -like '*DTN*'){
$Site = "Dayton"
}
ElseIf ($Description -like '*DTW*'){
$Site = "Detroit"
}
ElseIf ($Description -like '*ERI*'){
$Site = "Erie"
}
ElseIf ($Description -like '*INP*'){
$Site = "Idianapolis"
}
ElseIf ($Description -like '*SGT*'){
$Site = "Saegertown"
}
ElseIf ($Description -like '*WST*'){
$Site = "Williston"
}

# Main - run all the functions
GetComputerInfo ($Computer.name)  | Select-Object Name, @{l='Site';e={$Site}}, Domain, Description, OS, ServicePack, Architecture, Model, @{name="CPU";expression={$_.CPU -join ";"}}, Disk, RAM, InstallDate, Uptime

$Screen = $Computer.name

Write-Host "Information recorded for $Screen"
} 

#Display the text above the table
$Body = "<h1><center>Servers</center></h1>
<h3><center>All Locations</center></h3>"

Write-Host "Input file path to save output file.  Example: " -nonewline
Write-host "c:\temp\serverList.htm" -foregroundcolor Magenta
Write-Host "Please save file with .htm file extension" -ForegroundColor Green
Write-Host ">>" -NoNewline
$FilePath = Read-Host 

#Export to HTML file with specific head and body statements
$CompInfo | Sort-Object -Property site, name | ConvertTo-HTML -head $Style -Body $Body | Out-File $FilePath

#Runs command on local computer
Invoke-Expression $FilePath

#End