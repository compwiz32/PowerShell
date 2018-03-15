Function Get-FolderPathLength {

    <#
  .Synopsis
    Counts the length of a folder path and returns the total character length and the complete file path + file name.

  .Description
    Counts the length of a folder path and returns the total character length and the complete file path + file name.

  .Example
    Get-FolderPathLength c:\Intel
    Counts the folder length of the folder C:\fonts and all files one level below and returns the complete file path + file name
    and the character count of the path for each file or folder.

   PS C:\> Get-FolderPathLength 'C:\Users\michael_kanakos\OneDrive - LORD Corporation\Fonts\'

    PS C:\> Get-FolderPathLength C:\Fonts

    FullName             Characters
    --------             ----------
    C:\Fonts\dejavu-sans         20
    C:\Fonts\roboto              15




  .Example
    Get-FolderPathLength c:\Intel -recurse
    Counts the folder length of the folder C:\fonts and all sub-folers and files. It then returns the complete file path + file name
    and the character count of the path for each file or folder.

    PS C:\Scripts\Git-Repo\powershell> Get-FolderPathLength C:\Fonts\ -recurse

    FullName                                                 Characters
    --------                                                 ----------
    C:\Fonts\dejavu-sans                                             20
    C:\Fonts\roboto                                                  15
    C:\Fonts\dejavu-sans\DejaVu Fonts License.txt                    45
    C:\Fonts\dejavu-sans\DejaVuSans-Bold.ttf                         40
    C:\Fonts\dejavu-sans\DejaVuSans-BoldOblique.ttf                  47
    C:\Fonts\dejavu-sans\DejaVuSans-ExtraLight.ttf                   46
    C:\Fonts\dejavu-sans\DejaVuSans-Oblique.ttf                      43
    C:\Fonts\dejavu-sans\DejaVuSans.ttf                              35
    C:\Fonts\dejavu-sans\DejaVuSansCondensed-Bold.ttf                49
    C:\Fonts\dejavu-sans\DejaVuSansCondensed-BoldOblique.ttf         56
    C:\Fonts\dejavu-sans\DejaVuSansCondensed-Oblique.ttf             52
    C:\Fonts\dejavu-sans\DejaVuSansCondensed.ttf                     44
    C:\Fonts\roboto\Apache License.txt                               34
    C:\Fonts\roboto\Roboto-Black.ttf                                 32
    C:\Fonts\roboto\Roboto-BlackItalic.ttf                           38
    C:\Fonts\roboto\Roboto-Bold.ttf                                  31
    C:\Fonts\roboto\Roboto-BoldItalic.ttf                            37
    C:\Fonts\roboto\Roboto-Italic.ttf                                33
    C:\Fonts\roboto\Roboto-Light.ttf                                 32
    C:\Fonts\roboto\Roboto-LightItalic.ttf                           38
    C:\Fonts\roboto\Roboto-Medium.ttf                                33
    C:\Fonts\roboto\Roboto-MediumItalic.ttf                          39
    C:\Fonts\roboto\Roboto-Regular.ttf                               34
    C:\Fonts\roboto\Roboto-Thin.ttf                                  31
    C:\Fonts\roboto\Roboto-ThinItalic.ttf                            37
    C:\Fonts\roboto\RobotoCondensed-Bold.ttf                         40
    C:\Fonts\roboto\RobotoCondensed-BoldItalic.ttf                   46
    C:\Fonts\roboto\RobotoCondensed-Italic.ttf                       42
    C:\Fonts\roboto\RobotoCondensed-Light.ttf                        41
    C:\Fonts\roboto\RobotoCondensed-LightItalic.ttf                  47
    C:\Fonts\roboto\RobotoCondensed-Regular.ttf                      43


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





