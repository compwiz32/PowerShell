## Get-inactiveUsers
## MK - 2017-09-07 

Search-ADAccount -AccountInactive -TimeSpan 90.00:00:00 | Where {$_.enabled -eq $true} | ForEach-Object {Get-ADUser $_.ObjectGuid} | select name, givenname, surname