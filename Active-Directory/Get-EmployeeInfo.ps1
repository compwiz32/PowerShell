Function Get-EmployeeInfo {
<#
    .Synopsis
        Returns a customized list of Active Directory account information for a single user

    .Description
        Returns a customized list of Active Directory account information for a single user.
        The customized list is a combination of the fields that are most commonly needed to review
        when an employee calls the helpdesk for assistance.

    .Example
        Get-EmployeeInfo Tom_Brady
        Returns a customized list of AD account information for user account named Tom_Brady

        PS C:\Scripts> Get-EmployeeInfo Michael_Kanakos

        FirstName    : Tom
        LastName     : Brady
        Title        : Server Engineer
        Department   : Strategic Server Solutions
        Manager      : Bill_Belichick
        City         : Cary
        EmployeeID   : 123456
        UserName     : Tom_Brady
        DisplayNme   : Brady, Tom
        EmailAddress : Tom_Brady@NWTraders.msft
        OfficePhone  : +1 919-555-1212
        MobilePhone  : +1 631-555-1212

        PasswordExpired       : False
        AccountLockedOut      : False
        LockOutTime           : 0
        AccountEnabled        : True
        AccountExpirationDate :
        PasswordLastSet       : 3/26/2018 9:29:02 AM
        PasswordExpireDate    : 9/28/2018 9:29:02 AM

    .Parameter UserName
        The employee account to lookup in Active Directory

    .Notes
        NAME:        Add-EmployeeInfo.ps1
        AUTHOR:      Mike Kanakos
        VERSION:     1.0.2
        DateCreated: 2018-04-10
        DateUpdated: 2019-01-15

    .Link
        https://github.com/compwiz32/PowerShell

#>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True, Position = 1)]
        [string]$UserName
    )


    #Import AD Module
    Import-Module ActiveDirectory

    $Employee = Get-ADuser $UserName -Properties *, 'msDS-UserPasswordExpiryTimeComputed'
    $Manager = ((Get-ADUser $Employee.manager).samaccountname)
    $PasswordExpiry = [datetime]::FromFileTime($Employee.'msDS-UserPasswordExpiryTimeComputed')

    $AccountInfo = [PSCustomObject]@{
        FirstName    = $Employee.GivenName
        LastName     = $Employee.Surname
        Title        = $Employee.Title
        Department   = $Employee.department
        Manager      = $Manager
        City         = $Employee.city
        EmployeeID   = $Employee.EmployeeID
        UserName     = $Employee.SamAccountName
        DisplayNme   = $Employee.displayname
        EmailAddress = $Employee.emailaddress
        OfficePhone  = $Employee.officephone
        MobilePhone  = $Employee.mobilephone
    }

    $AccountStatus = [PSCustomObject]@{
        PasswordExpired       = $Employee.PasswordExpired
        AccountLockedOut      = $Employee.LockedOut
        LockOutTime           = $Employee.AccountLockoutTime
        AccountEnabled        = $Employee.Enabled
        AccountExpirationDate = $Employee.AccountExpirationDate
        PasswordLastSet       = $Employee.PasswordLastSet
        PasswordExpireDate    = $PasswordExpiry
    }

    $AccountInfo

    $AccountStatus

} #END OF FUNCTION