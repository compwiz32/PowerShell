# Build-DomainController.ps1
# Author: Mike Kanakos - August 2016
# -------------------------------------------------------

#Prompt for Server Name
Write-Host "What is name of server you want to promote to a DC?" -foregroundcolor Green
$dc = Read-Host 


#Prompt for Credentials
Write-Host "This process requires you to authenticate." -ForegroundColor Green
Write-Host "Press any key to authenicate ..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
$cred = Get-Credential lord\a-Mike_Kanakos

#Promote Domain Controller
Get-Date
Invoke-Command –ComputerName $dc –ScriptBlock{
Install-ADDSDomainController `
    -NoGlobalCatalog:$false `
    -CriticalReplicationOnly:$true `
    -DatabasePath "C:\Windows\NTDS" `
    -DomainName "lord.local" `
    -InstallDns:$true `
    -LogPath "C:\Windows\NTDS" `
    -NoRebootOnCompletion:$true `
    -Credential $using:cred `
    -Confirm:$false `
    -SafeModeAdministratorPassword ` (ConvertTo-SecureString 'LordAdmin456!' -AsPlainText -Force)
    }

#reboot after dcpromo
Write-Host "restarting computer after DCPromo" -foreground Green
Restart-Computer $dc ` -Wait -For PowerShell -Force -Confirm:$false

#check status of core AD services
Write-Host "Checking status of core AD services" -foreground Green $dc
Get-Service adws,kdc,netlogon,dns, DHCP,W32Time -ComputerName $dc