#Requires -Module NameIT

function New-PassPhrase {
    [CmdletBinding()]
    param (
        [Parameter()]
        [int]
        $MinPasswordLength = 10,

        [Parameter()]
        [int]
        $Count = 1,

        [Parameter()]
        [bool]
        $Complexity = $true
    )

    begin {
        $WordTypes = "Noun", "Verb", "color", "adjective", "month"
        $Specials = '~', '!', '@', '#', '%', '^', '&', '*', '_', '-', '+', '=', ':', ';', '<', '>', '.', '?'

        $Wordlist = [System.Collections.Generic.List[PSObject]]::new()
    }

    process {
        for ($i = 1; $i -le 20; $i++) {
            $Random = Get-Random $WordTypes
            $Wordlist.Add((Invoke-Generate $Random))
        }

        for ($i = 1; $i -le $Count; $i++) {

            $Number = Get-Random -Maximum 20
            $PassPhrase = $Wordlist[$Number]

            if ($($PassPhrase.length) -lt $MinPasswordLength) {
                $Number = Get-Random -Maximum 20
                $RandomList1 = [System.Collections.Generic.List[PSObject]]::new()

                $Randomlist1.Add($($Wordlist[$Number]))
                $RandomList1.Add($PassPhrase)

                If ($Complexity) {
                    $Randomlist1.Add($(Get-Random -Maximum 900))
                    $Randomlist1.Add($(Get-Random -Maximum 80))
                    $RandomList1.Add($(Get-Random $Specials))
                    $RandomList1.Add($(Get-Random $Specials))
                    $RandomList1.Add($(Get-Random $Specials))
                }

                $PassPhrase = -join ($RandomList1 | Sort-Object { Get-Random })

                if ($($PassPhrase.length) -lt $MinPasswordLength) {
                    $Number = Get-Random -Maximum 20
                    $RandomList2 = [System.Collections.Generic.List[PSObject]]::new()
                    $Randomlist2.Add($($Wordlist[$Number]))
                    $RandomList2.Add($PassPhrase)

                    If ($Complexity) {
                        $RandomList2.Add($(Get-Random $Specials))
                        $RandomList2.Add($(Get-Random $Specials))
                        $RandomList2.Add($(Get-Random $Specials))
                        $Randomlist2.Add($(Get-Random -Maximum 100))
                        $Randomlist2.Add($(Get-Random -Maximum 60))
                    }

                    $PassPhrase = -join ($RandomList2 | Sort-Object { Get-Random })

                    if ($($PassPhrase.length) -lt $MinPasswordLength) {
                        $Number = Get-Random -Maximum 20
                        $RandomList3 = [System.Collections.Generic.List[PSObject]]::new()
                        $Randomlist3.Add($($Wordlist[$Number]))
                        $RandomList3.Add($PassPhrase)

                        If ($Complexity) {
                            $RandomList3.Add($(Get-Random $Specials))
                            $RandomList3.Add($(Get-Random $Specials))
                            $RandomList3.Add($(Get-Random $Specials))
                            $Randomlist3.Add($(Get-Random -Maximum 100))
                            $Randomlist3.Add($(Get-Random -Maximum 200))
                        } #end Complexity3

                        $PassPhrase = -join ($RandomList3 | Sort-Object { Get-Random })
                    } #end if
                }
            } #end if

            else {
                $passphrase = -join ($(Get-Random $Specials), $PassPhrase, (Get-Random -Maximum 900), $(Get-Random $Specials))
                $PassPhrase
            } #end else#

            $PassPhrase
        }
    }
    end {}
}

