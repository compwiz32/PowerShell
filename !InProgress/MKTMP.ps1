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