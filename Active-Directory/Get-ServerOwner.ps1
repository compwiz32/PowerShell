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
    SRV01                Michael_Kanakos     Windows Server 2012 R2 Standard        True
    SRV02                Derek_Jeter         Windows Server 2012 R2 Standard        True
    SRV01                Tom_Brady           Windows Server 2012 R2 Standard        True


.NOTES
    Name: Get-ServerOwner
    Author: Mike Kanakos
    Version: 1.0.0
    DateCreated: 2019-06-05
    DateUpdated: 2019-06-05

    v1.0.0 - initial script build

.LINK
    https://www.github.com/compwiz32/Powershell

#>

    [CmdletBinding()]
    param(

    )

    begin {

    }

    process {
        $ADUserParams = @{
            Filter = {operatingsystem -like '*server*'}
            Properties =    'OperatingSystem',
                            'ManagedBy',
                            'CanonicalName',
                            'Enabled'
            }

        $SelectParams = @{
            Property =      'Name',
                            @{Name='ManagedBy';Expression={(Get-ADUser ($_.managedBy)).samaccountname}},
                            'OperatingSystem',
                            'Enabled'
            }


        get-adcomputer @ADUserParams  | Where-Object {$_.enabled -eq $true} | Select-Object @SelectParams
    }

    end {
    }
}








<# get-adcomputer -filter "operatingsystem -like '*server*'" -prop operatingsystem, managedby, enabled | Where-Object {$_.enabled
    -eq $true} |  select name, @{Name='ManagedBy';Expression={(Get-ADUser ($_.managedBy)).samaccountname}}, operatingsystem, enabled
    #>