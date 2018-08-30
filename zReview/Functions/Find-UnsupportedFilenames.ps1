function Find-UnsupportedFilenames($Folder, [switch]$Fix) {

<#
 .Synopsis
    Checks for unsupported characters in file name. Can also fix those filenames as well.

 .Description
    Finds and optionally fixes illegal characters in file names that can cause problems for online services like
    Microsoft OneDrive. Detects filenames with the following characters in the name: ! & { } ~ # %

    If option to remove/replace illegal characters is selected then, the following changes will be made to filenames:

        ! - Removed
        & - Replaced by "and"
        { - Removed
        } - Removed
        ~ - Removed
        # - Removed
        % - Removed


 .Example
  Find-UnsupportedFilenames -Folder <path>
  Returns a list of all files and folders in the specified path that contain unsupported characters.

 .Example
  Find-UnsupportedFilenames -Folder <path> -Fix
  Returns a list of all files and folders in the specified path that contain unsupported characters and automatically fixes those filenames.
  the new file name is displayed immediately after the filename re-write is complete. All unsupported characters will be removed
  from the file or folder name. Ampersand symbol "&" will be replaced by the word "and".

 .Parameter Folder
  The full path to the folder to scan

 .Parameter Fix
  Enable automatic fixing on filenames

 .Notes
  NAME: Find-UnsupportedFilenames
  AUTHOR: Andreas Molin
  LASTEDIT: 2018-02-05
  COMMENT: Mike Kanakos renamed function and added a help section that did not exist in original version

 .Link
  https://gallery.technet.microsoft.com/office/Check-for-unsupported-6676929a

#>

    $Items = Get-ChildItem -Path $Folder -Recurse

    $UnsupportedChars = '[!&{}~#%]'

    foreach ($item in $items) {
        filter Matches($UnsupportedChars) {
            $item.Name | Select-String -AllMatches $UnsupportedChars |
                Select-Object -ExpandProperty Matches
            Select-Object -ExpandProperty Values
        }


        # $BadFiles = @{}
        $BadFiles = @()
        $newFileName = $item.Name
        Matches $UnsupportedChars | ForEach-Object {
            # Write-Host "$($item.FullName) has the illegal character $($_.Value)" -ForegroundColor Magenta
            # $BadFileName = $($item.FullName)
            # $BadCharacter = $($_.Value)
            # $BadFiles.Add($BadFileName, $BadCharacter)
            $BadFiles += $([pscustomobject]@{
                    Name      = $item.FullName
                    Character = $_.value
                })


            if ($_.Value -match "&") { $newFileName = ($newFileName -replace "&", "and") }
            if ($_.Value -match "{") { $newFileName = ($newFileName -replace "{", "(") }
            if ($_.Value -match "}") { $newFileName = ($newFileName -replace "}", ")") }
            if ($_.Value -match "~") { $newFileName = ($newFileName -replace "~", "-") }
            if ($_.Value -match "#") { $newFileName = ($newFileName -replace "#", "") }
            if ($_.Value -match "%") { $newFileName = ($newFileName -replace "%", "") }
            if ($_.Value -match "!") { $newFileName = ($newFileName -replace "!", "") }

        }

        $BadFiles



        if (($newFileName -ne $item.Name) -and ($Fix)) {
            Rename-Item $item.FullName -NewName ($newFileName)
            Write-Host "$($item.Name) has been changed to $newFileName" -ForegroundColor Green
        }
    }
} #END OF FUNCTION