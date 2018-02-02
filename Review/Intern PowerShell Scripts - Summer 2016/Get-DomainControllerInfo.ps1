<# 
  .Synopsis 
  Exports information about Domain Controllers.

  .Description 
  Will gather hardware information on all domain controllers at all sites. The information is exported to a 
  preformatted HTML page. The formatting of the HTML page has alternating row colors which facilitates
  reading quickly.
  
  Will ask the user where they would like the file saved at the end of the script. The
  exported HTML file will list all of the domain controllers and which site they belong to.
  This script was written to pull a report for Mike Kanakos.

  .Example 
  get-DomainControllerInfo
  Asks the user to input a filepath to save the CSV to and then returns a variety of information on 
  domain controllers.

#>

$Computers = Get-ADComputer -Searchbase "OU=Domain Controllers,DC=LORD,DC=LOCAL" -filter * -properties * | select name, description

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

#Determine which site the DC is at
If ($Description -like '*ACO*'){
$Site = "Amherst Commerce"
}
ElseIf ($Description -like '*ACR*'){
$Site = "Amherst Creekside"
}
ElseIf ($Description -like '*BGP*'){
$Site = "Bowling Green"
}
ElseIf ($Description -like '*BGW*'){
$Site = "Bowling Green Warehouse"
}
ElseIf ($Description -like '*BKK*'){
$Site = "Bangkok-Thailand"
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
ElseIf ($Description -like '*GEV*'){
$Site = "Geneva"
}
ElseIf ($Description -like '*HKG*'){
$Site = "Hong Kong"
}
ElseIf ($Description -like '*HLD*'){
$Site = "Hilden"
}
ElseIf ($Description -like '*HUC*'){
$Site = "Huckelhoven"
}
ElseIf ($Description -like '*INP*'){
$Site = "Idianapolis"
}
ElseIf ($Description -like '*ITV*'){
$Site = "Brazil"
}
ElseIf ($Description -like '*JPN*'){
$Site = "Japan"
}
ElseIf ($Description -like '*LIT*'){
$Site = "Monzambano, Italy"
}
ElseIf ($Description -like '*LMS*'){
$Site = "Shanghai"
}
ElseIf ($Description -like '*LTS*'){
$Site = "Shanghai"
}
ElseIf ($Description -like '*MEX*'){
$Site = "Queretaro, Mexico"
}
ElseIf ($Description -like '*MUM*'){
$Site = "Mumbai, India"
}
ElseIf ($Description -like '*SGT*'){
$Site = "Saegertown"
}
ElseIf ($Description -like '*TWN*'){
$Site = "Taipei, Taiwan"
}
ElseIf ($Description -like '*TVA*'){
$Site = "Tullamarine-Victoria, Austrailia"
}
ElseIf ($Description -like '*WST*'){
$Site = "Williston"
}
Else{
$Site = "Unknown Location"
}

# Main - run all the functions
GetComputerInfo ($Computer.name)  | Select-Object Name, @{l='Site';e={$Site}}, Domain, Description, OS, ServicePack, Architecture, Model, @{name="CPU";expression={$_.CPU -join ";"}}, Disk, RAM, InstallDate, Uptime

$Screen = $Computer.name

#Print to screen to keep up with progress
Write-Host "Information recorded for $Screen"
} 

Write-Host "Input file path to save output file.  Example: " -nonewline
Write-host "c:\temp\serverList.htm" -foregroundcolor Magenta
Write-Host "Please save file with .htm file extension" -ForegroundColor Green
Write-Host ">>" -NoNewline
$FilePath = Read-Host 

#Export to HTML file with specific head and body statements
$CompInfo | Sort-Object -Property name | ConvertTo-HTML -head $Style | Out-File $FilePath

#Runs command on local computer
Invoke-Expression $FilePath