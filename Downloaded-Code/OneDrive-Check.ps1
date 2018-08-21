### Created by Andreas Molin
### Usage: Import-Module OneDrive-Check.ps1
### OneDrive-Check -Folder <path>
### OneDrive-Check -Folder <path> -Fix

function OneDrive-Check($Folder,[switch]$Fix){
    $Items = Get-ChildItem -Path $Folder -Recurse

    $UnsupportedChars = '[!&{}~#%]'

    foreach ($item in $items){
        filter Matches($UnsupportedChars){
        $item.Name | Select-String -AllMatches $UnsupportedChars |
        Select-Object -ExpandProperty Matches
        Select-Object -ExpandProperty Values
        }

        $newFileName = $item.Name
        Matches $UnsupportedChars | ForEach-Object {
            Write-Host "$($item.FullName) has the illegal character $($_.Value)" -ForegroundColor Magenta
            if ($_.Value -match "&") { $newFileName = ($newFileName -replace "&", "and") }
            if ($_.Value -match "{") { $newFileName = ($newFileName -replace "{", "(") }
            if ($_.Value -match "}") { $newFileName = ($newFileName -replace "}", ")") }
            if ($_.Value -match "~") { $newFileName = ($newFileName -replace "~", "-") }
            if ($_.Value -match "#") { $newFileName = ($newFileName -replace "#", "") }
            if ($_.Value -match "%") { $newFileName = ($newFileName -replace "%", "") }
            if ($_.Value -match "!") { $newFileName = ($newFileName -replace "!", "") }
         }
         if (($newFileName -ne $item.Name) -and ($Fix)){
            Rename-Item $item.FullName -NewName ($newFileName)
            Write-Host "$($item.Name) has been changed to $newFileName" -ForegroundColor Green
         }
    }
}