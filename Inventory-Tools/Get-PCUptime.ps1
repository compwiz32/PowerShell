function Get-PCUptime {

    <#
    .SYNOPSIS
        Displays the current uptime and last boot time for one or more computers.

    .DESCRIPTION
        Displays the current uptime and last boot time for one or more computers by querying CIM data. Remote computers
        are queried via WINRM using CIMInstance.

    .PARAMETER ComputerName
        Then name of a computer to query. Valid aliases are Name, Computer, & PC.

    .PARAMETER Credential
        Alternate credentials that can be used to run the function as another user.

    .EXAMPLE

        Get-PCUptime

        Days         : 40
        Hours        : 20
        Minutes      : 59
        TotalHours   : 981
        LastBootTime : 4/7/2020 10:38:44 AM

        Returns uptime stats for the local computer

    .EXAMPLE

        Get-PCUpTime | Format-Table

        Days Hours Minutes TotalHours LastBootTime
        ---- ----- ------- ---------- ------------
        53      22      17       1294 4/7/2020 10:38:44 AM

        Returns uptime stats for the local computer and display results in  table format

    .EXAMPLE

        $dc = 'DC01','DC02','DC03'

        Get-PCUptime $dc | Format-Table -AutoSize

        Days Hours Minutes TotalHours LastBootTime          PSComputerName
        ---- ----- ------- ---------- ------------          --------------
        12      0      59        289  5/19/2020 7:16:18 AM  DC01
        105     0      25       2520  2/16/2020 7:49:49 AM  DC02
        205     9      57       4930  11/7/2019 10:17:50 PM DC03

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
           [Alias("PC","Computer","Name")]
           [Parameter(
                ValueFromPipeline,
                ValueFromPipelineByPropertyName
                )]
           [string[]]
           $ComputerName = $env:COMPUTERNAME,

           [PSCredential]
           $Credential
        )

        process {
            $code = {
                $OSInfo = Get-CimInstance Win32_OperatingSystem
                $LastBootTime = $OSInfo.LastBootUpTime
                $Uptime = (New-TimeSpan -start $lastBootTime -end (Get-Date))

                $SelectProps =
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
            } #End $code

            Invoke-Command -ScriptBlock $code @PSBoundParameters -ErrorAction SilentlyContinue -ErrorVariable NoConnect | Select-Object * -ExcludeProperty RunspaceID

            foreach($fail in $NoConnect) {
                Write-Warning "Failed to run on $($fail.TargetObject)"
            } #end foreach warning loop
        } #End Process
    } #end function