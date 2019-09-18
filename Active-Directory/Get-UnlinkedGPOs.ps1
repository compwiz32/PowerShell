function Get-UnlinkedGPOs {
    <#
    .Synopsis
    
    .Description

    .Parameter Server

    .Example

    .Notes
        NAME:        Get-UnlinkedGPOs
        AUTHOR:      Mike Kanakos
        VERSION:     1.0.0
        DateCreated: 2019-09-03
        DateUpdated: 2019-09-03

        v 1.0.0 - initial function creation

    .Link
        https://github.com/compwiz32/PowerShell

    #>

    [CmdletBinding()]
    Param(
        [alias('DC', 'DomainController', 'Computer', 'IPAddress')]
        [Parameter(
            AttributeValues)]
        [String]$server
        
    )

    $GPOXML = Get-GPOReport -all -ReportType xml -Server $server 

    $List = New-Object -TypeName XML


}







Function Get-AllGPO {
    Get-GPOReport -all -ReportType xml | % {
        ([xml]$_).gpo | Select-Object name, @{n = "SOMName"; e = { $_.LinksTo | % { $_.SOMName } } }, @{n = "SOMPath"; e = { $_.LinksTo | % { $_.SOMPath } } }
    }
}