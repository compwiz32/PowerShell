#Requires -Module NameIT

param (
    $MinPasswordLength = 8
)

<#
    Invoke-Generate can take a hashtable in `-CustomData` then you can use the `key` in the template to get a random value
#>

$custom = @{
    WordTypes = "Noun", "Verb", "color", "adjective", "month"
    Specials  = '~', '!', '@', '#', '%', '^', '&', '*', '_', '-', '+', '=', '\', ':', ';', '<', '>', '.', '?', '/'
    WordList  = @()
}

foreach ($word in Invoke-Generate '[WordTypes]' -CustomData $custom -Count 20) {
    $custom.WordList += Invoke-Generate "[$word]" -CustomData $custom
}

$PassPhrase = Invoke-Generate "[WordList]" -CustomData $custom

$RandomList1 = @()

if ($PassPhrase.length -lt $MinPasswordLength) {
    $RandomList1 += Invoke-Generate "###" # Only generates 3 numbers from 0-9. May not be sufficent for all password requirements.
    $RandomList1 += Invoke-Generate "##"
    $RandomList1 += Invoke-Generate "[WordList]" -CustomData $custom
    $RandomList1 += $PassPhrase
    $RandomList1 += Invoke-Generate "[Specials]" -CustomData $custom
    $RandomList1 += Invoke-Generate "[Specials]" -CustomData $custom
    $RandomList1 += Invoke-Generate "[Specials]" -CustomData $custom

    -join ($RandomList1 | sort-object { Get-Random })
}
else {
    $RandomList1 += Invoke-Generate "[Specials]" -CustomData $custom
    $RandomList1 += $PassPhrase
    $RandomList1 += Invoke-Generate "###"
    $RandomList1 += Invoke-Generate "[Specials]" -CustomData $custom

    -join $RandomList1
}