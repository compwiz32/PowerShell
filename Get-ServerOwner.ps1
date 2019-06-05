function Get-ServerOwner {

<#
.SYNOPSIS
    Returns a list of servers and the associated owner assigned in Active Directory

.DESCRIPTION
    Returns a list of servers and the associated owner assigned in Active Directory. The list of servers is determined
    by querying the operatingsystem field and searching for *server*. Also, disabled computer objects are filtered out
    of the view.


.EXAMPLE
    Get-ServerOwner

    Name                 ManagedBy           OperatingSystem                        Enabled
    ----                 ---------           ---------------                        -------
    ACO-DC-WP01          Michael_Kanakos     Windows Server 2012 R2 Standard        True
    ACO-FS-WP01          George_Zhang        Windows Server 2012 R2 Standard        True
    ACO-PRINT-WP01       Steve_Aul           Windows Server 2016 Standard           True
    ACO-SCCMDP-WP01      James_Cox           Windows Server 2012 R2 Standard        True
    ACO-SLDWKS-WP01      Dale_Hull           Windows Server 2012 R2 Standard        True

.EXAMPLE
    Another example of how to use this cmdlet
#>

    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory=true)]
        [string]
        Param1
    )

    begin {
    }

    process {

    }

    end {
    }
}





get-adcomputer -filter "operatingsystem -like '*server*'" -prop operatingsystem, managedby, enabled | Where-Object {$_.enabled
    -eq $true} |  select name, @{Name='ManagedBy';Expression={(Get-ADUser ($_.managedBy)).samaccountname}}, operatingsystem, enabled