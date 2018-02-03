# Gets time stamps for all computers in the domain that have NOT logged in since after specified date
# Created by Mike Kanakos 2016-20-04


# Create variables
#import-module activedirectory 
#$DaysInactive = 90 
#$time = (Get-Date).Adddays(-($DaysInactive))
 
# Get AD computers that are not disabled AND haven't logged into domain in 90+ days AND have the word "server" in OperingSystem name
#Get-ADComputer -Filter {(enabled -eq "true") -and (PasswordLastSet -lt $time) -and (OperatingSystem -like "*Server*")} -Properties PasswordLastSet, Description, OperatingSystem, CanonicalName |
 
# Output hostname and lastLogonTimestamp into CSV
#select-object Name, Description, OperatingSystem, @{Name="Password Last Set"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp)}}, CanonicalName | Sort-Object Name


$lastSetdate = [DateTime]::Now - [TimeSpan]::Parse("60")
Get-ADComputer -Filter {(PasswordLastSet -le $lastSetdate) -and (enabled -eq "true") -and (OperatingSystem -like "*Server*")} -Properties PasswordLastSet, Description, OperatingSystem -ResultSetSize $null | Sort Name | FT Name, Description, OperatingSystem, PasswordLastSet 