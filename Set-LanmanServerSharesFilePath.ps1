Function Set-LanmanServerSharesFilePath {

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
        VERSION:     1.0.3
        DateCreated: 2018-04-10
        DateUpdated: 2019-01-15

        v 1.0.3 - update help file formatting

    .Link
        https://github.com/compwiz32/PowerShell

#>




    [cmdletbinding(SupportsShouldProcess = $true)]
    param(
        $OldFilePath,
        $NewFilePath
    )
 
    $RegPath = ‘HKLM:SYSTEMCurrentControlSetServicesLanmanServerShares’

    dir -Path $RegPath | Select-Object -ExpandProperty Property | ForEach-Object {
        $ShareName = $_
        $ShareData = Get-ItemProperty -Path $RegPath -Name $ShareName |
        Select-Object -ExpandProperty $ShareName
        if ($ShareData | Where-Object { $_ -eq “Path=$OldPath“ }) {
            $ShareData = $ShareData -replace [regex]::Escape(“Path=$OldPath“), “Path=$NewPath“
 
            if ($PSCmdlet.ShouldProcess($ShareName, ‘Change-SharePath’)) {
                Set-ItemProperty -Path $RegPath -Name $ShareName -Value $ShareData
            } #nd if Set-ItemProperty
        } #end If $sharedata
    } #end ForEach
} #end Function
 