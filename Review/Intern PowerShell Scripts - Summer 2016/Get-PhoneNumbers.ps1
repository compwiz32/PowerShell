<# 
  .Synopsis 
  Retrieves phone numbers for users in an OU

  .Description 
  Will pull and export the name, samaccountname, and phone numbers for employees from a specific OU. This
  was the first step in the 10-digit-dial fix project. It will export to a CSV file where the phone numbers
  could then be reformatted to the new standard in Excel.
  Note: to add the +1 to the 10-digit numbers, you have to format the Excel workbook as text, not general.
  This script was written for the 10 digit dial phone number update.

  .Example 
  Get-NewPhone
  Asks the user to input a filepath to save the CSV to and then returns name, samaccountname, fax, homephone, 
  mobile, mobilephone, officephone, telephonenumber, and othertelephone sorted alphabetically by name.

#>

#Using Active Directory
Import-Module ActiveDirectory

#Retrieves the information and exports to CSV
$Result = Get-Aduser –SearchBase “OU=Users,OU=Williston,OU=North_America,DC=LORD,DC=LOCAL”  -Filter * -Properties * | select name, samaccountname, mobile, mobilephone, officephone, telephonenumber, @{name="othertelephone";expression={$_.othertelephone -join ";"}} 

#Let user choose file path
Write-Host "Input file path to save output file.  Example: " -nonewline
Write-host "c:\temp\Array.csv" -foregroundcolor Magenta
Write-Host "Please save file with .csv file extension" -ForegroundColor Green
Write-Host ">>" -NoNewline
$FilePath = Read-Host 

#Export to CSV file
$Result | Sort-Object -Property name | Export-Csv $FilePath

#END