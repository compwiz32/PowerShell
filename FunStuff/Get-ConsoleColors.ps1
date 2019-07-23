Function Get-ConsoleColors {

    <#
    .SYNOPSIS
        Displays all color options on the screen at one time

    .DESCRIPTION
        Displays all color options on the screen at one time

    .EXAMPLE
        Get-ConsoleColors

    .NOTES
        Name       : Get-ConsoleColors.ps1
        Author     : Mike Kanakos
        Version    : 1.0.0
        DateCreated: 2019-07-23
        DateUpdated: 2019-07-23

        LASTEDIT:
        - Create function
        
    .LINK
        https://github.com/compwiz32/PowerShell


#>
    
    [enum]::GetValues([System.ConsoleColor]) | Foreach-Object {Write-Host $_ -ForegroundColor $_}  
    
}