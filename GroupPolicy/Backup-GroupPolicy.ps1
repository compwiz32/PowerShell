function Backup-GroupPolicy {
<#
    .SYNOPSIS
    Backs up all existing Group Policies to a folder

    .DESCRIPTION
    Backs up all group policies to a folder named after the current date. Each group policy is saved in
    its own sub folder. The folder name will be the name of the group policy.

    Folder Name Example:
    --------------------
    C:\GPBackup\2018-12-21\Default Domain Policy


    .PARAMETER Path
    Specifies the path where the backups will be saved. The path can be a local folder or a network based folder.
    This is a required parameter. Do not end the path with a trailing slash. A slash at the end will cause an error!

    Correct format:
    c:\backups or \\server\share

    Incorrect Format:
    c:\Backups\ or \\server\share\

    .PARAMETER Domain
    Specifies the domain to look for Group Policies. If not entered, the domain that PC running the cmdlet is
    joined to will be selected.

    .PARAMETER Server
    Specifies the Domain Controller to query for group Policies to backup

    .EXAMPLE
    Backup-GroupPolicy -path C:\Backup

    Description:
    Performs a backup of the GPO's and saves them to the c:\backups folder. Since no server was specified, the code will
    search for the nearest Domain Controller.

    .EXAMPLE
    Backup-GroupPolicy -path C:\Backup -Domain nwtraders.local -Server DC01

    Description:
    Will backup GPO's in the nwtraders.local domain to the C:\Backups folder. The backups will be pulled from
    the DC named DC01.


    .NOTES
    Name       : Backup-GroupPolicy.ps1
    Author     : Mike Kanakos
    Version    : 1.0.1
    DateCreated: 2018-12-19
    DateUpdated: 2018-12-21

    .LINK
    https://https://github.com/compwiz32/PowerShell
#>

[CmdletBinding(SupportsShouldProcess=$true)]
param (
    [Parameter(Mandatory=$True,Position=0)]
    [string]
    $Path,

    [Parameter()]
    [string]
    $Domain = (Get-WmiObject Win32_ComputerSystem).Domain,

    [Parameter()]
    [string]
    $Server
    )

    begin {

        # Get current GPO information
        $GPOInfo = Get-GPO -All -Domain $domain -Server $Server


        #Create a date-based folder to save backup of group policies
        $Date = Get-Date -UFormat "%Y-%m-%d"
        $UpdatedPath = "$path\$date"

        New-item $UpdatedPath -ItemType directory | Out-Null

        Write-Host "GPO's will be backed up to $UpdatedPath"
        }

    process {

        ForEach ($GPO in $GPOInfo) {

            #Assign temp variables for various parts of GPO data
            Write-Host "Backing up GPO named: " $GPO.Displayname
            $BackupInfo = Backup-GPO -Name $GPO.DisplayName -Domain $Domain -path $UpdatedPath -Server $Server
            $GpoBackupID = $BackupInfo.ID.Guid
            $GpoGuid = $BackupInfo.GPOID.Guid
            $GpoName = $BackupInfo.DisplayName
            $CurrentFolderName = $UpdatedPath + "\" + "{"+ $GpoBackupID + "}"
            $NewFolderName = $UpdatedPath + "\" + $GPOName

            #rename the newly created GPO backup sub folder from it's GPO ID to the GPO Displayname
            rename-item $CurrentFolderName -newname $NewFolderName

        }

    }

    end {
    }
}
