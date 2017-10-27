function Get-Privileges {
    <#
  .Synopsis
  This function will show the roles and privileges assigned  to a user

  .Description
  This function returns all the assigned roles as well as the inherited privileges granted to a user

  .Example
  Get-Privileges -username michael_kanakos
  Gets the privilege groups that Michael Kanakos has inherited from roles he is a member of.

  .Example
  Get-Privileges michael_kanakos
  Gets the privilege groups that Michael Kanakos has inherited from roles he is a member of. The -user switch is left off
  of the command but still is legal because -user is a required input. PowerShell assumes anything after the function name
  is the username you want to lookup

   .Notes
  NAME: Get-Privileges
  AUTHOR: Mike Kanakos
  LASTEDIT: 2017-10-26
#>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True, Position = 1)]
        [string]$username
    )

    Write-Host -ForegroundColor Green "Emurating groups.... Please wait..."
    Get-ADPrincipalGroupMembership ($username)  | ForEach-Object `
    {
        Get-ADPrincipalGroupMembership $_  | Get-ADGroup -prop description | Where-Object `
         { $_.name -like "*PRIV*" } | Select-Object name, description -ExpandProperty name

    } | Select-Object name, description | Sort-Object name

}
