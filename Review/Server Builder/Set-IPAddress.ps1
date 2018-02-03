$IpAddress = Read-Host "IP Address to bind to adaptor named 'Ethernet'"

New-NetIPAddress -interfaceAlias "Ethernet" $IpAddress -PrefixLength 22 -DefaultGateway "10.3.100.1"
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses ("10.3.100.234","10.3.100.235")