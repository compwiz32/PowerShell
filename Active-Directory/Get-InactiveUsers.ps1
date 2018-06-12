$InactiveUsers = Search-ADAccount -AccountInactive -TimeSpan 60 -UsersOnly | Where-Object { $_.Enabled -eq $true } | Format-Table Name

foreach ($User in $InactiveUsers) {
    Get-ADUser $User -prop city, manager, department | Select-Object name, userprincipalname, department, city, manager
}