Function Get-MKLocalGroupMember {
<#
.Synopsis
    Retrieves the local group membership for a particular group.

.Description
    Retrieves the local group membership for a particular group. The computer and
    group can be specified. If no computername is specified then the local machine will be queried.
    If no group  is specified then the Administrators group will be queried.

.Parameter ComputerName
    Name of the Computer to get group members. The default is "localhost" if not entered.

.Parameter GroupName
    Name of the GroupName to get members from. The default is "Administrators" if not entered.

    Common local groups are Administrators, Users, "Remote Desktop Users", "Event Log Readers",
    "Backup Oeprators" and Guests. This is not an exhaustive list and the local groups will
    vary by O/S.

    !!! Remember groups with spaces in the name need quotes !!!

.Example
    Get-MKLocalGroupMember

    Returns the members of the Administrators group from the localhost

.Example
    Get-MKLocalGroupMember -ComputerName SERVER01 -GroupName "Remote Desktop Users"

    Returns the members of the group "Remote Desktop Users" from computer named SERVER01

.Example
    Get-MKLocalGroupMember -ComputerName SERVER01,SERVER02 -GroupName "Administrators"

    Returns the members of the group "Administrators" on the computers SERVER01 and SERVER02

.OUTPUTS
    PSCustomObject

.INPUTS
    Array

.Link
    https://github.com/compwiz32/PowerShell/

.Notes
        Name       : Get-MKLocalGroupMember.ps1
        Author     : Mike Kanakos
        Credit     : Francois-Xavier Cat / www.LazyWinAdmin.com (script original source)

        Version    : v1.0.3
        DateCreated: Unknown
        DateUpdated: 2019-06-28

        LASTEDIT:
        - rename cmdlet name from "Get-LocalGroupMember" to "Get-MKLocalGroupMember"
        - rename file name from "Get-LocalGroupMember.ps1" to "Get-MKLocalGroupMember"
        - fix examples to match new cmdlet name
        - the renames are to avoid name collisons with built in cmdlets


#>


 [Cmdletbinding()]

 PARAM (
        [alias('DnsHostName','__SERVER','Computer','IPAddress')]
  [Parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true)]
  [string[]]$ComputerName = $env:COMPUTERNAME,

  [string]$GroupName = "Administrators"

  )
    BEGIN{
    }#BEGIN BLOCK

    PROCESS{
        foreach ($Computer in $ComputerName){
            TRY{
                $Everything_is_OK = $true

                # Testing the connection
                Write-Verbose -Message "$Computer - Testing connection..."
                Test-Connection -ComputerName $Computer -Count 1 -ErrorAction Stop |Out-Null

                # Get the members for the group and computer specified
                Write-Verbose -Message "$Computer - Querying..."
             $Group = [ADSI]"WinNT://$Computer/$GroupName,group"
             $Members = @($group.psbase.Invoke("Members"))
            }#TRY
            CATCH{
                $Everything_is_OK = $false
                Write-Warning -Message "Something went wrong on $Computer"
                Write-Verbose -Message "Error on $Computer"
                }#Catch

            IF($Everything_is_OK){
             # Format the Output
                Write-Verbose -Message "$Computer - Formatting Data"
             $members | ForEach-Object {
              $name = $_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)
              $class = $_.GetType().InvokeMember("Class", 'GetProperty', $null, $_, $null)
              $path = $_.GetType().InvokeMember("ADsPath", 'GetProperty', $null, $_, $null)

              # Find out if this is a local or domain object
              if ($path -like "*/$Computer/*"){
               $Type = "Local"
               }
              else {$Type = "Domain"
              }

              $Details = "" | Select-Object ComputerName,Type,Class,Account,Group
              $Details.ComputerName = $Computer
              $Details.Account = $name
              $Details.Class = $class
              $Details.Group = $GroupName
              # $details.Path = $path
              $details.Type = $type

              # Show the Output
                    $Details
             }
            }#IF(Everything_is_OK)
        }#Foreach
    }#PROCESS BLOCK

    END{Write-Verbose -Message "Script Done"}#END BLOCK
}#Function Get-LocalPCGroupMember