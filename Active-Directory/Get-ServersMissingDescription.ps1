function Get-ServersMissingDescription {
<#
   .Synopsis
   Returns a list of servers that have a NULL (blank) value for the "Description" field in Active Directory

   .Description
   Returns a list of servers that have a NULL (blank) value for the "Description" field in Active Directory. 

   .Example

    Get-ServersMissingDescription
    
    CanonicalName     : NWTraders.MSFT/US/Servers/Server01
    Description       :
    DistinguishedName : CN=Server01,OU=Servers,OU=US,DC=NWTraders,DC=MSFT
    DNSHostName       : Server01.NWTraders.MSFT
    Enabled           : True
    ManagedBy         : Michael_Kanakos
    Name              : Server01
    ObjectClass       : computer
    ObjectGUID        : 303eb1cf-7c25-4fbb-afc2-ea8bd3249255
    OperatingSystem   : Windows Server 2016 Standard
    SamAccountName    : Server01$
    SID               : S-1-5-21-3400731359-678803062-3499617246-270424

   .Example
    Get-ServersMissingDescription | Select Name, Enabled, Description, CanonicalName | Sort Name | FT -AutoSize

    Returns a list of servers that are missing an entry in the description field and displays in a table format.
    In this example, specific fields have been selected.
    
    Name            Enabled      Description        CanonicalName
    ----            -------      -----------        -------------
    Server01        True                            NWTraders.MSFT/Servers/Server01
    Server02        True                            NWTraders.MSFT/Servers/Server02
    Server03        True                            NWTraders.MSFT/Servers/Server03
    

   .Notes
      NAME: Get-ServersMissingDescriptions
      AUTHOR: Mike Kanakos
      LASTEDIT: 2019-07-17
      version: 1.0.0

   .Link
        https://github.com/compwiz32/PowerShell
#>



$Params = @{
   Filter = "OperatingSystem -like '*server*'
               -and Enabled -eq 'true'
               "
          
   Properties = 'operatingsystem',
                'description',
                'managedby',
                'canonicalname'
   }
 

Get-ADComputer @Params | Where-Object description -eq $null

}

