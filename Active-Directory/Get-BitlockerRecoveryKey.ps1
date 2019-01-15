Function Get-BitlockerRecoveryKey
{
<#
  .Synopsis
    Gets Bitlocker Recovery info stored in Active Directory.

  .Description
    This function retrieves the Bitlocker Recovery information stored in Active Directory.
    You must be a Domain Administrator or have the permissions delegated to your account in
    order to retrieve the information from A/D.

    *** BitLocker info will only exist if a PC is encrypted with BitLocker ***

  .Example
    Get-BitLockerRecoveryKey -computername  CRDNAB-183TXW1

    DistinguishedName      : CN=2015-12-10T12:36:09-05:00{5B99B6BF-2DFF-4F3C-B865-33FF1F370E91},CN=CRDNAB-183TXW1,OU=Computers,OU=XXX,OU=XXX,DC=XXX,DC=LOCAL
    msFVE-RecoveryPassword : 308759-XXXXXX-000000-XXXXXX-000000-XXXXXX-000000-621445
    Name                   : 2015-12-10T12:36:09-05:00{5B99B6BF-2DFF-4F3C-B865-33FF1F370E91}
    ObjectClass            : msFVE-RecoveryInformation
    ObjectGUID             : 01a93433-cbcb-48e2-bb4b-74f20d1fef6c

  .NOTES
    Name       : Get-BitLockerRecoveryKey.ps1
    Author     : Mike Kanakos
    Version    : 1.0.2
    DateCreated: 2016
    DateUpdated: 2019-01-15

  .LINK
    https://github.com/compwiz32/PowerShell

  #>


[CmdletBinding()]
  Param(
    [Parameter(Mandatory=$True,Position=1)]
    [string]$ComputerName
  )

# Get computer from Active Directory
$objComputer = Get-ADComputer $ComputerName

# Get all BitLocker Recovery Keys for that Computer
$BitLockerObjects = Get-ADObject -Filter {objectclass -eq 'msFVE-RecoveryInformation'} -SearchBase $objComputer.distinguishedName -Properties 'msFVE-RecoveryPassword'

# Output the result
$BitLockerObjects

} #end of function