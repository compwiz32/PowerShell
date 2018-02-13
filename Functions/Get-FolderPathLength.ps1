Function Get-FolderPathLength {

    <#
  .Synopsis
    Counts the length of a folder path and returns the total character length and the complete file path + file name.

  .Description
    Counts the length of a folder path and returns the total character length and the complete file path + file name.

  .Example
    Get-FolderPathLength c:\Intel
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
    Get-FolderPathLength c:\Intel -recurse
    Counts the folder length of the folder C:\scripts and sub-directories and returns a list of the character counts and the
    complete file path + file name for each sub-directory.

    PS: C:\> Get-FolderPathLength c:Iintel -recurse
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
    Specifies to scan all sub-folders and files below root directory

  .Parameter File
    Specifies to only scan files and not directories

  .Parameter File
    Specifies to only scan directories

  .Notes
    NAME: Get-FolderPathLength
    AUTHOR: Mike Kanakos
    LASTEDIT: 2018-02-01
#>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True, Position = 1, ValueFromPipeline = $True)]
        [string] $SourceDirectory = ".",

        [Parameter()]
        [switch] $Recurse,

        [Parameter()]
        [switch] $File,

        [Parameter()]
        [switch] $Directory
    )

    #Code
    #Get-ChildItem $SourceDirectory -Recurse:$recurse  | Select-Object FullName, @{Name='Chars';Expression={($_.FullName -split '').Count}}
    Get-ChildItem $SourceDirectory  -Recurse:$recurse -File:$File  -Directory:$Directory  | Select-Object FullName, `
    @{Name = "Characters"; Expression = {$_.fullname.length}}



    #Code
    #Get-ChildItem $SourceDirectory -Recurse:$recurse  | Select-Object FullName, @{Name = 'Chars'; Expression = {($_.FullName -split '').Count}}


} #END OF FUNCTION





