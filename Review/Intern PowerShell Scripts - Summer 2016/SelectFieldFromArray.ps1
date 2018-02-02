<# 
  .Synopsis 
  Select one field out of an array that would otherwise give error: "Microsoft.ActiveDirectory.Management.ADPropertyValueCollection"

  .Description 
  Search for all users in a specific OU and export their name and all 8 associated phone numbers to 
  a CSV Excel file. Previously we had trouble exporting the "othertelephone" field because it is saved as an array and 
  would give this error: "Microsoft.ActiveDirectory.Management.ADPropertyValueCollection", but this will export the phone 
  number in the standard form. The relevant part of this script is the syntax in line 24.
  This script was written for the 10 digit dial phone number update.

  .Example 
  SelectFieldFromArray.ps1 
  Asks the user to input a filepath to save the CSV to and then returns name, fax, homephone, mobile, mobilephone, 
  officephone, telephonenumber, and othertelephone sorted alphabetically by name.

#>

#Using Active Directory
Import-Module ActiveDirectory

$Result = Get-ADUser -SearchBase "OU=Users,OU=Cary,OU=North_America,DC=LORD,DC=LOCAL" -Filter * -Properties * | select name, fax, homephone, mobile, mobilephone, officephone, telephonenumber, 

#Select the "othertelephone" number out of an arry
@{name="othertelephone";expression={$_.othertelephone -join ";"}}

#Let user choose file path
Write-Host "Input file path to save output file.  Example: " -nonewline
Write-host "c:\temp\Array.csv" -foregroundcolor Magenta
Write-Host "Please save file with .csv file extension" -ForegroundColor Green
Write-Host ">>" -NoNewline
$FilePath = Read-Host 

#Export to CSV file
$Result | Sort-Object -Property name | Export-Csv $FilePath

#END