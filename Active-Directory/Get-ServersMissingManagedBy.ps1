function Get-ServersMissingManagedBy {
    <#
    .Synopsis
        Returns a list of enabled servers that do not have a value in the "ManagedBy" field in Active Directory

    .Description
        Returns a list of computer objects that meet the following conditions in Active Directory:
        - contain the word "server" in the operatingsystem field
        - enabled equals $true
        - have no value assigned for "ManagedBy"

    .Example
        Get-ServersMissingManagedBy
        Returns all servers not managed in Active Directory

    .Example
        Get-ServersMissingManagedBy | Select-Object Name, Description
        Returns all servers not managed in Active Directory and displays only the server name and server description

    .Notes
        NAME: Get-ServersMissingManagedBy
        AUTHOR: Mike Kanakos
        LASTEDIT: 2019-01-17

    .Link
        https://github.com/compwiz32/PowerShell

    #>

    $Params = @{
        Filter = "OperatingSystem -like '*server*'
                    -and Enabled -eq 'true'
                    -and description -notlike '*Failover cluster*'
                    -and description -notlike '*template*'
                    -and description -notlike '*inactive*'
                    "


        Properties = 'operatingsystem',
                     'description',
                     'managedby',
                     'memberof'
                    }

    Get-adcomputer @Params | Where-Object {($_.managedby -eq $null)}

} #End of Function