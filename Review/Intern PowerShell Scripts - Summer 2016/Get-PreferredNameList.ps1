<# 
  .Synopsis 
  Finds users in North America OU that have a preferred name that is different than their legal name.

  .Description 
  Will look in a specific OU and filter through all of the employees to find people that have parentheses
  in their display name because in our system, the preferred name is shown in parentheses after the legal
  name. This also has a filter on it that will leave out the disabled users.
  Note: There are some people that will show up that shouldn't be a part of this. For example, there are
  people that have their location in parentheses after their name or their job description or a number.
  Abbott, Timothy B (Dayton)
  Abbott, Timothy P (Saegertown)
  Ambrose, Alexander R (Contractor-Erie)
  Bremer, Steven T (2010-07-19)
  ...
  This script was written for the preferred display name update.

  .Example 
  Get-NewPhone
  Asks the user to input a filepath to save the CSV to and then returns their names sorted alphabetically

#>

#Using Active Directory
Import-Module ActiveDirectory

#Get the list of users with different preferred names
$Result = Get-ADUser -SearchBase "OU=North_America,DC=LORD,DC=LOCAL" -Filter {displayname -like "*(*" -and enabled -eq "true"} -Properties * | select name 

#Let user choose file path
Write-Host "Input file path to save output file.  Example: " -nonewline
Write-host "c:\temp\Array.csv" -foregroundcolor Magenta
Write-Host "Please save file with .csv file extension" -ForegroundColor Green
Write-Host ">>" -NoNewline
$FilePath = Read-Host 

#Export to CSV file
$Result | Sort-Object -Property name | Export-Csv $FilePath

#End