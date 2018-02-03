#
# Get-IPInfo
# 
# Script will return the current IP info for a given server
# Created: 2016-01-12 - Mike Kanakos
# ----------------------------------
#
# Prompt User for computer name
$ComputerName = Read-Host "Computer Name"

get-wmiobject win32_networkadapterconfiguration -Computer $Computername -filter "IPEnabled='True'" | Select DNSHostname,MACAddress,IPAddress,IPSubnet,DefaultIPGateway,DNSServerSearchOrder