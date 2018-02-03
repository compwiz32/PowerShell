$Computer = Read-Host "Computer Name"
$ServerOU = "OU=High,OU=Servers,OU=North_America,DC=LORD,DC=LOCAL"

Get-ADComputer $Computer | Move-ADObject -TargetPath $ServerOU