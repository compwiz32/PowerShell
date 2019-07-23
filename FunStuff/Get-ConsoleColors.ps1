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
        Version    : 1.0.1
        DateCreated: 2019-07-23
        DateUpdated: 2019-07-23

        LASTEDIT:
        - Add loops for foreground and background colors
        - output foreground and background colors for easy selection
        
    .LINK
        https://github.com/compwiz32/PowerShell


#>
    

    $List = [enum]::GetValues([System.ConsoleColor]) 
    
    ForEach ($Color in $List){
        # Write-Host "   " -nonewline
        Write-Host "      $Color" -ForegroundColor $Color -NonewLine
        Write-Host "" 
        
    }

    ForEach ($Color in $List){
        # Write-Host "  " -nonewline -backgroundColor $color
        Write-Host "      Background: $Color      " -backgroundColor $Color
        # Write-Host "      " -backgroundColor $color
        
    }


    
    
    # | Foreach-Object {Write-Host $_ -ForegroundColor $_}  

    # [enum]::GetValues([System.ConsoleColor]) | Foreach-Object {
    #    Write-Host "  " $_ -Backgroundcolor -nonewline
    #    WR
    #     $_ -BackgroundColor $_}  
    
}