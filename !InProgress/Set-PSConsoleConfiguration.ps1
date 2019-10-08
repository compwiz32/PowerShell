function Set-PSConsoleConfiguration {

    <#
    .SYNOPSIS
        Sets the window size, font and font attributes for the PowerShell console window

    .DESCRIPTION
        Sets the window size, font and font attributes for the PowerShell console window. Allows for programatically
        setting the properties of the PowerShell console without having to interact with the GUI.

    .PARAMETER ForegroundColor
        The name of the computer you want to query. More than one computer can be entered by seperating each computername
        should be with a comma.

    .PARAMETER BackgroundColor
        The name of the computer you want to query. More than one computer can be entered by seperating each computername
        should be with a comma.

    .PARAMETER BufferSize
    The name of the computer you want to query. More than one computer can be entered by seperating each computername
    should be with a comma.

    .PARAMETER WindowWidth
        The name of the computer you want to query. More than one computer can be entered by seperating each computername
        should be with a comma.

    .PARAMETER WindowHeight
        The name of the computer you want to query. More than one computer can be entered by seperating each computername
        should be with a comma.

    .PARAMETER WindowTitle
        The name of the computer you want to query. More than one computer can be entered by seperating each computername
        should be with a comma.

    .EXAMPLE
    Get-ServerOwner SRV01

    Name        ManagedBy           OperatingSystem                   CanonicalName
    ----        ---------           ---------------                   -------------
    SRV01       Michael_Kanakos     Windows Server 2012 R2 Standard   NWTraders.MSFT/Computers/SRV01

    .EXAMPLE
    Get-ServerOwner SRV01

    Name        ManagedBy           OperatingSystem                   CanonicalName
    ----        ---------           ---------------                   -------------
    SRV01       Michael_Kanakos     Windows Server 2012 R2 Standard   NWTraders.MSFT/Computers/SRV01

    .EXAMPLE
        Get-ServerOwner SRV01 | Format-List

        Name            : SRV01
        ManagedBy       : Michael_Kanakos
        OperatingSystem : Windows Server 2012 R2 Standard
        CanonicalName   : NWTraders.MSFT/Computers/SRV01


    .EXAMPLE
        Get-ServerOwner Svr01, svr02, svr03 | Format-Table

        Name     ManagedBy           OperatingSystem                      CanonicalName
        ----     ---------           ---------------                      -------
        SRV01    Michael_Kanakos     Windows Server 2012 R2 Standard      NWTraders.MSFT/Computers/SRV01
        SRV02    Derek_Jeter         Windows Server 2012 R2 Standard      NWTraders.MSFT/Computers/SRV02
        SRV03    Tom_Brady           Windows Server 2012 R2 Standard      NWTraders.MSFT/Computers/SRV03


    .NOTES
        Name: Get-ServerOwner
        Author: Mike Kanakos
        Version: 1.0.0
        DateCreated: 2019-06-05
        DateUpdated: 2019-09-17

        v1.0.1 - fix broken code, add examples, add parameter, add foreach

    .LINK
        https://www.github.com/compwiz32/Powershell

    #>


    [CmdletBinding()]
    param (

    )

    begin {

    }

    process {

    }

    end {

    }
}


<#
ForegroundColor       : DarkYellow
BackgroundColor       : DarkMagenta
CursorPosition        : 0,207
WindowPosition        : 0,168
CursorSize            : 25
BufferSize            : 150,3000
WindowSize            : 150,40
MaxWindowSize         : 150,63
MaxPhysicalWindowSize : 240,63
KeyAvailable          : False
WindowTitle           : Administrator: Windows PowerShell
#>
