$Username = Read-Host "What User ID do you want to check?"
Get-ADUser $Username -Properties Lockedout | Select-Object LockedOut