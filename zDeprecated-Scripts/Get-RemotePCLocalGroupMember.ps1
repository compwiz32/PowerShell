Function Get-RemotePCLocalGroupMember {
    <#
    .SYNOPSIS
    This function lists the members of a local group on a remote PC

    .DESCRIPTION
    This function lists the members of a local group. By default it queries the local administrators group.
    You can specify the name of the local group (i.e. Remote Desktop users") and you can also run the query against
    mulitple computers at one time.If no computer is specified then it will query the local computer.

    .EXAMPLE
    Get-Get-RemotePCLocalGroupMember -Group "remote desktop users" -Computername Server01

    .EXAMPLE
    Get-Get-RemotePCLocalGroupMember-Group "administrators" -Computername Srvwin0979 | select-object -expandproperty members

    This command will get the members of the local admins group and display the full list (not truncated).

    .EXAMPLE
    Get-Get-RemotePCLocalGroupMember -Group "remote desktop users" -Computername $sessions



    Group: remote desktop users
    Computername : CHI-FP01
    Members:

    Group: remote desktop users
    Computername : CHI-WIN8-01
    Members:

    Computername : CHI-EX01
    Members:
    Group: remote desktop users

    Group: remote desktop users
    Computername : CHI-DC01
    Members: jfrost


    .NOTES
    NAME: Get-RemotePCLocalGroupMember
    AUTHOR: Mike Kanakos
    CREATED: 2016-06-22
    UPDATED: 2017-10-27
    ## changed function name to not conflict with built PS function



    Based 100% on script by Jeffrey Hicks found at:
    https://powershell.org/get-local-admin-group-members-in-a-new-old-way-3/
#>

    [cmdletbinding()]

    Param(
        [Parameter(Position = 0)]
        [ValidateNotNullorEmpty()]
        [object[]]$Computername = $env:computername,
        [ValidateNotNullorEmpty()]
        [string]$Group = "Administrators",
        [switch]$Asjob
    )

    Write-Verbose "Getting members of local group $Group"

    #define the scriptblock
    $sb = {
        Param([string]$Name = "Administrators")
        $members = net localgroup $Name |
            where {$_ -AND $_ -notmatch "command completed successfully"} |
            select -skip 4
        New-Object PSObject -Property @{
            Computername = $env:COMPUTERNAME
            Group        = $Name
            Members      = $members
        }
    } #end scriptblock

    #define a parameter hash table for splatting
    $paramhash = @{
        Scriptblock      = $sb
        HideComputername = $True
        ArgumentList     = $Group
    }

    if ($Computername[0] -is [management.automation.runspaces.pssession]) {
        $paramhash.Add("Session", $Computername)
    }
    else {
        $paramhash.Add("Computername", $Computername)
    }

    if ($asjob) {
        Write-Verbose "Running as job"
        $paramhash.Add("AsJob", $True)
    }

    #run the command
    Invoke-Command @paramhash | Select * -ExcludeProperty RunspaceID

} #end of function