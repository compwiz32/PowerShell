$Params = @{
    Path            = '.\PowerShell.png'
    FocusWord       = 'PowerShell'
    StrokeWidth     = 1
    StrokeColor     = 'MidnightBlue'
    ImageSize       = 4096
    BackgroundColor = 'Transparent'
    Padding         = 2
    MaxUniqueWords  = 250
}
$PSCoreCode | New-WordCloud @Params


$colors = [enum]::GetValues([System.ConsoleColor])

Foreach ($bgcolor in $colors){
    Foreach ($fgcolor in $colors) { Write-Host "$fgcolor|"  -ForegroundColor $fgcolor -BackgroundColor $bgcolor -NoNewLine }

    Write-Host " on $bgcolor"

}

 rainbow 1
