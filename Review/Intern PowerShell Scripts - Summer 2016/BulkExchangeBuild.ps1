<# 
  .Synopsis 
  Create email and Active Directory accounts in bulk from a CSV

  .Description 
  This script runs off of a CSV with columns for all of the information that you are using to create the Active Directory account.
  Will create multiple mail-enabled user accounts at once in Exchange and Active Directory.
  This script was written for the FlyByWire onboarding process. Ed Wentling wrote a different version of this, so this script
  has not been tested.

  .Example 
  BulkExchangeBuild
  Has no visible output. Will create a mailbox and active directory account from a list of people in the CSV.

#>

#Assign a password - it will be the same password for all users
$Password = Read-Host "Enter Password" -AsSecureString

#Import the CSV file and create mailboxes
#Come back and add all of the fields you need when you know what the .CSV file looks like
Import-CSV "C:\Users\Melissa_Green\Documents\PowerShell\NameofDocuemnt.csv" | ForEach {New-Mailbox -Alias $_.alias -Name $_.name -userPrincipalName $_.upn -Database "Mailbox Database" -OrganizationalUnit Users - Password $Password}

#End