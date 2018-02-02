<# 
  .Synopsis 
  Shows last logon date and password last set date to determine if a computer is being used

  .Description 
  This script runs off of a CSV with a column for the computer name.
  Sorts through an array of computer names and exports the computer name, last log on date, and last password
  reset date into an Excel document. This was useful for inventory to determine if a computer that we can't ping
  has been used recently. Some computers haven't been accessed since 2010, so Keith was able to determine those
  computers should not be included on the inventory list.
  This script was written to pull a report for Keith Hawkins during inventory.

  .Example 
  ProblemComputers
  Asks the user to input a filepath to save the CSV to and then returns computers name, lastlogondate, and passwordlastset

#>

#Using Active Directory
Import-Module ActiveDirectory

#Import all of the information from the Excel document
$Computers = Import-CSV C:\Users\Melissa_Green\Documents\"ProblemComputers.csv"

#Loop through each user in the Excel document and replace their original phone numbers with the ones from the file
$Information = ForEach ($Computer in $Computers)
{
Get-ADComputer -Identity $Computer.Name -Properties * | Select CN, lastLogonDate, PasswordLastSet | Sort-Object -Property CN
}

#Let user choose file path
Write-Host "Input file path to save output file.  Example: " -nonewline
Write-host "c:\temp\Array.csv" -foregroundcolor Magenta
Write-Host "Please save file with .csv file extension" -ForegroundColor Green
Write-Host ">>" -NoNewline
$FilePath = Read-Host 

#Export to CSV file
$Information | Sort-Object -Property name | Export-Csv $FilePath

#END