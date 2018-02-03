# Clean-DNSServerRootHints.ps1
# Created: 2017-12-12
# Author: Mike Kanakos

$2012DCs = get-content C:\Scripts\Input\2012DCs.txt

foreach ($DC in $2012DC) {
    Get-DnsServerRootHint -ComputerName $DC | Remove-DnsServerRootHint -ComputerName $DC -Force

}