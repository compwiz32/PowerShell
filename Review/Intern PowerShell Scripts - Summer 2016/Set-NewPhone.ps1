<# 
  .Synopsis 
  Updates phone number fields in Active Directory

  .Description 
  This script runs off of a CSV with columns for samaccountname, mobile, telephonenumber, and othertelephone.
  Make an array of employees and their phone numbers from a predetermined CSV file. Loops through the array
  to create a hash table that will update the phone numbers. This will throw an error for employees that are
  replacing null fields with null fields (typically for interns that don't have any phone numbers listed). The
  error can be ignored because it doesn't effect any of the other users. The script will also print to the screen
  so that you can watch the progress as each person is updated.
  The new standard for phone numbers is outlined in KB0010938.
  This script was written for the 10 digit dial phone number update.

  .Example 
  Set-NewPhone
  The only visible output is the script writing "Information recorded for ___________" to the screen. It will 
  reset phone numbers for an array of people imported from a CSV.

#>

#Using Active Directory
Import-Module ActiveDirectory

#Import all of the information from the Excel document
$Users = Import-CSV C:\Phone\"MissedInformationTryAgain.csv"

#Loop through each user in the Excel document and replace their original phone numbers with the ones from the file
ForEach ($User in $Users)
{
  $hash = @{}
  if(!($user.mobile -eq "")){$hash.mobile = $user.mobile;}
  if(!($user.telephoneNumber -eq "")){$hash.telephoneNumber = $user.telephoneNumber;}
  if(!($user.othertelephone -eq "")){$hash.othertelephone = $user.othertelephone}
  Set-ADUser -Identity $user.samaccountName -Replace $hash

$Screen = $User.name

#Print to screen for progress updates
Write-Host "Information recorded for $Screen"
}

#END