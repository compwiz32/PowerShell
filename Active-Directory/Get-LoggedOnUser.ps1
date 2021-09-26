function Get-LoggedOnUser {
    <#
.SYNOPSIS
   Queries a computer to check for interactive sessions / users logged into the computer

.DESCRIPTION
    returns a list of logged on users and status info about each logged on user.
    This script takes the output from the quser program and parses thre data into PowerShell objects

.NOTES
    Name: Get-LoggedOnUser
    Author: Mike Kanakos
    Original Author: Jaap Brasser (http://www.jaapbrasser.com)
    Version: 1.0.0
    DateUpdated: 2015-09-23

.LINK
    https://www.github.com/compwiz32/Powershell

.EXAMPLE
    Get-LoggedOnUser -ComputerName server01
    Displays the session information for server01

    UserName     : derek_jeter
    ComputerName : server01
    SessionName  :
    Id           : 2
    State        : Disc
    IdleTime     : 1+02:21
    LogonTime    : 3/28/2019 10:53 AM
    Error        :



.EXAMPLE
    Get-LoggedOnUser -ComputerName server01,server02

    Description:
    Displays the session information for server01 and server02

    UserName     : derek_jeter
    ComputerName : server01
    SessionName  :
    Id           : 2
    State        : Disc
    IdleTime     : 1+02:23
    LogonTime    : 3/28/2019 10:53 AM
    Error        :

    UserName     : tom_brady
    ComputerName : server02
    SessionName  : rdp-tcp#21
    Id           : 2
    State        : Active
    IdleTime     : 9
    LogonTime    : 3/19/2019 11:14 AM
    Error        :

    UserName     : derek_jeter
    ComputerName : server02
    SessionName  :
    Id           : 4
    State        : Disc
    IdleTime     : 8
    LogonTime    : 3/29/2019 10:22 AM
    Error        :


.EXAMPLE
    Get-LoggedOnUser -computername server01, server02 | format-table

    Description:
    Displays the session information on server01 and server02 and displays the output in a table view

    UserName          ComputerName SessionName Id State  IdleTime LogonTime          Error
    --------          ------------ ----------- -- -----  -------- ---------          -----
    derek_jeter       server01                  2  Disc   1+02:25  3/28/2019 10:53 AM
    tom_brady         server02      rdp-tcp#21  2  Active 12       3/19/2019 11:14 AM
    derek_jeter       server02                  4  Disc   10       3/29/2019 10:22 AM


.PARAMETER ComputerName
    The string or array of string for which a query will be executed
#>

    param(
        [CmdletBinding()]
        [Parameter(ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string[]]$ComputerName = 'localhost'
    )
    begin {
        $ErrorActionPreference = 'Stop'
    }

    process {
        foreach ($Computer in $ComputerName) {
            try {
                quser /server:$Computer 2>&1 | Select-Object -Skip 1 | ForEach-Object {
                    $CurrentLine = $_.Trim() -Replace '\s+', ' ' -Split '\s'
                    $HashProps = @{
                        UserName     = $CurrentLine[0]
                        ComputerName = $Computer
                    }

                    # If session is disconnected different fields will be selected
                    if ($CurrentLine[2] -eq 'Disc') {
                        $HashProps.SessionName = $null
                        $HashProps.Id = $CurrentLine[1]
                        $HashProps.State = $CurrentLine[2]
                        $HashProps.IdleTime = $CurrentLine[3]
                        $HashProps.LogonTime = $CurrentLine[4..6] -join ' '
                        $HashProps.LogonTime = $CurrentLine[4..($CurrentLine.GetUpperBound(0))] -join ' '
                    }
                    else {
                        $HashProps.SessionName = $CurrentLine[1]
                        $HashProps.Id = $CurrentLine[2]
                        $HashProps.State = $CurrentLine[3]
                        $HashProps.IdleTime = $CurrentLine[4]
                        $HashProps.LogonTime = $CurrentLine[5..($CurrentLine.GetUpperBound(0))] -join ' '
                    }

                    New-Object -TypeName PSCustomObject -Property $HashProps |
                    Select-Object -Property UserName, ComputerName, SessionName, Id, State, IdleTime, LogonTime, Error
                }
            }
            catch {
                New-Object -TypeName PSCustomObject -Property @{
                    ComputerName = $Computer
                    Error        = $_.Exception.Message
                } | Select-Object -Property UserName, ComputerName, SessionName, Id, State, IdleTime, LogonTime, Error
            }
        }
    }
} #End of Function