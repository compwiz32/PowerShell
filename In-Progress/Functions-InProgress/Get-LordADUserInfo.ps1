Function Get-LordADUserInfo
{

 <#
    .SYNOPSIS
    This function returns common AD User account info related to login and password status
                 
    .DESCRIPTION            
    This function returns common AD user fields most commonly used to tell if their is an
    issue with a user account (ie password status, expiration date, lockout status, last changed date)
    along with some basic acct info to verify user if they are on the phone

  .Example 
  Get-LordADuserInfo michael_kanakos
  
  Account Info
  ------------

  Displayname  : Kanakos, Michael
  Department   : Strategic Server Solutions
  City         : Cary
  Manager      : CN=Adams\, William,OU=Users,OU=Cary,OU=North_America,DC=LORD,DC=LOCAL
  EmailAddress : Michael_Kanakos@LORD.COM
  OfficePhone  : +1 919-342-4132
  MobilePhone  : +1 631-355-4580
  EmployeeID   : 201278



  Account Status
  --------------

  Enabled               : True
  AccountExpirationDate : 
  LockedOut             : False
  LockedOutTime         : {}
  PasswordLastSet       : 9/15/2016 8:54:17 AM
  PasswordExpireDate    : 3/20/2017 8:54:17 AM
  PasswordExpired       : False

#>


[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True,Position=1)]
   [string]$UserName
   )
   
  
# Get User Acct Info from AD  
$ADInfo = Get-ADUser $UserName –Properties DisplayName, City, EmailAddress, EmployeeID, Enabled, Manager, Department, OfficePhone, MobilePhone,LockedOut, LockOutTime, AccountExpirationDate, PasswordExpired, PasswordLastSet, “msDS-UserPasswordExpiryTimeComputed”


# Output AD User Info
Write-Host ""
Write-Host "Account Info" -ForegroundColor Yellow
Write-Host "------------" -NoNewline
$ADInfo | Select-Object -Property Displayname, Department, City, Manager,EmailAddress, OfficePhone, MobilePhone, EmployeeID | fl


# Output AD User Account Status
Write-Host "Account Status" -ForegroundColor Yellow
Write-Host "--------------" -NoNewline

$ADInfo  | Select-Object -Property Enabled, AccountExpirationDate, LockedOut, LockedOutTime, PasswordLastSet,@{Name=“PasswordExpireDate”;Expression={[datetime]::FromFileTime($_.“msDS-UserPasswordExpiryTimeComputed”)}}, PasswordExpired | fl


}