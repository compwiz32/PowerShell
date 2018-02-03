Function Get-WindowsFeaturesInstalled
{

<# 
  .Synopsis 
  This function returns a list of the installed Windows Features 

  .Description 
  This function returns a list of the installed Windows Features

  .Example 
  Get-WindowsFeaturesInstalled
  Returns list of installed features for the local computer

  .Example 
  Get-WindowsFeaturesInstalled SRVWIN1024
  Returns list of installed features for server SRVWIN1024

  .Example 
  Get-DiskDrive -drive e: -computer berlin, munich 
  Returns capacity and free space in gigabytes of the e: drive. It also returns 
  percent free, and the drive letter and drive label of the system drive on two  
  remote machines named berlin and munich. 

  .Parameter computername 
  The name of the computer to query. Defaults to local machine.  

  .Notes 
  NAME: Get-WindowsFeatures 
  AUTHOR: ed wilson, msft 
  LASTEDIT: 06/02/2011 16:12:08 
  KEYWORDS: 
  HSG: HSG-06-26-2011 
  .Link 
  Http://www.ScriptingGuys.com/blog
#Requires -Version 2.0 
#>

[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True,Position=1)]
   [string]$computerName
)

#Main part of function

Get-WindowsFeature -ComputerName $computername | Where-Object Installed | Format-Table Name

}