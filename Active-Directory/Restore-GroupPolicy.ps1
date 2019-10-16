function Restore-GroupPolicy {
<#
    .SYNOPSIS
        Restores a Group Policy from a previous GPO backup.


    .DESCRIPTION
        Restores a Group Policy from a previous GPO backup.

        This function is intended to be used with backups created by Backup-GroupPolicy cmdlet written by Mike
        Kanakos. The built-in Restore-GPO cmdlet should be used for restoring backups made from the built-in cmdlet
        named Backup-GPO from Microsoft.

    .PARAMETER Name
        Specifies the folder of the GPO you would like to restore. The folders created by the Backup-GrouPolicy cmdlet will
        be a combination of the Name of the GPo and the BackupID guid of the GPO.

        An example of a valid folder name would be:
        Default Domain Controllers Policy___{697ebe7d-019d-46e6-91c2-c5c85ce3f160}


    .PARAMETER Path
        Specifies the path where the backups currently exist. The path can be a local folder or a network based folder.
        This is a required parameter. Do not end the path with a trailing slash. A slash at the end will cause an error!

        Correct format:
        c:\backups or \\server\share

        Incorrect Format:
        c:\Backups\ or \\server\share\

    .PARAMETER Domain
        Specifies the domain to look for Group Policies. This is auto populated with the domain info from the PC
        running the cmdlet.


    .PARAMETER Server
        Specifies the name of the domain controller that is contacted to complete the operation.
        You can specify either the fully qualified domain name (FQDN) or the host name. If you do not specify the name
        by using the Server parameter, the primary domain controller (PDC) emulator is contacted.


    .EXAMPLE
        Restore-GroupPolicy -name "Default Domain Policy___{f4c29b97-03d3-45da-894a-e1cf7f68f276}"
        -Path "\\server01\backups\Group-Policy\2019-01-25" -Server DC01

        Description:
        Restores the GPO named Default Domain Policy from the folder named
        Default Domain Policy___{f4c29b97-03d3-45da-894a-e1cf7f68f276}. The GPO is restored to the domain controller
        named DC01.

        The domain name is auto-added to the back-end code without requiring input from console.


    .NOTES
        Name       : Restore-GroupPolicy.ps1
        Author     : Mike Kanakos
        Version    : 1.0.2
        DateCreated: 2019-01-25
        DateUpdated: 2019-01-26

    .LINK
        https://github.com/compwiz32/PowerShell
#>

[CmdletBinding(SupportsShouldProcess=$true)]
param (
    [Parameter(Mandatory=$True,Position=0,
    HelpMessage="Enter the folder name of the GPO that needs to be restored")]
    [alias("GroupPolicy","GPO","FolderName")]
    [string]
    $Name,

    [Parameter()]
    [string]
    $Path,

    [Parameter()]
    [string]
    $Domain = $env:USERDNSDOMAIN,

    [Parameter()]
    [string]
    $Server
    )

    #Variable to hold the concatenated full original path
    $FullOriginalPath = $path + "\" + $Name

    #Create temp variables to hold just the GUID two different ways
    $TempFolderName = $Name -replace '^.+_{3}'
    $GUID = $TempFolderName -replace '^\{|\}$'

    #Create a temp variable to hold the temporary updated full path
    $FullTempPath = $path + "\" + $TempFolderName


    $Connection = Test-path $FullOriginalPath

    If(!($Connection)) {
        Write-Warning "Folder " $FullOriginalPath "is not reachable!"
        } #end if

    Else {

        #Rename the specified GPO folder to just the GUID
        Rename-item  $FullOriginalPath -newname $FullTempPath

        Restore-GPO -BackupID $GUID -Path $path -Domain $Domain -Server $Server

        #Rename the folder from a GUID back to the original folder name
        Rename-item  $FullTempPath -newname $FullOriginalPath

    } #end else


} #end of function
