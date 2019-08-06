Function Remove-MKLocalGroupMember {
    <#
    .SYNOPSIS
        Removes an AD user or an AD group from a local user group on a client PC or server.

    .DESCRIPTION
        Removes an AD user or an AD group from a local user group on a client PC or server.

    .PARAMETER ComputerName
        Specifies a computer to add the users to. Multiple computers can be specificed with commas and single quotes
        (-Computer 'Server01','Server02')

    .PARAMETER Account
        The SamAccount name of an AD User or AD Group that will be added to a local group on the local PC.

    .PARAMETER Group
        The name of the LocalGroup on target computer that the account will be removed from. Valid choices are
        Administrators,'Remote Desktop Users','Remote Management Users', 'Users' and 'Event Log Readers'.
        If no choice is made, the default will be Administrators. Tab completion works for group names.

    .EXAMPLE
        Remove-MKLocalGroupMember -Computer Server01 -Account Michael_Kanakos -Group Administrators

        Description:
        Removes the account named Michael_Kanakos from the local Administrators group on the computer named Server01

    .EXAMPLE
        Remove-MKLocalGroupMember -Computer 'Server01','Server02' -Account HRManagers -Group 'Remote Desktop Users'

        Description:
        Removes the HRManagers group from the Remote Desktop Users group on computers named Server01 and Server02


    .NOTES
        Name       : Remove-MKLocalGroupMember.ps1
        Author     : Mike Kanakos
        Version    : 1.0.1
        DateCreated: 2019-07-23
        DateUpdated: 2019-08-06

        LASTEDIT:
        - - change output colors of variables returned to screen
        
    .LINK
        https://github.com/compwiz32/PowerShell

#>

    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $True, Position = 0)]
        [string]
        $Account,

        [Parameter(Position = 1)]
        [string[]]
        $ComputerName,

        [Parameter(Mandatory = $true, Position = 2)]
        [ValidateSet('Administrators', 'Remote Desktop Users', 'Remote Management Users', 'Users', 'Event Log Readers')]
        [String]
        $Group = 'Administrators'
    )

    begin {
        $Domain = $env:userdomain
    } #end begin

    process {
        Foreach ($Computer in $ComputerName) {
            try {
                $Connection = Test-Connection $Computer -Quiet -Count 2

                If (!($Connection)) {
                    Write-Warning "Computer: $Computer appears to be offline!"
                } #end if

                Else {
                    $ADSILookup = ([adsisearcher]"(samaccountname=$Account)").findone().properties['samaccountname']

                    Write-Host "Attempting to remove: " -NoNewline
                    Write-Host $ADSILookup -ForegroundColor White -BackgroundColor Blue -NoNewline
                    Write-Host " from " -NoNewline
                    Write-Host $group -ForegroundColor White -BackgroundColor Magenta -NoNewline
                    Write-Host " group on computer named " -NoNewline
                    Write-Host $computer -ForegroundColor White -BackgroundColor Red
                    $AcctReWrite = ([ADSI]"WinNT://$Domain/$ADSILookup").path

                    ([adsi]"WinNT://$Computer/$Group,group").Remove($AcctReWrite)
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
