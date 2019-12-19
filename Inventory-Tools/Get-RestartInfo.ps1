function Get-RestartInfo
{
    <#
    .Synopsis
        Returns reboot / restart event log info for specified computer

    .DESCRIPTION
        Queries the system event log and returns all log entries related to reboot & shutdown events (event ID 1074)

    .Parameter ComputerName
    Specifies a computer to add the users to. Multiple computers can be specified with commas and single quotes
    (-Computer 'Server01','Server02')

    .PARAMETER Credential
    Specifies the user you would like to run this function as


    .EXAMPLE
        Get-RestartInfo

        This command will return all the shutdown/restart eventlog info for the local computer.

        PS C:\Scripts\> Get-RestartInfo

        Computer : localhost
        Date     : 1/7/2019 5:16:50 PM
        Action   : shutdown
        Reason   : No title for this reason could be found
        User     : NWTRADERS.MSFT\Tom_Brady
        Process  : C:\WINDOWS\system32\shutdown.exe (CRDNAB-PC06LY52)
        Comment  :

        Computer : localhost
        Date     : 1/4/2019 5:36:58 PM
        Action   : shutdown
        Reason   : No title for this reason could be found
        User     : NWTRADERS.MSFT\Tom_Brady
        Process  : C:\WINDOWS\system32\shutdown.exe (CRDNAB-PC06LY52)
        Comment  :

        Computer : localhost
        Date     : 1/4/2019 9:10:11 AM
        Action   : restart
        Reason   : Operating System: Upgrade (Planned)
        User     : NT AUTHORITY\SYSTEM
        Process  : C:\WINDOWS\servicing\TrustedInstaller.exe (CRDNAB-PC06LY52)
        Comment  :


    .EXAMPLE
        Get-RestartInfo SERVER01 | select-object Computer, Date, Action, Reason, User

        This command will return all the shutdown/restart eventlog info for server named SERVER01


        PS C:\Scripts\> Get-RestartInfo SERVER01 | Format-Table -AutoSize

        Computer    Date                  Action  Reason                                  User
        --------    ----                  ------  ------                                  ----
        SERVER01    12/15/2018 6:21:45 AM restart No title for this reason could be found NT AUTHORITY\SYSTEM
        SERVER01    11/17/2018 6:57:53 AM restart No title for this reason could be found NT AUTHORITY\SYSTEM
        SERVER01    9/29/2018  6:47:50 AM restart No title for this reason could be found NT AUTHORITY\SYSTEM


    .NOTES
        NAME: Get-RestartInfo
        AUTHOR: Mike Kanakos
        CREATED: 2016-09-27
        LASTEDIT: 2019-12-17
        MISC: Function based on script found at:
        https://social.technet.microsoft.com/wiki/contents/articles/17889.powershell-script-for-shutdownreboot-events-tracker.aspx
        CREDIT: Biswajit Biswas

    .Link
        https://github.com/compwiz32/PowerShell
#>

[CmdletBinding()]
Param(
    [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName)]
    [alias("Name","MachineName","Computer")]
    [string[]]
    $ComputerName = 'localhost',

    [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty

    )

    Begin { }

    Process {
        Foreach($Computer in $ComputerName){
            $Connection = Test-Connection $Computer -Quiet -Count 2

            If(!$Connection) {
                Write-Warning "Computer: $Computer appears to be offline!"
            } #end If

            Else {
                Get-WinEvent -ComputerName $computer -FilterHashtable @{logname = 'System'; id = 1074,6005,6006,6008}  |
                    ForEach-Object {
                        $EventData = New-Object PSObject | Select-Object Date, EventID, User, Action, Reason, ReasonCode, Comment, Computer, Message, Process
                        $EventData.Date = $_.TimeCreated
                        $EventData.User = $_.Properties[6].Value
                        $EventData.Process = $_.Properties[0].Value
                        $EventData.Action = $_.Properties[4].Value
                        $EventData.Reason = $_.Properties[2].Value
                        $EventData.ReasonCode = $_.Properties[3].Value
                        $EventData.Comment = $_.Properties[5].Value
                        $EventData.Computer = $Computer
                        $EventData.EventID = $_.id
                        $EventData.Message = $_.Message
                    
                        $EventData | Select-Object Computer, Date, EventID, Action, Reason, User, Process, Comment


                    }
                } #end Else
        } #end Foreach Computer Loop
    } #end Process block
} #end of Function