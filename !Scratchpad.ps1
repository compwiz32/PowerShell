##Out-File longfilepath.txt ; cmd /c "dir /b /s /a" | ForEach-Object { if ($_.length -gt 250) {$_ | Out-File -append longfilepath.txt}}


cmd /c "dir /b /s /a" | ForEach-Object { if ($_.length -gt 250) {$_ | Write-Host $_.length, $_ }}

cmd /c "dir /b /s /a" | ForEach-Object Write-Host $_.length, $_ }


# $obj = New-Object psobject
Get-ChildItem C:\Scripts -Recurse | ForEach-Object {
    $FilePath = $_.FullName
    # $obj | Add-Member NotePropertyColumnA $FilePath.Length $obj | Add-Member NotePropertyColumnB $FilePath $obj
    Write-Host  $FilePath.Length,  $FilePath
    }





$array = @{}
Get-ChildItem C:\Scripts -Recurse | ForEach-Object {
    $Path = $_.FullName
    $PathLength = $a.Length
    $array.Path = $Path
    $array.PathLength = $PathLength
}





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





