function prompt {

    #Assign Windows Title Text
    $host.ui.RawUI.WindowTitle = "Current Folder: $pwd"

    #Configure current user, current folder and date outputs
    $CmdPromptCurrentFolder = Split-Path -Path $pwd -Leaf
    $CmdPromptUser = [Security.Principal.WindowsIdentity]::GetCurrent();
    $Date = Get-Date -Format 'dddd hh:mm:ss tt'

    # Test for Admin / Elevated
    $IsAdmin = (New-Object Security.Principal.WindowsPrincipal ([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)

    #Calculate execution time of last cmd and convert to milliseconds, seconds or minutes
    $LastCommand = Get-History -Count 1
    if ($lastCommand) { $RunTime = ($lastCommand.EndExecutionTime - $lastCommand.StartExecutionTime).TotalSeconds }

    if ($RunTime -ge 60) {
        $ts = [timespan]::fromseconds($RunTime)
        $min, $sec = ($ts.ToString("mm\:ss")).Split(":")
        $ElapsedTime = -join ($min, " min ", $sec, " sec")
    }
    else {
        $ElapsedTime = [math]::Round(($RunTime), 2)
        $ElapsedTime = -join (($ElapsedTime.ToString()), " sec")
    }

    #Decorate the CMD Prompt
    Write-Host ""
    Write-host ($(if ($IsAdmin) { 'Elevated ' } else { '' })) -BackgroundColor DarkRed -ForegroundColor White -NoNewline
    Write-Host " USER:$($CmdPromptUser.Name.split("\")[1]) " -BackgroundColor DarkBlue -ForegroundColor White -NoNewline
    If ($CmdPromptCurrentFolder -like "*:*")
        {Write-Host " $CmdPromptCurrentFolder "  -ForegroundColor White -BackgroundColor DarkGray -NoNewline}
        else {Write-Host ".\$CmdPromptCurrentFolder\ "  -ForegroundColor White -BackgroundColor DarkGray -NoNewline}

    Write-Host " $date " -ForegroundColor White
    Write-Host "[$elapsedTime] " -NoNewline -ForegroundColor Green
    return "> "
} #end prompt function


function Invoke-5Admin {
    [CmdletBinding()]
    param ()

    begin {

    }

    process {
        Start-Process powershell.exe -Credential aligntech\mkanakos-admin -ArgumentList "Start-Process powershell.exe -Verb runAs"
    }

    end {

    }
}

function Invoke-7Admin {
    [CmdletBinding()]
    param ()

    begin {

    }

    process {
        Start-Process powershell.exe -Credential aligntech\mkanakos-admin -ArgumentList "Start-Process pwsh.exe -Verb runAs"
    }

    end {

    }
}


#PSReadline settings
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -Colors @{emphasis = '#ff0000'; inlinePrediction = 'Yellow'}
Set-PSReadLineOption -HistoryNoDuplicates
Set-PSReadLineKeyHandler -Key Tab -Function Complete

#Fav Variables & Shortcuts

$exclude = "runspaceid", "pscomputername"

$InputDir = "C:\Scripts\Input"
$OutputDir = "C:\Scripts\Output"

$GitIAMDir = "C:\GitRepos\foundational-and-identity"
$OneDriveDir = "C:\Users\mkanakos\OneDrive - Align Technology, Inc"
$DownloadsDir = "C:\Users\mkana\Downloads"
$DesktopDir = "C:\Users\mkanakos\Desktop"
$ReportsDir = "C:\Users\mkanakos\OneDrive - Align Technology, Inc\Reports"
