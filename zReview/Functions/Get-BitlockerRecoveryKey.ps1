Function Get-BitlockerRecoveryKey
{

<#
.Synopsis 
  This function retreives the Bitlocker Recovery info stored in Active Directory. You must be a Domain Admin
  or have the permissions delegated to your account in order to retreive the information from A/D

  .Description 
  This function retreives the Bitlocker Recovery info stored in Active Directory.

  .Example 
  Get-BitlockerRecoveryKey
  Returns the bitlocker info PC for the you are running command from.

  .Example 
  Get-DiskDrive -Computername RemotePC
  Returns the bitlocker info PC for the remote machine named RemotePC. 
#>


[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True,Position=1)]
   [string]$computerName
)

#Get computer from Active Directory
$objComputer = Get-ADComputer $computerName

# Get DN for AD Object
# $DN = (Get-ADComputer $objComputer).distinguishedName

# Get all BitLocker Recovery Keys for that Computer
# $BitLockerObjects = Get-ADObject -Filter {objectclass -eq 'msFVE-RecoveryInformation'} -SearchBase $DN -Properties 'msFVE-RecoveryPassword'

# Output the results!
# $BitLockerObjects

# Find the AD object which match the computername and is of the class "msFVE-RecoveryInformation"
$objADObject = get-adobject -Filter * | Where-Object {$_.DistinguishedName -match $objComputer.Name -and $_.ObjectClass -eq 'msFVE-RecoveryInformation'}
 
# Filter the result so you'll get only the recovery key
(($objADObject.DistinguishedName.Split(&quot;,&quot;)[0]).split(";{";)[1]).Substring(0,$trimming.Length-1)

}