function Get-PCUptime {

<#
.SYNOPSIS
    Displays the current uptime and last boot time for one or more computers.

.DESCRIPTION
    Displays the current uptime and last boot time for one or more computers by querying CIM data. Remote computers
    are queried via WINRM using CIMInstance.

.PARAMETER ComputerName
        Then name of a computer to query. Valid aliases are Name, Computer, & PC.

.EXAMPLE

    Get-PCUptime

    Computer     : DC01
    Days         : 40
    Hours        : 20
    Minutes      : 59
    TotalHours   : 981
    LastBootTime : 4/7/2020 10:38:44 AM

    Returns uptime stats for the local computer

.EXAMPLE

    Get-PCUpTime | Format-Table

    Computer       Days Hours Minutes TotalHours LastBootTime
    --------       ---- ----- ------- ---------- ------------
    DC01           40    21       2        981 4/7/2020 10:38:44 AM

    Returns uptime stats for the local computer and display results in  table format

.EXAMPLE

    $dc = 'DC01','DC02','DC03'

    $dc | ForEach-Object {Get-PCUpTime $_ } | Format-Table -AutoSize

    Computer   Days Hours Minutes TotalHours LastBootTime
    --------   ---- ----- ------- ---------- ------------
    DC01       13    10      20        322 5/4/2020 9:27:23 PM
    DC02        4    10      34        107 5/13/2020 9:13:11 PM
    DC03       59    20       0       1436 3/19/2020 11:47:13 AM

    Returns uptime stats for three remote computers.

.INPUTS
    Computername
    Accepts input from pipeline

.OUTPUTS
    Output (if any)

.NOTES
   NAME:           Get-PCUptime.ps1
   AUTHOR:         Mike Kanakos
   DATE CREATED:   2020-05-18
#>


    [CmdletBinding()]
    param (
       [Alias("PC","Computer","ComputerName")]
       [Parameter(ValueFromPipelineByPropertyName = $true)]
       [string[]]$Name=$env:COMPUTERNAME
    )

    process {
        foreach ($PC in $Name) {
            Write-Verbose "Testing that $PC is online"
            $online = Test-Connection -ComputerName $PC -Count 1 -Quiet
                if ($online -eq $true){
                    $OSInfo = Get-CimInstance Win32_OperatingSystem -ComputerName $PC
                    $LastBootTime = $OSInfo.LastBootUpTime
                    $Uptime = (New-TimeSpan -start $lastBootTime -end (Get-Date))

                    $SelectProps = @{
                            Name       = 'Computer'
                            Expression = { $PC }
                        },
                        'Days',
                        'Hours',
                        'Minutes',
                        @{
                            Name       = 'TotalHours'
                            Expression = { [math]::Round($Uptime.TotalHours) }
                        },
                        @{
                            Name       = 'LastBootTime'
                            Expression = { $LastBootTime }
                        }

                    $Uptime | Select-Object $SelectProps
                }
        }
    }

}