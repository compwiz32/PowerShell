#region a super long cmdlet
Start-DbaMigration -Source $Source -Destination $Destination -BackupRestore -NetworkShare $Share -WithReplace -ReuseSourceFolderStructure -IncludeSupportDbs -NoAgentServer -NoAudits -NoResourceGovernor -NoSaRename -NoBackupDevices
#endregion


#region article link
https://blog.robsewell.com/blog/easily-splatting-powershell-with-vs-code/


Steps to setup:

#install module
Install-Module EditorServicesCommandSuite -Scope CurrentUser

#add codeblock to your VSCode profile
C:\Users\USERNAME\Documents\PowerShell\Microsoft.VSCode_profile.ps1

Import-Module EditorServicesCommandSuite
Import-EditorCommand -Module EditorServicesCommandSuite
#endregion


#region simple cmdlet
$getWeatherSplat = @{
    ZipCode  = 27502
    Current  = -Current
    Forecast = -Forecast
}

Get-Weather @getWeatherSplat
#endregion


#region a longish cmd
$newitemSplat = @{
    Name     = $($NumPattern, $name -join " ")
    ItemType = 'Directory'
    Path     = "C:\Users\mkana\Documents\Obsidian\Work\800-899 Hobbies\"
}

new-item @newitemSplat
#endregion


#region ad cmdlet
$getaduserSplat = @{
    filter     = '*'
    SearchBase = "OU=Service Accounts,DC=aligntech,DC=com"
    prop       = '*'
}

get-aduser @getaduserSplat
#endregion



#region long AD cmdlet
$setADUserSplat = @{
    Identity   = $ADUserAccount.DistinguishedName
    Replace    = @{extensionAttribute12 = $HRInfo."Management Level" }
    Server     = $ADServer
    Credential = $PSCredential
}

Set-ADUser @setADUserSplat
#endregion



#region getting a little long
add-content -Value "CertificateName: $($CertContactInfo.CertificateName) - Expire Date: $(CertContactInfo.ExpirationDate) - $certContactInfo.DaysRemaining" -Path $LogFilePath
#endregion



#region hard to read
$compareObjectSplat = @{
    ReferenceObject  = @($Users | Select-Object)
    DifferenceObject = @($TargetGroupMembers | Select-Object)
}

Compare-Object @compareObjectSplat
#endregion



#region two splats
$selectSplat = @{
    Property = @{ Name = 'Computer'; Expression = { $computername } }, 'name', 'owner', 'clientip', 'memoryused'
}

$getWSManInstanceSplat = @{
    ResourceURI   = 'shell'
    ConnectionURI = "http://$($computername):5985/WSMAN"
    Credential    = $cred
    Enumerate     = $true
}

Get-WSManInstance @getWSManInstanceSplat | Select-Object @selectSplat
#endregion