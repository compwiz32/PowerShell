<# 
  .Synopsis 
  Finds contractors that will expire in the next 2 weeks

  .Description 
  Will look in a specific OU and filter through all of the employees to find people that have account
  expiration dates within the next 14 days. It will display the contractors name, expiration date, email address,
  and manager so that the help desk will be able to contact the managers in time. Can easily change the date by
  adding days. 
  This script was written to pull a report for Stacy Swiger.

  .Example 
  Get-UsersExpiringSoon
  Asks the user to input a filepath to save the CSV to and then returns expiring users' names, emails, expiration dates, and managers

#>

#Using Active Directory
Import-Module ActiveDirectory

Get-ADUser -Filter * -SearchBase "OU=North_America,DC=LORD,DC=LOCAL" -properties AccountExpirationDate, manager | Where-Object{$_.AccountExpirationDate -gt (Get-Date) -and $_.AccountExpirationDate -lt ((get-date).AddDays(14)) -and $_.AccountExpirationDate -ne $null} | select-object name, samaccountname, manager, AccountExpirationDate | Sort-Object -Property AccountExpirationDate