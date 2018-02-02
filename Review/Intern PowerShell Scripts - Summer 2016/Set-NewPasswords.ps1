<# 
  .Synopsis 
  Set new passwords for a group of people

  .Description 
  This script runs off of a CSV with columns for UserPrincipalName, samaccountname, and new passwords.
  Will import a list of users from a CSV file and pu7t it into an array. Loops through the array and changes
  the password to a predetermined random password that is in the CSV file. It will also prompt the user to
  change the password at the next logon for security purposes. Script writes to the screen after each user
  that it updates so that you can track the progress.
  This script was written for the FlyByWire onboarding process.

  .Example 
  Set-NewPasswords
  Takes no user input and the only visible output is the script writing "Password has been reset for the user: ____"
  to the screen. It will reset passwords for an array of people imported from a CSV

#>

#Using Active Directory
Import-Module ActiveDirectory

#Using Office 365 PowerShell
Import-Module MSOnline
Connect-MsolService

#Get the list of accounts from the Excel file
$Users = Import-Csv  C:\Users\Melissa_Green\Documents\"NewPasswords.csv"

ForEach ($User in $Users)
{
    #Set the default password for the current account in Active Directory
    Set-ADAccountPassword $User.samaccountname  -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $User.password -Force)

    #Set the default password for the current account in Office 365
    Set-MsolUserPassword -UserPrincipalName $User.upn -NewPassword $User.password -ForceChangePassword $false

    #Make the user change the password next time they log in
    Get-ADUser $User.samaccountname | Set-ADUser -ChangePasswordAtLogon $true

    $name = $user.samaccountname

    Write-Host "Password has been reset for the user: $name"
}

#END