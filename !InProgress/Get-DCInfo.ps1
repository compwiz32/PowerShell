
Param($computer)



# Server FQDN
$FQDN=([System.Net.Dns]::GetHostByName(($computer))).Hostname



# Accounts in Local admins

# hostname less than 15 characters

# IP Info

# Domain Joined?

# PartOfDomain (boolean Property)
$IsDc = (Get-WmiObject -ComputerName $computer -Class Win32_ComputerSystem).PartOfDomain

# Roles Installed



# DNS server configs

## forwarder info
## any non AD integrated zones?

# cert info

# domain fsmo folders

# is global catalog?




