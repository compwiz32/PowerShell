function Get-ServersAssignedToUser {
    <#
 .Synopsis
    Returns a list of servers assigned to a user

 .Description
    Returns a list of servers and their description that are assigned to a user

 .Example
    Get-ServersAssignedtoUser
    Returns a list of servers assigned to the current logged in user

 .Example
     Get-ServersAssignedtoUser -UserName Michael_Kanakos
     Returns a list of servers assigned to the value entered for the -User parameter

 .Parameter UserName
    The user to query. Should be in the form of firstname_lastname


  .Notes
  NAME: Get-ServersAssignedtoUser
  AUTHOR: Mike Kanakos
  LASTEDIT: 2018-01-09
#>


    param(
        [string]$username = $env:USERNAME

    )
    Get-ADComputer -filter "ManagedBy -eq '$username'" -Properties managedby, Description


}