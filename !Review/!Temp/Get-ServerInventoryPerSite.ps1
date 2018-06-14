# Melissa Green
# Will gather information on all servers at 1 specified site at a time. When the script is run, a menu
# option will appear to the user and they can select which site they would like the server information from.
# The list has all of the sites globally and it is separated into region for ease of use. The information 
# is exported to a preformatted HTML page. The formatting of the HTML table has alternating row
# colors which facilitates reading quickly.

# TESTED AND RUNS AS EXPECTED

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

#Get information from the user about which site they want to see servers from

Write-Host "Select site by Number" -ForegroundColor Green
Write-Host "
North America Sites:" -ForegroundColor Yellow
Write-Host "1  - Amherst Commerce
2  - Amherst Creekside
3  - Bowling Green
4  - Cambridge Springs
5  - Cary
6  - Columbus
7  - Dayton
8  - Detroit Wixom
9  - Erie
10 - Indianapolis
11 - Saegertown
12 - Williston
" 

Write-Host "Asia Pacific Sites:" -ForegroundColor Yellow

Write-host "13 - Australia
14 - China
15 - Hong Kong
16 - India
17 - Indonesia
18 - Japan
19 - Malaysia
20 - Singapore
21 - Taiwan
22 - Thailand
"

Write-Host "European Sites" -ForegroundColor Yellow
Write-host "23 - Geneva, Switzerland
24 - Hilden, Germany
25 - Huckelhoven, Germany
26 - Leuna, Germany
27 - Monzambano, Italy
28 - Saint Vallier, France
"

Write-Host "South American Sites:" -ForegroundColor Yellow
Write-Host "29 - Brazil"
Write-Host "
Input a Number:" -nonewline
$pickSite = Read-Host


#Decide which text is displayed above the table and on the host screen
If ($pickSite -eq 1){
$Body = "<h1><center>Servers</center></h1>
<h3><center>Amherst Commerce</center></h3>"
}
ElseIf ($pickSite -eq 2){
$Body = "<h1><center>Servers</center></h1>
<h3><center>Amherst Creekside</center></h3>"
}
ElseIf ($pickSite -eq 3){
$Body = "<h1><center>Servers</center></h1>
<h3><center>Bowling Green</center></h3>"
}
ElseIf ($pickSite -eq 4){
$Body = "<h1><center>Servers</center></h1>
<h3><center>Cambridge Springs</center></h3>"
}
ElseIf ($pickSite -eq 5){
$Body = "<h1><center>Servers</center></h1>
<h3><center>Cary</center></h3>"
}
ElseIf ($pickSite -eq 6){
$Body = "<h1><center>Servers</center></h1>
<h3><center>Columbus</center></h3>"
}
ElseIf ($pickSite -eq 7){
$Body = "<h1><center>Servers</center></h1>
<h3><center>Dayton</center></h3>"
}
ElseIf ($pickSite -eq 8){
$Body = "<h1><center>Servers</center></h1>
<h3><center>Detroit Wixom</center></h3>"
}
ElseIf ($pickSite -eq 9){
$Body = "<h1><center>Servers</center></h1>
<h3><center>Erie</center></h3>"
}
ElseIf ($pickSite -eq 10){
$Body = "<h1><center>Servers</center></h1>
<h3><center>Indianapolis</center></h3>"
}
ElseIf ($pickSite -eq 11){
$Body = "<h1><center>Servers</center></h1>
<h3><center>Saegertown</center></h3>"
}
ElseIf ($pickSite -eq 12){
$Body = "<h1><center>Servers</center></h1>
<h3><center>Williston</center></h3>"
}

