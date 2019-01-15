Function Add-LocalPCGroupMember {
<#
    .SYNOPSIS
        Adds an AD user or an AD group to local user group on a client PC or server.

    .DESCRIPTION
        Adds an AD user or an AD group to a local user group on a client PC or server. This cmdlet does not create new
        Local PC groups, it only adds users or groups to existing Local PC groups already created.

    .PARAMETER ComputerName
        Specifies a computer to add the users to. Multiple computers can be specificed with commas and single quotes
        (-Computer 'Server01','Server02')

    .PARAMETER Account
        The SamAccount name of an AD User or AD Group that will be added to a local group on the local PC.

    .PARAMETER Group
        The name of the LocalGroup on target computer that the account will be added to. Valid choices are
        Administrators,'Remote Desktop Users','Remote Management Users', 'Users' and 'Event Log Readers'.
        If no choice is made, the default will be Administrators

    .EXAMPLE
        Add-LocalPCGroupMember -Computer Server01 -Account Michael_Kanakos -Group Administrators

        Description:
        Will add the account named Michael_Kanakos to the local Administrators group on the computer named Server01

    .EXAMPLE
        Add-LocalPCGroupMember -Computer 'Server01','Server02' -Account HRManagers -Group 'Remote Desktop Users'

        Description:
        Will add the HRManagers group as a member of Remote Desktop Users group on computers named Server01 and Server02


    .NOTES
        Name       : Add-LocalPCGroupMember.ps1
        Author     : Mike Kanakos
        Version    : 1.0.9
        DateCreated: 2018-12-03
        DateUpdated: 2019-01-15

    .LINK
        https://github.com/compwiz32/PowerShell

#>

[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [Parameter(Mandatory=$True,Position=0)]
    [string]
    $Account,

    [Parameter(Mandatory=$true,Position=1)]
    [string[]]
    $ComputerName,

    [Parameter(Mandatory=$true,Position=2)]
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
