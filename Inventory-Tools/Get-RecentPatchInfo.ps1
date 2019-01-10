Function Get-RecentPatchInfo {
    <#
     .Synopsis
     Returns last patch installed and last time the PC was restarted

     .Description
     Returns last patch installed and last time the PC was restarted.

     .Parameter computername
     The name of the computer to query. Defaults to local machine.

     .Example
     Get-RecentPatchInfo

     Description:
     Returns last installed patch and reboot info for the localhost.

     Computer           : localhost
     PatchType          : Security Update
     LastInstalledPatch : KB4483232
     InstallDate        : 1/4/2019 12:00:00 AM
     LastRestartTime    : 1/8/2019 8:57:51 AM


     .Example
     Get-RecentPatchInfo DC01, DC02

     Description:
     Returns last installed patch and reboot info for the localhost.

     Computer           : DC01
     PatchType          : Update
     LastInstalledPatch : KB4467695
     InstallDate        : 12/15/2018 12:00:00 AM
     LastRestartTime    : 12/15/2018 6:24:32 AM

     Computer           : DC02
     PatchType          : Update
     LastInstalledPatch : KB4467695
     InstallDate        : 12/20/2018 12:00:00 AM
     LastRestartTime    : 12/20/2018 12:26:11 AM

    .Example
     Get-RecentPatchInfo -computername DC01, DC02 | ft

     Computer    PatchType LastInstalledPatch InstallDate            LastRestartTime
     --------    --------- ------------------ -----------            ---------------
     DC01        Update    KB4467695          12/15/2018 12:00:00 AM 12/15/2018 6:24:32 AM
     DC02        Update    KB4467695          12/20/2018 12:00:00 AM 12/20/2018 12:26:11 AM


     .Notes
     Name       : Get-LocalPCGroupMember.ps1
     Author     : Mike Kanakos
     Version    : 1.0.1
     DateCreated: 2019-01-09
     DateUpdated: 2019-01-09

     .Link
     https://github.com/compwiz32/PowerShell

    #>

    [CmdletBinding()]
    Param(

        [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [string[]]
        $ComputerName = 'localhost'
    )

        Begin { }

        Process {
            Foreach($Computer in $ComputerName){

                    $Connection = Test-Connection $Computer -Quiet -Count 2

                    If(!$Connection) {
                    Write-Warning "Computer: $Computer appears to be offline!"
                    } #end if

                    Else {
                        $PCpatchinfo = Get-WmiObject Win32_Quickfixengineering -computer $Computer |
                            Select-Object HotfixID, Description, InstalledOn -last 1

                        $OSInfo = Get-WmiObject -Class win32_operatingsystem -computer $Computer
                        $LastBoot =$OSInfo.ConvertToDateTime($OSInfo.LastBootUpTime)

                        $Results = [pscustomobject]@{
                                        Computer            = $Computer
                                        PatchType           = $PCpatchinfo.Description
                                        LastInstalledPatch  = $PCpatchinfo.HotfixID
                                        InstallDate         = $PCpatchinfo.InstalledOn
                                        LastRestartTime     = $LastBoot
                                    } #end Results Array

                        $Results
                    } #end else

            }# Foreach
        }   #end process block

        end {}

    } #END OF FUNCTION