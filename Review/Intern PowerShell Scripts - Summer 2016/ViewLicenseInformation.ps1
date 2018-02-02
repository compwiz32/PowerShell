# Melissa Green
# This script will take a specific user and find the licenses that they have. From this, we can
# expand the property of the license pack to see the provisioning status of each application in
# the pack

# TESTED AND RUNS AS EXPECTED

#Using Office 365 PowerShell
Import-Module MSOnline
Connect-MsolService

#Import all of the information from the Excel document
$Users = Import-CSV C:\Users\Melissa_Green\Documents\"Test.csv"

#Loop through each user in the Excel document and replace their original phone numbers with the ones from the file
ForEach ($User in $Users)
{

#get the user and select the properties we want to see
get-msoluser -userprincipalname $User.UserPrincipalName | Select-Object -ExpandProperty licenses | select-object –expandproperty servicestatus

}

#END