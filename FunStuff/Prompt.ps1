
function prompt {

    $host.ui.RawUI.WindowTitle = "Current Folder: $pwd"

    $zPromptCurrentFolder = Split-Path -Path $pwd -Leaf
    $zCmdPromptUser = [Security.Principal.WindowsIdentity]::GetCurrent();
    $date = Get-Date -Format 'dddd hh:mm:ss tt'

    $zIsAdmin = (New-Object Security.Principal.WindowsPrincipal ([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)


    #calc execution time of last cmd and convert to milliseconds, seconds or minutes
    $lastCommand = Get-History -Count 1
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


    #decorate the prompt
    Write-Host -Object ""
    Write-host -Object ($(if ($zIsAdmin) { 'Elevated ' } else { '' })) -BackgroundColor DarkRed -ForegroundColor White -NoNewline
    Write-Host -Object " USER:$($zCmdPromptUser.Name.split("\")[1]) " -BackgroundColor DarkBlue -ForegroundColor White -NoNewline
    Write-Host -object ".\$zPromptCurrentFolder\ "  -ForegroundColor White -BackgroundColor DarkGray -NoNewline
    Write-Host -Object " $date " -ForegroundColor White
    Write-Host "[" -NoNewline -ForegroundColor Green
    Write-Host $ElapsedTime -ForegroundColor Green -NoNewline
    Write-host "] " -NoNewline -ForegroundColor Green
    return " > "
} #end prompt function