ElseIf ($pickSite -eq 13){
$Body = "<h1><center>Servers</center></h1>
<h3><center>Australia</center></h3>"
}
ElseIf ($pickSite -eq 14){
$Body = "<h1><center>Servers</center></h1>
<h3><center>China</center></h3>"
}
ElseIf ($pickSite -eq 15){
$Body = "<h1><center>Servers</center></h1>
<h3><center>Hong Kong</center></h3>"
}
ElseIf ($pickSite -eq 16){
$Body = "<h1><center>Servers</center></h1>
<h3><center>India</center></h3>"
}
ElseIf ($pickSite -eq 17){
$Body = "<h1><center>Servers</center></h1>
<h3><center>Indonesia</center></h3>"
}
ElseIf ($pickSite -eq 18){
$Body = "<h1><center>Servers</center></h1>
<h3><center>Japan</center></h3>"
}
ElseIf ($pickSite -eq 19){
$Body = "<h1><center>Servers</center></h1>
<h3><center>Malaysia</center></h3>"
}
ElseIf ($pickSite -eq 20){
$Body = "<h1><center>Servers</center></h1>
<h3><center>Singapore</center></h3>"
}
ElseIf ($pickSite -eq 21){
$Body = "<h1><center>Servers</center></h1>
<h3><center>Taiwan</center></h3>"
}
ElseIf ($pickSite -eq 22){
$Body = "<h1><center>Servers</center></h1>
<h3><center>Thailand</center></h3>"
}

ElseIf ($pickSite -eq 23){
$Body = "<h1><center>Servers</center></h1>
<h3><center>Geneva, Switzerland</center></h3>"
}
ElseIf ($pickSite -eq 24){
$Body = "<h1><center>Servers</center></h1>
<h3><center>Hilden, Germany</center></h3>"
}
ElseIf ($pickSite -eq 25){
$Body = "<h1><center>Servers</center></h1>
<h3><center>Huckelhoven, Germany</center></h3>"
}
ElseIf ($pickSite -eq 26){
$Body = "<h1><center>Servers</center></h1>
<h3><center>Leuna, Germany</center></h3>"
}
ElseIf ($pickSite -eq 27){
$Body = "<h1><center>Servers</center></h1>
<h3><center>Monzambano, Italy</center></h3>"
}
ElseIf ($pickSite -eq 28){
$Body = "<h1><center>Servers</center></h1>
<h3><center>Saint Vallier, France</center></h3>"
}

ElseIf ($pickSite -eq 29){
$Body = "<h1><center>Servers</center></h1>
<h3><center>Brazil</center></h3>"
}

Else{
$Body = "<h1><center>Unknown Location</center></h1>"
}

#Message to the user so they know the program is running
Write-Host "
Gathering information about servers, please wait (wait times can be more than 10 minutes for large sites)..."  -ForegroundColor red -BackgroundColor white

