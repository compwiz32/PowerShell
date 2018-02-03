Function Get-FolderLength {

    <#
  .Synopsis
  Counts the length of a folder path and returns the total character length and the complete file path + file name.

  .Description
  Counts the length of a folder path and returns the total character length and the complete file path + file name.

  .Example
  Get-FolderLength c:\Intel
  Counts the folder length of the folder C:\Intel and returns the character count and the complete file path + file name.

PS: C:\> psGet-FolderLength c:\Intel
24 C:\intel\ExtremeGraphics
11 C:\intel\gp
13 C:\intel\Logs
28 C:\intel\ExtremeGraphics\CUI
37 C:\intel\ExtremeGraphics\CUI\Resource
27 C:\intel\Logs\IntelCPHS.log
26 C:\intel\Logs\IntelGFX.log
30 C:\intel\Logs\IntelGFXCoin.log


  .Example
  Get-FolderLength c:\Intel -recurse
  Counts the folder length of the folder C:\scripts and sub-directories and returns a list of the character counts and the
   complete file path + file name for each sub-directory.

PS: C:\> Get-FolderLength c:Iintel -recurse
24 C:\Intel\ExtremeGraphics
11 C:\Intel\gp
13 C:\Intel\Logs
28 C:\Intel\ExtremeGraphics\CUI
37 C:\Intel\ExtremeGraphics\CUI\Resource
27 C:\Intel\Logs\IntelCPHS.log
26 C:\Intel\Logs\IntelGFX.log
30 C:\Intel\Logs\IntelGFXCoin.log

  .Parameter SourceDirectory
  The directory you wish to count the total character length of

  .Parameter Recurse
  switch to scan sub folders of root folder

  .Notes
  NAME: Get-FolderLength
  AUTHOR: Mike Kanakos
  LASTEDIT: 2018-02-01
#>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True, Position = 1, ValueFromPipeline = $True)]
        [string] $SourceDirectory = ".",

        [Parameter()]
        [switch] $Recurse
    )


    #Code
    Get-ChildItem $SourceDirectory -Recurse:$recurse  | ForEach-Object {
        $FilePath = $_.FullName
        Write-Host  $FilePath.Length, $FilePath
    }


} #END OF FUNCTION
