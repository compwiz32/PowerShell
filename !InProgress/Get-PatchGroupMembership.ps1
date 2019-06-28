Function Get-PatchGroupMembership {

    <#
 .Synopsis
  Returns the patch group membership for the computer from Active Directory

 .Description
  Returns the patch group membership for the computer from Active Directory.

 .Example
  Get-PatchGroupmembership CRD-FS-WP01

  Returns capacity and free space in gigabytes. It also returns percent free,
  and the drive letter and drive label of the system drive on the local machine.

 .Example
  Get-PatchGroupmembership CRD-FS-WP01, SGT-PRT-WP01


 .Parameter computername
  The name of the computer to query. Defaults to local machine.

 .Notes
  NAME: Example-
  AUTHOR: ed wilson, msft
  LASTEDIT: 06/02/2011 16:12:08
  .Link
  Http://www.ScriptingGuys.com/blog
#Requires -Version 2.0
#>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True, Position = 1)]
        [string[]]$ComputerName
        )

    #Main part of function

    ForEach ($computer in $ComputerName){
        $results = Get-ADPrincipalGroupMembership (Get-ADComputer $computer).distinguishedname | get-adgroup -Property description |
            Select-Object Name, Description | Where-Object { $_.name -like "patch*" } | Sort-Object name

        <#$results = Get-ADComputer $lookup.name -Properties memberof | get-adgroup $lookup.name -Property description |
            Select-Object Name, Description | Where-Object { $_.name -like "patch*" } | Sort-Object name
        #>

        if (!$Results){
            Write-Warning "$computername is not in any patch groups"
        }
            
        else {
            $results
        }    
    }
    
    

} #END OF FUNCTION