function Find-IllegalCharacters ($Path, $OutputFile, [switch]$Fix, [switch]$Verbose) {
    #The maximum allowed number of characters of a file's full path + name
    $maxCharacters = 400
    #The maximum file size
    $maxFileSize = 2147483648
    #A list of file types that can't be sync'd
    $invalidFileTypes = ".tmp", ".ds_store"
    #A list of file names that can't be sync'd
    $invalidFileNames = "desktop.ini", "thumbs.db", "ehthumbs.db"

    Write-Host Checking files in $Path, please wait...

    #Only run for a valid path
    if (!(test-path $path)) {
        'Invalid path for file renames'
    }
    else {
        #if the output file exists empty it first
        if (test-path $outputFile) {
            clear-content $outputFile
        }
        #add headers to output file
        Add-Content $outputFile "File/Folder Name	New Name	Comments";

        #Get all files and folders under the path specified
        $items = Get-ChildItem -Path $Path -Recurse
        foreach ($item in $items) {
            #Keep a flag to indicate whether or not we can perform the updates (some problems are deal breakers)
            $valid = $true
            #Keep an array list for comments
            $comments = New-Object System.Collections.ArrayList

            if ($item.PSIsContainer) { $type = "Folder" }
            else { $type = "File" }

            #Check if item name is longer than the max characters in length
            if ($item.Name.Length -gt $maxCharacters) {
                [void]$comments.Add("$($type) $($item.Name) is $($item.Name.Length) characters (max is $($maxCharacters)) and will need to be truncated")
                $valid = $false
            }

            if ($item.Length -gt $maxFileSize) {
                [void]$comments.Add("$($type) $($item.Name) is $($item.Length / 1MB) MB (max is $($maxFileSize / 1MB)) and cannot be synchronized.")
                $valid = $false
            }

            if ($invalidFileNames.Contains($item.Name)) {
                [void]$comments.Add("$($type) $($item.Name) is not a valid filename for file sync.")
                $valid = $false
            }

            if ($invalidFileTypes.Contains($item.Name.Substring($item.Name.Length - 4))) {
                [void]$comments.Add("$($type) $($item.Name) type $($item.Name.Substring($item.Name.Length-4)) is not a valid file type for file sync.")
                $valid = $false
            }

            #Technically all of the following are illegal \ / : * ? " < > | # %
            #However, all but the last two are already invalid Windows Filename characters, so we don't have to worry about them
            $illegalChars = '[#%*?"<>|!&{}~]'
            filter Matches($illegalChars) {
                $item.Name | Select-String -AllMatches $illegalChars |
                    Select-Object -ExpandProperty Matches
                Select-Object -ExpandProperty Values
            }

            #Replace illegal characters with legal characters where found
            $newFileName = $item.Name
            Matches $illegalChars | ForEach-Object {
                if ($Verbose) { [void]$comments.Add("Illegal string '$($_.Value)' found") }
                #These characters may be used on the file system but not SharePoint
                if ($_.Value -match "#") { $newFileName = ($newFileName -replace "#", "-") }
                if ($_.Value -match "%20") { $newFileName = ($newFileName -replace "%20", " ") }
                if ($_.Value -match "%") { $newFileName = ($newFileName -replace "%", "-") }
            }

            if ($comments.Count -gt 0) {
                #output the details
                Add-Content $outputFile "$($item.FullName)	$($item.FullName -replace $([regex]::escape($item.Name)), $($newFileName))	$($comments -join ', ')"
                if ($Verbose) {
                    Write-Host $($type) $($item.FullName): $($comments -join ', ') -ForegroundColor Red
                }
            }

            #Fix file and folder names if found and the Fix switch is specified
            if ($newFileName -ne $item.Name) {
                if ($fix -and $valid) {
                    Rename-Item $item.FullName -NewName ($newFileName)
                    if ($Verbose) {
                        Write-Host $($type) $($item.Name) has been changed to $($newFileName) -ForegroundColor Yellow
                    }
                }
            }
        }
    }
    Write-Host "Done"
}

#Example: Find-IllegalCharacters -Path 'C:\Users\User\Downloads\Files With Errors' -OutputFile 'C:\Users\User\Desktop\RenamedFiles.tsv' -Verbose -Fix