function Get-iDriveLog {
    [CmdletBinding()]
    param (

    )

    begin {
        $LogDirectory = "C:\ProgramData\IDrive\IBCOMMON\mkana\Session\Backup"
        $FileList = get-childitem $LogDirectory | Sort-Object -Descending CreationTime

    }
    process {

        $file = $FileList[0]
        # $file = $filelist | Where-Object {$_.creationtime -gt (get-date).AddDays(-2) -and $_.creationtime -lt (get-date).AddDays(-1)}

        # Get-Content -Path $LogDirectory\06-24* | ForEach-Object { if ($_ -match "success" ) { Write-Output $_ } }

        # Get-Content -Path "$LogDirectory\$($file.name)" | ForEach-Object { if ($_ -match "success" ) { Write-Output $_ } }
        Get-Content -Path "$LogDirectory\$($file.name)" | ForEach-Object { if ($_ ) { Write-Output $_ } }
    }

    end {

    }
}