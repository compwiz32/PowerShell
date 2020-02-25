
Param($computer)



# Server FQDN
$ComputerInfo = Get-CimInstance Win32_ComputerSystem |select *
$FQDN=([System.Net.Dns]::GetHostByName(($computer))).Hostname
$FQDN


# Accounts in Local admins

# hostname less than 15 characters

# IP Info

# Domain Joined?

# PartOfDomain (boolean Property)
$IsDc = (Get-WmiObject -ComputerName $computer -Class Win32_ComputerSystem).PartOfDomain

$osInfo = Get-CimInstance -ClassName Win32_OperatingSystem
$osInfo.ProductType

# Roles Installed



# DNS server configs

## forwarder info
## any non AD integrated zones?

# cert info

# domain fsmo folders

# is global catalog?




