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
        LASTEDIT: 2019-01-15

    .Link
        https://github.com/compwiz32/PowerShell

    #>


    Get-adcomputer -filter 'OperatingSystem -like "*server*"'  -prop operatingsystem, description, managedby, memberof |
    Where-Object { ($_.enabled -eq $true) -and ($_.description -notlike '*Failover cluster*') -and `
    ($_.description -notlike '*template*') -and ($_.description -notlike '*inactive*') -and ($_.managedby -eq $null) }

} #End of Function