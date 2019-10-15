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
    Specifies the domain to look for Group Policies. This is auto populated with the domain info from the PC running
    the cmdlet.

    .PARAMETER Server
    Specifies the Domain Controller to query for group Policies to backup

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
    Name       : Backup-GroupPolicy.ps1
    Author     : Mike Kanakos
    Version    : 1.1.0
    DateCreated: 2018-12-19
    DateUpdated: 2019-01-25

    .LINK
    https://github.com/compwiz32/PowerShell
#>

[CmdletBinding(SupportsShouldProcess=$true)]
param (
    [Parameter(Mandatory=$True,Position=0)]
    [string]
    $Path,

    [Parameter()]
    [string]
    $Domain = $env:USERDNSDOMAIN,

    # Specify aliases for the Server parameter and support tab completion for domain controller names.
    [Parameter(]
    [Alias("DomainController","DC")]
    [ArgumentCompleter( {
        param ( $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters )
        $possibleValues = @{ Server = (Get-ADDomainController -Filter *).Hostname }
        if ($fakeBoundParameters.ContainsKey('Type')) { $possibleValues[$fakeBoundParameters.Type] | Where-Object { $_ -like "$wordToComplete*" } }
        else { $possibleValues.Values | ForEach-Object {$_} }
    } )]
    $Server

    ) #End of Parameter Declarations

    begin {

        # Get a domain controller if none was specified with by server parameter
        If (-Not $Server) { $Server = (Get-ADDomainController).Hostname }
        
        # Get current GPO information
        $GPOInfo = Get-GPO -All -Domain $domain -Server $Server


        #Create a date-based folder to save backup of group policies
        $Date = Get-Date -UFormat "%Y-%m-%d"
        $UpdatedPath = "$path\$date"

        If (-Not $UpdatedPath) { New-item $UpdatedPath -ItemType directory | Out-Null }

        Write-Host "GPOs will be backed up to $UpdatedPath" -backgroundcolor white -foregroundColor red
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