#Only find the servers from a specific location in the OU
switch ($pickSite)
{
    1 {$Servers = Get-ADComputer -Searchbase "OU=Servers,OU=North_America,DC=LORD,DC=LOCAL" -Filter {description -like "*ACO*"} -properties * | select name; break}
    2 {$Servers = Get-ADComputer -Searchbase "OU=Servers,OU=North_America,DC=LORD,DC=LOCAL" -Filter {description -like "*ACR*"} -properties * | select name; break}
    3 {$Servers = Get-ADComputer -Searchbase "OU=Servers,OU=North_America,DC=LORD,DC=LOCAL" -Filter {description -like "*BGP*"} -properties * | select name; break}
    4 {$Servers = Get-ADComputer -Searchbase "OU=Servers,OU=North_America,DC=LORD,DC=LOCAL" -Filter {description -like "*CSP*"} -properties * | select name; break}
    5 {$Servers = Get-ADComputer -Searchbase "OU=Servers,OU=North_America,DC=LORD,DC=LOCAL" -Filter {description -like "*CRD*"} -properties * | select name; break}
    6 {$Servers = Get-ADComputer -Searchbase "OU=Servers,OU=North_America,DC=LORD,DC=LOCAL" -Filter {description -like "*COL*"} -properties * | select name; break}
    7 {$Servers = Get-ADComputer -Searchbase "OU=Servers,OU=North_America,DC=LORD,DC=LOCAL" -Filter {description -like "*DTN*"} -properties * | select name; break}
    8 {$Servers = Get-ADComputer -Searchbase "OU=Servers,OU=North_America,DC=LORD,DC=LOCAL" -Filter {description -like "*DTW*"} -properties * | select name; break}
    9 {$Servers = Get-ADComputer -Searchbase "OU=Servers,OU=North_America,DC=LORD,DC=LOCAL" -Filter {description -like "*ERI*"} -properties * | select name; break}
    10 {$Servers = Get-ADComputer -Searchbase "OU=Servers,OU=North_America,DC=LORD,DC=LOCAL" -Filter {description -like "*INP*"} -properties * | select name; break}
    11 {$Servers = Get-ADComputer -Searchbase "OU=Servers,OU=North_America,DC=LORD,DC=LOCAL" -Filter {description -like "*SGT*"} -properties * | select name; break}
    12 {$Servers = Get-ADComputer -Searchbase "OU=Servers,OU=North_America,DC=LORD,DC=LOCAL" -Filter {description -like "*WST*"} -properties * | select name; break}

    13 {$Servers = Get-ADComputer -Searchbase "OU=Servers,OU=Australia,OU=Asia_Pacific,DC=LORD,DC=LOCAL" -Filter {description -like "*AUS*"} -properties * | select name; break}
    14 {$Servers = Get-ADComputer -Searchbase "OU=Servers,OU=China,OU=Asia_Pacific,DC=LORD,DC=LOCAL" -Filter {description -like "*CHN*"} -properties * | select name; break}
    15 {$Servers = Get-ADComputer -Searchbase "OU=Servers,OU=Hong_Kong,OU=Asia_Pacific,DC=LORD,DC=LOCAL" -Filter {description -like "*HKG*"} -properties * | select name; break}
    16 {$Servers = Get-ADComputer -Searchbase "OU=Servers,OU=India,OU=Asia_Pacific,DC=LORD,DC=LOCAL" -Filter {description -like "*NSK*"} -properties * | select name; break}
    17 {$Servers = Get-ADComputer -Searchbase "OU=Servers,OU=Indonesia,OU=Asia_Pacific,DC=LORD,DC=LOCAL" -Filter {description -like "*JKT*"} -properties * | select name; break}
    18 {$Servers = Get-ADComputer -Searchbase "OU=Servers,OU=Japan,OU=Asia_Pacific,DC=LORD,DC=LOCAL" -Filter {description -like "*JPN*"} -properties * | select name; break}
    19 {$Servers = Get-ADComputer -Searchbase "OU=Servers,OU=Malaysia,OU=Asia_Pacific,DC=LORD,DC=LOCAL" -Filter {description -like "*SEL*"} -properties * | select name; break}
    20 {$Servers = Get-ADComputer -Searchbase "OU=Servers,OU=Singapore,OU=Asia_Pacific,DC=LORD,DC=LOCAL" -Filter {description -like "*SGP*"} -properties * | select name; break}
    21 {$Servers = Get-ADComputer -Searchbase "OU=Servers,OU=Taiwan,OU=Asia_Pacific,DC=LORD,DC=LOCAL" -Filter {description -like "*TWN*"} -properties * | select name; break}
    22 {$Servers = Get-ADComputer -Searchbase "OU=Servers,OU=Thailand,OU=Asia_Pacific,DC=LORD,DC=LOCAL" -Filter {description -like "*BKK*"} -properties * | select name; break}

    23 {$Servers = Get-ADComputer -Searchbase "OU=Servers,OU=Europe,DC=LORD,DC=LOCAL" -Filter {description -like "*GVA*"} -properties * | select name; break}
    24 {$Servers = Get-ADComputer -Searchbase "OU=Servers,OU=Europe,DC=LORD,DC=LOCAL" -Filter {description -like "*HLD*"} -properties * | select name; break}
    25 {$Servers = Get-ADComputer -Searchbase "OU=Servers,OU=Europe,DC=LORD,DC=LOCAL" -Filter {description -like "*HUC*"} -properties * | select name; break}
    26 {$Servers = Get-ADComputer -Searchbase "OU=Servers,OU=Europe,DC=LORD,DC=LOCAL" -Filter {description -like "*LEU*"} -properties * | select name; break}
    27 {$Servers = Get-ADComputer -Searchbase "OU=Servers,OU=Europe,DC=LORD,DC=LOCAL" -Filter {description -like "*LIT*"} -properties * | select name; break}
    29 {$Servers = Get-ADComputer -Searchbase "OU=Servers,OU=Europe,DC=LORD,DC=LOCAL" -Filter {description -like "*STV*"} -properties * | select name; break}

    29 {$Servers = Get-ADComputer -Searchbase "OU=Servers,OU=South_America,DC=LORD,DC=LOCAL" -Filter {description -like "*JUN*"} -properties * | select name; break}
    default {"That is not a valid Site"}
}

