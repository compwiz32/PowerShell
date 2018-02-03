function Get-RestartInfo ($Computername)

{
<#
.Synopsis
   Returns reboot / restart event log info for specified computer

.DESCRIPTION
   Queries the system event log and returns all log entries related to reboot & shutdown events (event ID 1074)

.EXAMPLE
   Get-Restartinfo WINCRDDC01

   This command will return all the  shutdown/restart eventlog info for server named WINCRDDC01

.NOTES
    NAME: Get-RestartInfo
    AUTHOR: Mike Kanakos
    CREATED: 2016-09-27
    LASTEDIT: 2016-09-27
    MISC: Found script online at https://social.technet.microsoft.com/wiki/contents/articles/17889.powershell-script-for-shutdownreboot-events-tracker.aspx
    CREDIT: Biswajit Biswas

#>

Get-WinEvent -ComputerName $computername -FilterHashtable @{logname='System'; id=1074}  | ForEach-Object {
$rv = New-Object PSObject | Select-Object Date, User, Action, Process, Reason, ReasonCode, Comment
$rv.Date = $_.TimeCreated
$rv.User = $_.Properties[6].Value
$rv.Process = $_.Properties[0].Value
$rv.Action = $_.Properties[4].Value
$rv.Reason = $_.Properties[2].Value
$rv.ReasonCode = $_.Properties[3].Value
$rv.Comment = $_.Properties[5].Value
$rv
} | Select-Object Date, Action, Reason, User
    
} #end of Function