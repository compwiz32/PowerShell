<# 
  .Synopsis 
  Show users that are not in a specified Security Group

  .Description 
  Searching through the North American OU, the script is looking for users that are not a part of a specified
  Security Group. Right now, it is set to find people not in the Zscaler Test group, but by changing the 
  'sg-zscaler-test' in Get-ADGroup on line 26, you can change the security group that you are filtering through.
  This script uses user input to determine the filepath to export to.
  This script was written to pull a report for Scott Wilson.

  .Example 
  SecurityGroup-NotinZScaler 
  Asks the user to input a filepath to save the CSV to and then returns name, samaccountname, and userprincipalname
  of all of the users in North American OU that are not a member of the Zscaler Test group.

#>

#Which security group to check for
$SecurityGroup = (Get-ADGroup 'sg-zscaler-test').DistinguishedName

#Determine the OU
$OU = "OU=North_America,DC=LORD,DC=LOCAL"

#Get the Information
$Result = Get-ADUser -Filter { -not (memberof -eq $SecurityGroup) } -SearchBase $OU | select name, distinguishedname, samaccountname, userprincipalname

#Let user choose file path
Write-Host "Input file path to save output file.  Example: " -nonewline
Write-host "c:\temp\Array.csv" -foregroundcolor Magenta
Write-Host "Please save file with .csv file extension" -ForegroundColor Green
Write-Host ">>" -NoNewline
$FilePath = Read-Host 

#Export to CSV file
$Result | Sort-Object -Property name | Export-Csv $FilePath
#END