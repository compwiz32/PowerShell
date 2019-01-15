Function Get-LocalPCGroupMember {
<#
.SYNOPSIS
Retrieves the local group membership for a particular group.

.DESCRIPTION
Retrieves the local group membership for a particular group. The computer and group can be specified.
If no computername is specified then the local machine will be queried. If no group  is specified
then the Administrators group will be queried.

.PARAMETER ComputerName
Specifies a computer to get group members from. Multiple computers can be specificed with commas and single quotes
(-Computer 'Server01','Server02'). The default is "localhost" if not entered.

.PARAMETER Group
The name of the LocalGroup on target computer that will queried. Valid choices are
Administrators,'Remote Desktop Users','Remote Management Users', 'Users' and 'Event Log Readers'.
If no choice is made, the default will be Administrators

.EXAMPLE
Get-LocalPCGroupMember -Computer Server01

Description:
Will retrieve the members of Administrators group on computer named Server01. The administrators group is
retreived since no group was specified.


.EXAMPLE
Get-LocalPCGroupMember -Computer Server01 -Group 'Remote Management Users'

Description:
Will retrieve the members of Remote Management Users group on computer named Server01.

.EXAMPLE
Get-LocalPCGroupMember -Computer 'Server01','Server02' -Group 'Remote Desktop Users'

Description:
Will retrieve the members of 'Remote Desktop Users' from computers named Server01 and Server02.


.NOTES
Name       : Get-LocalPCGroupMember.ps1
Author     : Mike Kanakos
Version    : 1.0.1
DateCreated: 2019-01-09
DateUpdated:

.LINK
https://https://github.com/compwiz32/PowerShell


#>

[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [Parameter(Mandatory=$true,Position=0)]
    [string[]]
    $ComputerName = . ,

    [Parameter(Mandatory=$true,Position=1)]
    [ValidateSet('Administrators','Remote Desktop Users','Remote Management Users', 'Users', 'Event Log Readers')]
    [String]
    $Group = 'Administrators'
    )

        begin{
            $Domain = $env:userdomain
           } #end begin

        process{
            Foreach($Computer in $ComputerName){
              try{
                  $Connection = Test-Connection $Computer -Quiet -Count 4

                  If(!($Connection)) {
                    Write-Warning "Computer: $Computer appears to be offline!"
                    } #end if

                  Else {
                      $ADSILookup = ([adsisearcher]"(samaccountname=$Account)").findone().properties['samaccountname']

                      Write-Host "Attempting to add $ADSILookup to $group on $computer"
                      $AcctReWrite = ([ADSI]"WinNT://$Domain/$ADSILookup").path

                      ([adsi]"WinNT://$Computer/$Group,group").add($AcctReWrite)
                      Write-Host "Success!" -foregroundcolor Green

                    } #end else
                } # end try

              catch {
                  $ADSILookup = $null
                } #end catch

                if (!$ADSILookup) {
                    Write-Warning "User `'$Account`' not found in AD, please input correct SAM Account"
                } #end if
            } #end Foreach
        }# end Process
    }#end function
