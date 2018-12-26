Function Get-LocalAdmin
{

<#s
  .Synopsis
  lists the members of the local admins group

  .Description
  lists the members of local admins group of the computer specified. If no computer is specified
  then it will query the local computer.

  .Example
  Get-LocalAdmin -ComputerName Server01
  Returns a list of local admins from from Server 01.

  .Notes
  NAME: Get-LocalAdmin
  AUTHOR: Mike Kanakos
  CREATED: 2016-01-05
  LASTEDIT: 2016-09-14

  -Change: turned script into a working function

#>

[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True,Position=0)]
   [string]$ComputerName
)


#List current group membership of local admin group
invoke-command {net localgroup administrators} -comp $computername

}
#end of function