switch ($pickSite)
{
    1 {$DCs = Get-ADComputer -Searchbase "OU=Domain Controllers,DC=LORD,DC=LOCAL" -Filter {description -like "*ACO*"} -properties * | select name; break}
    2 {$DCs = Get-ADComputer -Searchbase "OU=Domain Controllers,DC=LORD,DC=LOCAL" -Filter {description -like "*ACR*"} -properties * | select name; break}
    3 {$DCs = Get-ADComputer -Searchbase "OU=Domain Controllers,DC=LORD,DC=LOCAL" -Filter {description -like "*BGP*" -or description -like "*BGW*"} -properties * | select name; break}
    4 {$DCs = Get-ADComputer -Searchbase "OU=Domain Controllers,DC=LORD,DC=LOCAL" -Filter {description -like "*CSP*"} -properties * | select name; break}
    5 {$DCs = Get-ADComputer -Searchbase "OU=Domain Controllers,DC=LORD,DC=LOCAL" -Filter {description -like "*CRD*"} -properties * | select name; break}
    6 {$DCs = Get-ADComputer -Searchbase "OU=Domain Controllers,DC=LORD,DC=LOCAL" -Filter {description -like "*COL*"} -properties * | select name; break}
    7 {$DCs = Get-ADComputer -Searchbase "OU=Domain Controllers,DC=LORD,DC=LOCAL" -Filter {description -like "*DTN*"} -properties * | select name; break}
    8 {$DCs = Get-ADComputer -Searchbase "OU=Domain Controllers,DC=LORD,DC=LOCAL" -Filter {description -like "*DTW*"} -properties * | select name; break}
    9 {$DCs = Get-ADComputer -Searchbase "OU=Domain Controllers,DC=LORD,DC=LOCAL" -Filter {description -like "*ERI*"} -properties * | select name; break}
    10 {$DCs = Get-ADComputer -Searchbase "OU=Domain Controllers,DC=LORD,DC=LOCAL" -Filter {description -like "*INP*"} -properties * | select name; break}
    11 {$DCs = Get-ADComputer -Searchbase "OU=Domain Controllers,DC=LORD,DC=LOCAL" -Filter {description -like "*SGT*"} -properties * | select name; break}
    12 {$DCs = Get-ADComputer -Searchbase "OU=Domain Controllers,DC=LORD,DC=LOCAL" -Filter {description -like "*WST*"} -properties * | select name; break}

    13 {$DCs = Get-ADComputer -Searchbase "OU=Domain Controllers,DC=LORD,DC=LOCAL" -Filter {description -like "*AUS*" -or description -like "*TVA*"} -properties * | select name; break}
    14 {$DCs = Get-ADComputer -Searchbase "OU=Domain Controllers,DC=LORD,DC=LOCAL" -Filter {description -like "*CHN*" -or description -like "*LMS*" -or description -like "*LTS*"} -properties * | select name; break}
    15 {$DCs = Get-ADComputer -Searchbase "OU=Domain Controllers,DC=LORD,DC=LOCAL" -Filter {description -like "*HKG*"} -properties * | select name; break}
    16 {$DCs = Get-ADComputer -Searchbase "OU=Domain Controllers,DC=LORD,DC=LOCAL" -Filter {description -like "*NSK*" -or description -like "*MUM*"} -properties * | select name; break}
    17 {$DCs = Get-ADComputer -Searchbase "OU=Domain Controllers,DC=LORD,DC=LOCAL" -Filter {description -like "*JKT*"} -properties * | select name; break}
    18 {$DCs = Get-ADComputer -Searchbase "OU=Domain Controllers,DC=LORD,DC=LOCAL" -Filter {description -like "*JPN*"} -properties * | select name; break}
    19 {$DCs = Get-ADComputer -Searchbase "OU=Domain Controllers,DC=LORD,DC=LOCAL" -Filter {description -like "*SEL*"} -properties * | select name; break}
    20 {$DCs = Get-ADComputer -Searchbase "OU=Domain Controllers,DC=LORD,DC=LOCAL" -Filter {description -like "*SGP*"} -properties * | select name; break}
    21 {$DCs = Get-ADComputer -Searchbase "OU=Domain Controllers,DC=LORD,DC=LOCAL" -Filter {description -like "*TWN*"} -properties * | select name; break}
    22 {$DCs = Get-ADComputer -Searchbase "OU=Domain Controllers,DC=LORD,DC=LOCAL" -Filter {description -like "*BKK*"} -properties * | select name; break}

    23 {$DCs = Get-ADComputer -Searchbase "OU=Domain Controllers,DC=LORD,DC=LOCAL" -Filter {description -like "*GVA*" -or description -like "*GEV*"} -properties * | select name; break}
    24 {$DCs = Get-ADComputer -Searchbase "OU=Domain Controllers,DC=LORD,DC=LOCAL" -Filter {description -like "*HLD*"} -properties * | select name; break}
    25 {$DCs = Get-ADComputer -Searchbase "OU=Domain Controllers,DC=LORD,DC=LOCAL" -Filter {description -like "*HUC*"} -properties * | select name; break}
    26 {$DCs = Get-ADComputer -Searchbase "OU=Domain Controllers,DC=LORD,DC=LOCAL" -Filter {description -like "*LEU*"} -properties * | select name; break}
    27 {$DCs = Get-ADComputer -Searchbase "OU=Domain Controllers,DC=LORD,DC=LOCAL" -Filter {description -like "*LIT*"} -properties * | select name; break}
    29 {$DCs = Get-ADComputer -Searchbase "OU=Domain Controllers,DC=LORD,DC=LOCAL" -Filter {description -like "*STV*"} -properties * | select name; break}

    29 {$DCs = Get-ADComputer -Searchbase "OU=Domain Controllers,DC=LORD,DC=LOCAL" -Filter {description -like "*JUN*" -or description -like "*ITV*"} -properties * | select name; break}
    default {"That is not a valid Site"}
}

$Computers = @()
$Computers += $Servers
$Computers += $DCs

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
        Write-Host "Error: $mc not Pingable" -foregroundcolor Magenta
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
GetComputerInfo ($Computer.name)  | Select-Object Name, Domain, Description, OS, ServicePack, Architecture, Model, @{name="CPU";expression={$_.CPU -join ";"}}, Disk, RAM, InstallDate, Uptime

} 

Write-Host "Input file path to save output file.  Example: " -nonewline
Write-host "c:\temp\serverList.htm" -foregroundcolor Magenta
Write-Host "Please save file with .htm file extension" -ForegroundColor Green
Write-Host ">>" -NoNewline
$FilePath = Read-Host 

#Export to HTML file with specific head and body statements
$CompInfo | Sort-Object -Property name | ConvertTo-HTML -head $Style -Body $Body | Out-File $FilePath

#Runs command on local computer
Invoke-Expression $FilePath

#End