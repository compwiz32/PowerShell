function Get-ServerOwner {

    <#
    .SYNOPSIS
        Returns the associated owner assigned for the specified server(s). Also included are the operating system name
        and the location where the object resides in Active Directory

    .DESCRIPTION
        Returns the associated owner assigned for the specified server(s). Also included are the operating system name
        and the location where the object resides in Active Directory

    .PARAMETER ComputerName
        The name of the computer you want to query. More than one computer can be entered by seperating each computername
        should be with a comma. 

    .EXAMPLE
        Get-ServerOwner SRV01

        Name        ManagedBy           OperatingSystem                   CanonicalName
        ----        ---------           ---------------                   -------------
        SRV01       Michael_Kanakos     Windows Server 2012 R2 Standard   NWTraders.MSFT/Computers/SRV01

    .EXAMPLE
        Get-ServerOwner SRV01 | Format-List

        Name            : SRV01
        ManagedBy       : Michael_Kanakos
        OperatingSystem : Windows Server 2012 R2 Standard
        CanonicalName   : NWTraders.MSFT/Computers/SRV01

        
    .EXAMPLE
        Get-ServerOwner Svr01, svr02, svr03 | Format-Table

        Name     ManagedBy           OperatingSystem                      CanonicalName
        ----     ---------           ---------------                      -------
        SRV01    Michael_Kanakos     Windows Server 2012 R2 Standard      NWTraders.MSFT/Computers/SRV01
        SRV02    Derek_Jeter         Windows Server 2012 R2 Standard      NWTraders.MSFT/Computers/SRV02
        SRV03    Tom_Brady           Windows Server 2012 R2 Standard      NWTraders.MSFT/Computers/SRV03


    .NOTES
        Name: Get-ServerOwner
        Author: Mike Kanakos
        Version: 1.0.0
        DateCreated: 2019-06-05
        DateUpdated: 2019-09-17

        v1.0.1 - fix broken code, add examples, add parameter, add foreach

    .LINK
        https://www.github.com/compwiz32/Powershell

#>

    [CmdletBinding()]
    Param(
        [alias('DnsHostName', '__SERVER', 'Computer', 'IPAddress')]
        [Parameter(Mandatory = $True, ValueFromPipeline = $true)]
        [string[]]$ComputerName
    )


    begin {

    } #end of begin

    process {
        
        foreach ($Node in $ComputerName) {
            
            $ParamHash = @{
                Identity   = $Node
                Properties = 'OperatingSystem',
                'ManagedBy',
                'CanonicalName',
                'Enabled'
            } #end ADUserParams

            $SelectParams = @{
                Property = 'Name',
                @{Name = 'ManagedBy'; Expression = { (Get-ADUser ($_.managedBy)).samaccountname } },
                'OperatingSystem',
                'CanonicalName'
            } #end SelectParams

            Get-ADComputer @ParamHash | Where-Object { $_.enabled -eq $true } | Select-Object @SelectParams
        
        } #end ForEach

    } #end Process block

    end {
    } #end End block

} #end of Function