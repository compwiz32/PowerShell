function Test-MarkdownFileLinks {
    [CmdLetBinding()]
    param(
        [ValidateScript({Test-Path -Path $_})]
        [string[]]$MarkdownFile,
        [uri[]]$SkipUri,
        [switch]$ShowProgress
    )

    begin {
        $InlineMdLink = '(?:]\()(?<Inline>\S+\w)(?:\))'
        $RefMdLink ='(?:^\[\d+\]:\s*)(?<Reference>\S+)'
        $FileCount = 1
    }

    process {

        foreach ($Markdown in $MarkdownFile) {
            $LineCount = 1
            $File = Get-ChildItem -Path $Markdown
            $Content = Get-Content -path $File.FullName

            foreach ($Line in $Content) {
                if ($ShowProgress) {
                    $ProgressParams = @{
                        Activity = 'Checking Links'
                        Status = '{0} - {1}/{2}' -f $File.Name,$FileCount,$MarkdownFile.Count
                        CurrentOperation = 'Line {0}/{1}' -f $LineCount,$Content.Count

                    }
                    Write-Progress @ProgressParams
                }
                if ($Line -match "$InlineMdLink|$RefMdLink") {
                    'Found link on line {0}' -f $LineCount | Write-Verbose

                    $StatusCode = $null
                    foreach ($MatchUrl in $Matches) {
                        if ($MatchUrl['Inline']) {
                            $LinkType = 'Inline'
                            $Url = $MatchUrl['Inline']
                            if ($SkipUri.AbsoluteUri -contains $MatchUrl['Inline']) {
                                $StatusCode = 'Skipped'
                            }
                        } elseif ($MatchUrl['Reference']) {
                            $LinkType = 'Reference'
                            $Url = $MatchUrl['Reference']
                            if ($SkipUri.AbsoluteUri -contains $MatchUrl['Reference']) {
                                $StatusCode = 'Skipped'
                            }
                        }
                        if ($StatusCode -ne 'Skipped') {
                            try {
                                $OriginalProgress = $ProgressPreference
                                $ProgressPreference = 'SilentlyContinue'
                                $StatusCode = (Invoke-WebRequest -Uri $Url -Verbose:$false).StatusCode
                                $ProgressPreference = $OriginalProgress
                            }
                            catch {
                                $StatusCode = $_.Exception.Message
                            }
                        }
                        [PsCustomObject]@{
                            Name = $File.Name
                            FullName = $File.FullName
                            LineNumber = $LineCount
                            Line = $Line
                            Link = $Url
                            LinkType = $LinkType
                            StatusCode = $StatusCode
                        }
                    }
                }
                $LineCount++
            }
            $FileCount++
        }
    }

    end {

    }
}