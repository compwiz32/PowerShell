function Get-ServersNotInPatchGroups {

    <#
 .Synopsis
    Returns a list of servers not a member of any Lord patch groups

 .Description
    Returns a list of servers and their description that are assigned to a user

 .Example
    Get-ServersAssignedtoUser
    Returns a list of servers assigned to the current logged in user

 .Example
     Get-ServersAssignedtoUser -UserName Michael_Kanakos
     Returns a list of servers assigned to the value entered for the -User parameter


  .Notes
  NAME: Get-ServersNotInPatchGroups
  AUTHOR: Mike Kanakos
  LASTEDIT: 2018-01-11
#>

Get-adcomputer -filter 'OperatingSystem -like "*server*"' -prop operatingsystem, description, managedby, memberof | `
Where-Object {[String] $_.memberof -notlike  "*patch*" -and $_.enabled -eq $true }
}

