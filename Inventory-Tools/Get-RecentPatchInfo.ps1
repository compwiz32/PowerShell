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


     .Example
     Get-RecentPatchInfo -computer berlin

     Description:


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