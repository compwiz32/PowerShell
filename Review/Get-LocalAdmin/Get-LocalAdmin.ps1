Function Get-LocalAdmin 
{

<# 
  .Synopsis 
  This function lists the members of the local admins group
  
  .Description 
  This function lists the members of local admins group of the computer specified. If no computer is specified
  then it will query the local computer.

  .Example 
  Get-DiskDrive Server01
  Returns list of members from Server 01of the local capacity and free space in gigabytes. It also returns percent free, 
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

  .Example 
  "c:","d:","f:" | % { Get-DiskDrive $_ } 
  Returns information about c, d, and f drives on local computer.  

  .Example 
  Get-DiskDrive -d "c:","d:","f:" 
  Returns information about c, d, and f drives on local computer. Same command 
  as the previous example - but easier to read. But on my computer this is a  
  bit slower than the previous command (40 milliseconds). 

  .Parameter drive 
  The drive letter to query. Defaults to system drive (normally c:) 

  .Parameter computername 
  The name of the computer to query. Defaults to local machine.  

  .Notes 
  NAME: Get-LocalAdmin
  AUTHOR: Mike Kanakos
  CREATED: 2016-01-05
  LASTEDIT: 2016-06-22
#>


Param (<Parameter>, <Parameter>)

#Main part of function

<FUNCTION CODE THAT WRITES OBJECTS TO THE PIPELINE> 

[<scope:>]<name> [([type]$parameter1[,[type]$parameter2])]{


    param([type]$parameter1 [,[type]$parameter2])
    dynamicparam {<statement list>}


    begin {<statement list>}
    process {<statement list>}
    end {<statement list>}


}

#
# Get local admins group user list
# Created: 2016-01-05 - Mike Kanakos
# ----------------------------------

# Unused input - uncomment to prompt users for domain input
# $DomainName = Read-Host "Domain name"


# Prompt User for computer name
$ComputerName = Read-Host "Computer Name"

#List current group membership of local admin group
invoke-command {net localgroup administrators} -comp $computername