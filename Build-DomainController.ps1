# Build-DomainController.ps1
# Author: Mike Kanakos - July 2016
# Updated: 2018-05-22 - added ping check and if/else loop
# -------------------------------------------------------

#Prompt for Server Name
Write-Host "What is name of server you want to installed DC services on?" -foregroundcolor Green
$dc = Read-Host

 $online=PingMachine $dc
    if ($online -eq $true)
    {
    # Ping Success

    Import-Module servermanager

    #List installed Windows Roles / Features
    get-date
    Write-Host "Getting list of current Roles & Features installed" -foreground Cyan
    Write-Host "Please wait, this takes a few minutes to gather the info"
    Get-WindowsFeature -ComputerName $dc | Where-Object Installed | Format-Table Name

    Write-Host "
    This script will not install WINS, please do so manually if the DC will be a WINS server " -BackgroundColor White -ForegroundColor Red

    #Install required services for DCPromo
    Get-Date
    Write-Host "Installing AD Domain Services" -foreground Green
    Install-WindowsFeature –Name AD-Domain-Services –ComputerName $dc -IncludeManagementTools

    #DNS
    Write-Host "Installing DNS" -foreground Green
    Install-WindowsFeature –Name DNS –ComputerName $dc -IncludeManagementTools

    #DHCP
    Write-Host "Installing DHCP" -foreground Green
    Install-WindowsFeature –Name Dhcp –ComputerName $dc -IncludeManagementTools


    #update help on new domain controller
    Write-Host "Updating PowerShell help file on" -foreground Green $dc
    invoke-command -ComputerName $dc -ScriptBlock {update-help}

    #Display refreshed list of installed Windows Roles / Features
    Get-Date
    Write-Host "Getting updated list of Windows Roles / Features:" -foreground Cyan
    Get-WindowsFeature -ComputerName $dc | Where-Object Installed | Format-Table Name

    else
    {
        # Ping Failed!
        Write-Host "Error: $dc not Pingable" -fore white -BackgroundColor Red
    }
}