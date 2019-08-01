Function Set-LanmanServerSharesFilePath {

    <#
    .Synopsis
        Sets (or changes) the file path for Windows shares in the registry for the LanmanServerSharesFilePath reg key

    .Description
        Sets (or changes) the file path for Windows shares in the registry for the LanmanServerSharesFilePath reg key.
        Use this function to update file paths in bulk for Windows shares.

    .Example
        Set-LanmanServerSharesFilePath -OldPath c:\ -NewPath d:\
        
        Finds shares in Set-LanmanServerSharesFilePath reg key that match the old path and updates the value with the 
        new path

    .Parameter OldFilePath
        Existing file path in regkey named Set-LanmanServerSharesFilePath

    .Parameter OldFilePath
        New file path that will be updated in Set-LanmanServerSharesFilePath


    .Notes
        NAME:        Set-LanmanServerSharesFilePath.ps1
        AUTHOR:      Mike Kanakos
        VERSION:     1.0.0
        DateCreated: 2019-07-31
        DateUpdated: 2019-07-31

        v 1.0.0 - initial function build

    .Link
        https://github.com/compwiz32/PowerShell

        Originally found at https://martin77s.wordpress.com/2014/12/21/changing-shared-folders-path/

#>

    [cmdletbinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $True, Position = 0)]
        [String]$OldFilePath,
        
        [Parameter(Mandatory = $True, Position = 1)]
        [String]$NewFilePath
    )
 
    $RegPath = 'HKLM:SYSTEM\CurrentControlSet\Services\LanmanServer\Shares'

    dir -Path $RegPath | Select-Object -ExpandProperty Property | ForEach-Object {
        $ShareName = $_
        $ShareData = Get-ItemProperty -Path $RegPath -Name $ShareName |
        Select-Object -ExpandProperty $ShareName
        if ($ShareData | Where-Object { $_ -eq "Path=$OldFilePath" }) {
            $ShareData = $ShareData -replace [regex]::Escape("Path=$OldFilePath"), "Path=$NewFilePath"
 
            if ($PSCmdlet.ShouldProcess($ShareName, 'Change-SharePath')) {
                Set-ItemProperty -Path $RegPath -Name $ShareName -Value $ShareData
            } #end if Set-ItemProperty
        } #end If $sharedata
    } #end ForEach
} #end Function
 