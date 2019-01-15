function Get-ServersMissingManager {
<#
.Synopsis
Returns a list of enabled servers that do not have a value in the "ManagedBy" field in Active Directory

.Description
Returns a list of computer objects that meet the following conditions in Active Directory:
- contain the word "server" in the operatingsystem field
- enabled equals $true
- have no value assigned for "ManagedBy"

.Example
Get-ServersMissingManager
Returns all servers not managed in Active Directory

.Example
Get-ServersMissingManager | Select-Object Name, Description
Returns all servers not managed in Active Directory and displays only the server name and server description

.Notes
NAME: Get-ServersMissingManager
AUTHOR: Mike Kanakos
LASTEDIT: 2019-01-15
#>

[CmdletBinding()]

Get-adcomputer -filter 'OperatingSystem -like "*server*" '  -prop operatingsystem, description, managedby, memberof |
Where-Object {($_.enabled -eq $true) -and ($_.managedby -eq $null) }

} #End of Function