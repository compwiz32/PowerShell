<# 
  .Synopsis 
  Remove license pack

  .Description 
  This script runs off of a CSV with a column for UserPrincipalName.
  Will disable all licenses that are assigned to a specific user. In order to set the license using a script,
  all previous licenses have to have been removed from the user or else it will throw an error. It is recommended
  to run this script first to avoid a mix of error and success on the array of employees. 
  This script was written for the FlyByWire onboarding process.

  .Example 
  RemoveLicense.ps1 
  Remove licenses and then prints each user and their expanded license information to the screen.

#>

#Using Office 365 PowerShell
Import-Module MSOnline
Connect-MsolService

#Import all of the information into an array
$Users = Import-CSV C:\Users\Melissa_Green\Documents\"Test.csv"

#Loop through each user in the array one at a time to set the location and licenses
ForEach ($User in $Users)
{
    #Disable user the entire EnterprisePack
    Set-MsolUserLicense -UserPrincipalName $User.UserPrincipalName -RemoveLicenses lordcorp:ENTERPRISEPACK
}