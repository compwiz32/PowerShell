Function Get-WMIComputerSessions {
<#
.SYNOPSIS
    Retrieves tall user sessions from local or remote server/s
.DESCRIPTION
    Retrieves tall user sessions from local or remote server/s
.PARAMETER computer
    Name of computer/s to run session query against.
.NOTES
    Name: Get-WmiComputerSessions
    Author: Boe Prox
    DateCreated: 01Nov2010
 
.LINK
    https://boeprox.wordpress.org
.EXAMPLE
Get-WmiComputerSessions -computer "server1"
 
Description
-----------
This command will query all current user sessions on 'server1'.
 
#>
[cmdletbinding(
    DefaultParameterSetName = 'session',
    ConfirmImpact = 'low'
)]
    Param(
        [Parameter(
            Mandatory = $True,
            Position = 0,
            ValueFromPipeline = $True)]
            [string[]]$computer
    )
Begin {
    #Create empty report
    $report = @()
    }
Process {
    #Iterate through collection of computers
    ForEach ($c in $computer) {
        #Get explorer.exe processes
        $proc = gwmi win32_process -computer $c -Filter "Name = 'explorer.exe'"
        #Go through collection of processes
        ForEach ($p in $proc) {
            $temp = "" | Select Computer, Domain, User
            $temp.computer = $c
            $temp.user = ($p.GetOwner()).User
            $temp.domain = ($p.GetOwner()).Domain
            $report += $temp
          }
        }
    }
End {
    $report
    }
}