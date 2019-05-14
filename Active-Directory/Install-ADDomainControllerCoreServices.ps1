function Install-ADDomainControllerCoreServices {

<#
    .Synopsis
        Installs services needed for computer to function as a domain controller

    .Description
        Installs the necessary services that are needed for a computer to become a domain controller. This function does
        not join promote the domain controller. 

    .Example
        Install-ADDomainControllerCoreServices -computer DC01 
        
        Installs the AD services needed on server named DC01

        
    .Parameter Computer
        The name of the remote computer that will have the necessary AD services installed

    
    .Notes
        NAME:        Install-ADDomainControllerCoreServices.ps1
        AUTHOR:      Mike Kanakos
        VERSION:     1.0.0
        DateCreated: 2019-05-14
        DateUpdated: 2019-05-14

        v1.0.0 - initial function creation. Conversion of a flat script to a function and modernizing of code 
                 (try/catch, help, loop, parameters, etc. )

    .Link
        https://github.com/compwiz32

#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True)]
    [Alias("Name","PC")]
    [string]
    $Computer   
)

$services = @('AD-Domain-Services','DNS','DHCP','FS-DFS-Namespace','FS-DFS-Replication')

Write-Host "Querying list of installed services on $computer ..."
Get-WindowsFeature -ComputerName $Computer | Where-Object Installed | Format-Table Name

$online = Test-Connection -ComputerName $Computer -Count 2 -Quiet
    if ($online -eq $true)
    {
        Import-Module servermanager      
        
        Foreach($service in $services){

            Try {
                Write-Host "Installing $service. Start time is: " -foregroundcolor Green -NoNewline
                Write-Host $(get-date) -foregroundcolor Magenta
                
                Install-WindowsFeature –Name $service –ComputerName $Computer -IncludeManagementTools -ErrorAction Stop

            } #end try

            Catch {
                Write-Output "Service: $Service failed to install: $error[0].Exception.Message"

            } #end catch  

        }#foreach
        
    Write-Host "Updating PowerShell help files" -foregroundcolor Green
    invoke-command -Computer $computer -ScriptBlock {update-help}

    } #end if

} #end function
