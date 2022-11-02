install-module editorservicescommandsuite -Scope CurrentUser -AllowPrerelease
Import-Module EditorServicesCommandSuite
Get-Command ConvertTo-SplatExpression | Import-EditorCommand

$newpSDriveSplat = @{
    Name = "S"
    Root = "\\Server01\Scripts"
    Persist = $true
    PSProvider = "FileSystem"
    Credential = $cred
}

new-pSDrive @newpSDriveSplat




$newpSDriveSplat = @{
    Name = "S"
    Root = "\\Server01\Scripts"
    Persist = $true
    PSProvider = "FileSystem"
    Credential = $cred
}

new-pSDrive @newpSDriveSplat