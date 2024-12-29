$db = Get-database 'C:\Users\mkana\AppData\Roaming\Ditto\Ditto.db'

$db.InvokeSql("
select * from main m inner join data d on d.'lParentID' = m.'lID'
where d.strClipBoardFormat = 'CF_DIB'
--limit 1000
") | ForEach-Object -Parallel {

    $mod_time = Get-Date -UnixTimeSeconds $_.ldate
    $access_time = Get-Date -UnixTimeSeconds $_.lastPasteDate
    $ext = switch -Regex  ($_.strClipBoardFormat) {
        "CF_DIB" { "bmp" }
        "rich text" { "rtf" }
        default { "txt" }
    }
    $name = "{0}-{1}-{2}-{3}.{4}" -f @(
        $access_time.ToString("yyyy-MM-dd hh_mm_ss")
        $_.lID
        $_.strClipBoardFormat
        $_.lID1
        $ext
    )
    if ($ext -eq "bmp") {
        $newName = $name -replace "bmp$", "png"
        $stream = [convert]::FromHexString(("42 4D 06 00 03 00 00 00 00 00 36 00 00 00" -replace " "))
        Set-Content -AsByteStream -Value ($stream + $_.ooData) -Path $name
        try {
            ConvertTo-Image -FilePath "$pwd\$name" -OutputPath "$pwd\$newName"
            Remove-Item $name
            while (-not ($file = Get-ChildItem $newName -ea silent)) { Write-Host "." -ForegroundColor Red; Start-Sleep 1 }
        }
        catch {
            $_
        }
    }
    else {
        Set-Content -AsByteStream -Value $_.ooData -Path $name
        while (-not ($file = Get-ChildItem $Name -ea silent)) { Write-Host "." -ForegroundColor Yellow; Start-Sleep 1 }
    }
    $file.LastAccessTime = $access_time
    $file.LastWriteTime = $mod_time
}