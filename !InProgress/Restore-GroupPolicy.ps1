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
    Specifies the domain to look for Group Policies. This is auto populated with the domain info from the PC running
    the cmdlet.


    .PARAMETER Server
    Specifies the name of the domain controller that is contacted to complete the operation.
    You can specify either the fully qualified domain name (FQDN) or the host name. If you do not specify the name
    by using the Server parameter, the primary domain controller (PDC) emulator is contacted.


    .EXAMPLE
    Backup-GroupPolicy -path C:\Backup

    Description:
    This example creates a backup of the GPO's and saves them to the c:\backup folder.
    Since no server was specified, the code will search for the nearest Domain Controller.

    .EXAMPLE
    Backup-GroupPolicy -path C:\Backup -Domain nwtraders.local -Server DC01

    Description:
    This example creates a backup of GPO's in the nwtraders.local domain to the C:\Backup folder.
    The backups will be pulled from the DC named DC01.


    .NOTES
    Name       : Restore-GroupPolicy.ps1
    Author     : Mike Kanakos
    Version    : 1.0.1
    DateCreated: 2019-01-25
    DateUpdated: 2019-01-25

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
    $Domain = (Get-WmiObject Win32_ComputerSystem).Domain,

    [Parameter()]
    [string]
    $Server
    )

    try{
        $Connection = test-path $path

        If(!($Connection)) {
          Write-Warning "Folder " $path + "\" + $Name  "is not reachable!"
          } #end if

        Else {}

       #Create a temp variable to hold just the GUID of part of folder name
       $TempFolderName = $Name -replace '^.+_{3}'

       #Rename the specified GPO folder to just the GUID
       Rename-item  $Path + "\" + $Name -newname $path + "\" + $TempFolderName

       Restore-GPO -Name $Name -Path $path -Domain $Domain -Server $Server

       #Rename the folder from a GUID back to the original folder name
       Rename-item  $Path + "\" + $TempFolderName -newname $path + "\" + $Name

    }




    begin {

        # Get current GPO information
        $GPOInfo = Get-GPO -All -Domain $domain -Server $Server


        #Create a date-based folder to save backup of group policies
        $Date = Get-Date -UFormat "%Y-%m-%d"
        $UpdatedPath = "$path\$date"

        New-item $UpdatedPath -ItemType directory | Out-Null

        Write-Host "GPO's will be backed up to $UpdatedPath" -backgroundcolor white -foregroundColor red
    } #end of begin block

    process {

        ForEach ($GPO in $GPOInfo) {

            Write-Host "Backing up GPO named: " -foregroundColor Green -nonewline
            Write-Host $GPO.Displayname -foregroundColor White

            #Assign temp variables for various parts of GPO data
            $BackupInfo = Backup-GPO -Name $GPO.DisplayName -Domain $Domain -path $UpdatedPath -Server $Server
            $GpoBackupID = $BackupInfo.ID.Guid
            $GpoGuid = $BackupInfo.GPOID.Guid
            $GpoName = $BackupInfo.DisplayName
            $CurrentFolderName = $UpdatedPath + "\" + "{"+ $GpoBackupID + "}"
            $NewFolderName = $UpdatedPath + "\" + $GPOName + "___" + "{"+ $GpoBackupID + "}"
            $ConsoleOutput = $GPOName + "___" + "{"+ $GpoBackupID + "}"

            #rename the newly created GPO backup sub folder from it's GPO ID to GPO Displayname + GUID
            rename-item $CurrentFolderName -newname $NewFolderName


        } #end ForEach loop

    } #end of process block

    end {
    } #End of End block
} #end of function
