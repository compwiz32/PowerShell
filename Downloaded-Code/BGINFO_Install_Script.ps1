##-------------------------------------------------------------------
 
## Name:            BgInfo Automated
## Usage:           BgInfo_Automated_v1.0.ps1
## Note:            Change variables were needed to fit your needs
## PSVersion:       Windows PowerShell 5.0
## Creator:         Wim Matthyssen
## Date:            21/02/17
## Version:         1
##-------------------------------------------------------------------
 
## Requires -RunAsAdministrator
## Variables
 
$BginfoUrl = 'https://download.sysinternals.com/files/BGInfo.zip'
$LogonBgiUrl = 'http://scug.be/wim/files/2017/02/LogonBgi.zip'
$BginfoZip = 'C:\BgInfo\BgInfo.zip'
$BginfoFolder = 'C:\BgInfo'
$BginfoEula = 'C:\BgInfo\Eula.txt'
$LogonBgiZip = 'C:\BgInfo\LogonBgi.zip'
$ForegroundColor1 = 'Red'
$ForegroundColor2 = 'Yellow'
$BginfoRegPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run'
$BginfoRegKey = 'BGInfo'
$BginfoRegKeyValue = 'C:\BgInfo\Bginfo.exe C:\BgInfo\logon.bgi /timer:0 /nolicprompt'
 
## Set date/time variable and write blank lines
$global:currenttime= Set-PSBreakpoint -Variable currenttime -Mode Read -Action { $global:currenttime= Get-Date }
 
for ($i = 1; $i -lt 4; $i++) {write-host}
Write-Host "Download started" $currenttime -foregroundcolor $ForegroundColor1
 
#Create BGInfo folder on C: if not exists
 
If(!(test-path $BginfoFolder))
    {
    New-Item -ItemType Directory -Force -Path $BginfoFolder
    Write-Host 'BgInfo folder created' -foregroundcolor $ForegroundColor2   
    }
 
## Download, save and extract latest BgInfo software to C:\BgInfo
 
function AllJobs-BginfoZip{
 
    Import-Module BitsTransfer
    Start-BitsTransfer -Source $BginfoUrl -Destination $BginfoZip
    Expand-Archive -LiteralPath $BginfoZip -DestinationPath $BginfoFolder
    Remove-Item $BginfoZip
    Remove-Item $BginfoEula
    
    for ($i = 1; $i -lt 2; $i++) {write-host}
    Write-Host 'bginfo.exe available' $currenttime -foregroundcolor $ForegroundColor2
    }
 
AllJobs-BginfoZip
 
## Download, save and extract logon.bgi file to C:\BgINfo

function AllJobs-LogonBgiZip{
    Invoke-WebRequest -Uri $LogonBgiUrl -OutFile $LogonBgiZip
    Expand-Archive -LiteralPath $LogonBgiZip -DestinationPath $BginfoFolder
    Remove-Item $LogonBgiZip
    
    for ($i = 1; $i -lt 2; $i++) {write-host}
    Write-Host 'logon.bgi available' $currenttime -foregroundcolor $ForegroundColor2
    }
 
AllJobs-LogonBgiZip
 
## Create BgInfo Registry Key to AutoStart
 
    function Add-BginfoRegKey{
    New-ItemProperty -Path $BginfoRegPath -Name $BginfoRegKey -PropertyType "String" -Value $BginfoRegKeyValue
    Write-Host 'BGInfo regkey added' -ForegroundColor $ForegroundColor2
    }
 
Add-BginfoRegKey
 
## Run BgInfo
 
C:\BgInfo\Bginfo.exe C:\BgInfo\logon.bgi /timer:0 /nolicprompt
 
for ($i = 1; $i -lt 2; $i++) {write-host}
Write-Host 'BgInfo has run' -foregroundcolor $ForegroundColor1
 
## Close PowerShell windows upon completion
 
stop-process -Id $PID
##-------------------------------------------------------------------