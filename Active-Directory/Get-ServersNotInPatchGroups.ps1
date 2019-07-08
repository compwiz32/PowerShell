function Get-ServersNotInPatchGroups {
<#
   .Synopsis
      Returns a list of servers that are not a member of any groups that contain the word "Patch"

   .Description
      Returns a list of servers that are not a member of any groups that contain the word "Patch"

   .Example
      Get-ServersNotInPatchGroups
      Returns a list of servers that are not a member of any groups that contain the word "Patch" and are also
      enabled and do not have the words "Failover cluster", "cluster virtual", template or inactive in the description
      field.

      Example Output:

      Get-ServersNotInPatchGroups

      Description       : Domain Controller
      DistinguishedName : CN=DC01,OU=Domain Controllers,DC=NWTraders,DC=MSFT
      DNSHostName       : DC01.NWTraders.MSFT
      Enabled           : True
      ManagedBy         : CN=Kanakos\, Michael,OU=Users,DC=NWTraders,DC=MSFT
      MemberOf          : {}
      Name              : DC01
      ObjectClass       : computer
      ObjectGUID        : ba5ef2a8-2118-421c-a7e4-a826bb5f4866
      OperatingSystem   : Windows Server 2012 R2 Datacenter
      SamAccountName    : DC01$
      SID               : S-1-5-21-3400731359-123456789-3499617246-289124
      UserPrincipalName :

   .Example
      Get-ServersNotInPatchGroups | select-object name, description, managedby, memberof | sort-object name | format-table -AutoSize

      Returns a list of servers that are not a member of any groups that contain the word "Patch" and are also
      enabled and do not have the words "Failover cluster", "cluster virtual", template or inactive in the description
      field. In this example, specific fields have been selected and output is a table format.


name            description              managedby                                              memberof
----            -----------              ---------                                              --------
DC01            Domain Controller        CN=Kanakos\, Michael,OU=Users,DC=NWTraders,DC=MSFT     {}

   .Notes
      NAME: Get-ServersNotInPatchGroups
      AUTHOR: Mike Kanakos
      LASTEDIT: 2019-02-05
      version: 1.4.3

   .Link
        https://github.com/compwiz32/PowerShell
#>

$Params = @{
   Filter = "OperatingSystem -like '*server*'
               -and Enabled -eq 'true'
               -and description -notlike '*Failover cluster*'
               -and description -notlike '*cluster virtual*'
               -and description -notlike '*template*'
               -and description -notlike '*inactive*'
               -and canonicalname -notlike '*inactive*'
               "


   Properties = 'operatingsystem',
                'description',
                'managedby',
                'memberof'
   }

Get-adcomputer @params | Where-Object {[String] $_.memberof -notlike  "*patch*" -and $_.enabled -eq $true }
}

