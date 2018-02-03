Param($machine)

function GetPCHardwareInfo{
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
        $myobj = "" | Select-Object Name,Domain,Model,MachineSN,OS,ServicePack,WindowsSN,Uptime,RAM,Disk,CPU,Architecture,InstallDate
        $myobj.Name = $CompInfo.Name
        $myobj.Domain = $CompInfo.Domain
        $myobj.Model = $CompInfo.Model
        $myobj.MachineSN = $BiosInfo.SerialNumber
        $myobj.OS = $OSInfo.Caption
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
        
        #Return Custom Object"
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

# Main - run all the functions
# GetPCHardwareInfo ($machine)  | Format-Table -Auto -Wrap  Name, Model, RAM, Architecture, CPU, InstallDate, Uptime, Disk
# GetPCHardwareInfo ($machine)  | Select-Object Name, Model, RAM, Architecture, CPU, Disk, InstallDate, Uptime | Out-GridView
GetPCHardwareInfo ($machine)  | Select-Object Name, Architecture, Model, RAM, CPU, Disk, InstallDate, Uptime