Function Get-LordUserInfo {

    <#
  .Synopsis
  Returns a customized view of a Lord Employee's Active Directory Account Info

  .Description
  Returns a customized view of a Lord Employee's Active Directory Account Info. The lookup is a list of the most common fields of an employee's
  account that would be useful when an employee calls in for help.

  .Example
  Get-LordUserInfo michael_kanakos
  Returns capacity and free space in gigabytes. It also returns percent free,
  and the drive letter and drive label of the system drive on the local machine.

  .Example
  Get-DiskDrive -drive e: -computer berlin
  Returns capacity and free space in gigabytes of the e: drive. It also returns
  percent free, and the drive letter and drive label of the system drive on the
  remote machine named berlin.

  .Example
  Get-DiskDrive -drive e: -computer berlin, munich
  Returns capacity and free space in gigabytes of the e: drive. It also returns
  percent free, and the drive letter and drive label of the system drive on two
  remote machines named berlin and munich.

  .Example
  Get-DiskDrive -drive c:, e: -computer berlin, munich
  Returns capacity and free space in gigabytes of the C: and e: drive. It also
  returns percent free, and the drive letter and drive label of the system drive
  on two remote machines named berlin and munich.

  .Parameter Username
  The drive letter to query. Defaults to system drive (normally c:)

  .Parameter computername
  The name of the computer to query. Defaults to local machine.

  .Notes
  NAME: Get-LordUserInfo
  AUTHOR: Mike Kanakos
  LASTEDIT: 2018-02-01

#Requires -Version 3.0
#>

    [CmdletBinding()]
    param
    (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True]
            )
             [Microsoft.ActiveDirectory.Management.ADUser]$Employee
    )

    $Array = Get-ADUser $Employee -Properties *

    Write-Host ""
    Write-Host "Employee Information"
    Write-Host "------------------------------------"
    Write-host "First Name:" $Array.GivenName
    Write-host "Last name:" $Array.Surname



        } #END OF FUNCTION
