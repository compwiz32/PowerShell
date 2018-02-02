<# 
  .Synopsis 
  Set a custom license pack and then show each users outcome

  .Description 
  This script runs off of a CSV with columns for UserPrincipalName and Country.
  Import a list of users from a CSV file into an array. Script will loop through the array and assign every user
  the Enterprise Pack License and then disable select plans so that the user has correct licenses. This script is
  written to enable Microsoft Planner, Office 365 ProPlus, Skype for Business Online, and Exchange Online from the
  Office 365 Enterprise E3 pack. By adding to or removing from the -DisabledPlans, you can choose the custom license.
  Note: You are unable to set a license on someone that already has a license assigned to them, so you must remove
  all licenses before this script will run without error.
  This script was written for the FlyByWire onboarding process

  .Example 
  Set-CustomLicense.ps1 
  Sets the custom licenses and then prints each user and their expanded license information to the screen.

#>

#Using Office 365 PowerShell
Import-Module MSOnline
Connect-MsolService

#Import all of the information into an array
$Users = Import-CSV C:\Users\Melissa_Green\Documents\"Test.csv"

#Variable to hold the E3 pack name and the applications inside E3 that we do NOT want to give licenses for
$mysku1 = New-MsolLicenseOptions -AccountSkuId lordcorp:ENTERPRISEPACK -DisabledPlans INTUNE_o365, SWAY, YAMMER_ENTERPRISE, RMS_S_ENTERPRISE, SHAREPOINTWAC, SHAREPOINTENTERPRISE

#Loop through each user in the array one at a time to set the location and licenses
ForEach ($User in $Users)
{

    #Set the Users Location to United States
    Set-MsolUser -UserPrincipalName $User.UserPrincipalName -UsageLocation $User.country

    #Assign user the entire EnterprisePack and then disable parts of it
    Set-MsolUserLicense -UserPrincipalName $User.UserPrincipalName -AddLicenses lordcorp:ENTERPRISEPACK -LicenseOptions $mysku1

}

#Loop through each user in the array one at a time to view their license information
ForEach ($User in $Users)
{

    #get the user and select the properties we want to see
    Get-MsolUser -UserPrincipalName $User.UserPrincipalName | Select-Object -ExpandProperty licenses | select-object –expandproperty servicestatus

}

#END