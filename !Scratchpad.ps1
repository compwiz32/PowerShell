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


    # Get a list of existing folders
$folders = Get-ChildItem -Directory

foreach ($folder in $folders) {
    $newName = $folder.Name.Substring(0, $folder.Name.Length - 2)
    Rename-Item -Path $folder.FullName -NewName $newName
}


$folders | Rename-Item -Path $_ -NewName { $_.Name.Substring(0, $_.Name.Length - 2) }



# Define the file path
$file = "C:\Git\Website\content\posts\join-a-local-user-group.md"
$fancySingleQuotes = "[\u2019\u2018]"
$fancyDoubleQuotes = "[\u201C\u201D]"


(Get-Content $file).Replace('+++', '---') | Set-Content $file
(Get-Content $file).Replace(' =', ':') | Set-Content $file
(Get-Content $file).Replace(':00Z', ':00 +0300') | Set-Content $file
(Get-Content $file).Replace("description: `"`"","") | Set-Content $file
(Get-Content $file).Replace("summary:","description:") | Set-Content $file
(Get-Content $file).Replace("`“","`"") | Set-Content $file
(Get-Content $file).Replace("`”","`"") | Set-Content $file
(Get-Content $file).Replace("__GHOST_URL__/content","") | Set-Content $file



# Perform text replacement (replace 'old_text' with 'new_text')
$ReplacePlus = $content | ForEach-Object { $_ -replace '+++', '---' }

# Update the Markdown file with the modified content
Set-Content -Path $file -Value $ReplacePlus
