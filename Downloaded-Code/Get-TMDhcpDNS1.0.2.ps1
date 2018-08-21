Function Get-TMDhcpDNS {
<#
.SYNOPSIS
    The Get-TMDhcpDNS advanced function determines the DNS Servers being used by a DHCP Scope.

.DESCRIPTION
    The Get-TMDhcpDNS advanced function determines the DNS Servers being used by a DHCP Scope whether the DNS Servers are assigned by the Scope Options, or Server Options.

.PARAMETER ComputerName
    This mandatory parameter is the DHCP Server(s). This function can be invoked against a single DHCP server, or a list of comma-seperated DHCP servers.

.EXAMPLE
    Get-TMDhcpDNS -ComputerName 'dhcpsrv1.mydomain.com' | Format-Table -AutoSize
   
    This example will return the DHCP Scopes on the dhcpsrv1.mydomain.com DHCP Server. It will include the Name (DHCP Server Name), ScopeName, ScopeId, the DNS IPs, and whether the DNS is being assigned at the Scope or Server level. It will format the data in an autosized table.

.NOTES
    NAME: Get-TMDhcpDNS
    AUTHOR: Tommy Maynard
    WEB: http://tommymaynard.com
    VERSION: 1.0.1
    LASTEDIT: 4/29/2015
        1.0.1:
            Added abilty to run against multiple DHCP Servers: Moved first try-catch to Process block (from Begin block), modified variables names, etc.
        1.0.2:
            Prevented System.Object[] for DNS when exporting to CSV.
            Added embedded try-catch (in 2nd try-catch) when getting the DNS from the server (not from the scope). The catch portion should, in theory, never run.
#>
    [CmdletBinding()]
    Param (
        [Parameter(Position = 0,Mandatory = $true,ValueFromPipeline = $true)]
        [string[]]$ComputerName
    )

    Begin {
    } # End Begin

    Process {
        Foreach ($Computer in $ComputerName) {
            try {
                $Scopes = Get-DhcpServerv4Scope -ComputerName $Computer -ErrorAction Stop
                $Continue = $true
            } catch [Microsoft.Management.Infrastructure.CimException] {
                Write-Warning -Message "Cannot reach DHCP Server (ComputerName: $Computer)."
                $Continue = $false
            } catch {
                Write-Warning -Message "Unknown Error."
                $Continue = $false
            } # End try-catch.

            If ($Continue) {
                Foreach ($Scope in $Scopes){
                    Clear-Variable DNS,ScopeDNS -ErrorAction SilentlyContinue
                    try {
                        $DNS = (Get-DhcpServerv4OptionValue -ComputerName $Computer -ScopeID $Scope.ScopeId -OptionID 6 -ErrorAction Stop | Select-Object -ExpandProperty Value) -join ','
                        $ScopeOrServerDNS = 'Scope'
                    } catch {
                        try {
                            $DNS = (Get-DhcpServerv4OptionValue -ComputerName $Computer -OptionId 6 | Select-Object -ExpandProperty Value) -join ','
                            $ScopeOrServerDNS = 'Server'
                        } catch {
                            $DNS = 'Unknown'
                            $ScopeOrServerDNS = 'Unknown'
                        }
                    } # End try-catch.

                    $Object = [PSCustomObject]@{
                        Name = $Computer
                        ScopeName = $Scope.Name
                        ScopeID = $Scope.ScopeId
                        DNS = $DNS
                        ScopeOrServerDNS = $ScopeOrServerDNS
                    }
                    Write-Output -Verbose $Object
                } # End Foreach 2.
            } # End If.
        } # End Foreach 1.
    } # End Process.
}