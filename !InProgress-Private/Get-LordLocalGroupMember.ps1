<#
.SYNOPSIS
    Returns local group members from a specified server or client pc.
.DESCRIPTION
    This function lists the members of a local group. By default it queries the local administrators
    group. You can specify the name of the local group (i.e. Remote Desktop users") and you can 
    also run the query against mulitple computers at one time. If no computer is specified then 
    it will query the local computer.
.EXAMPLE
    Get-LordLocalGroupMember

    
.EXAMPLE
    Get-LordLocalGroupMember -group "Remote Desktop Users" -computername 
#>
function verb-noun {
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [parameter(Mandatory=$false,
        ValueFromPipeline=$true)]
        [string]$Group = "Administrators"

    )
    
    begin {

    }
    
    process {
        net localgroup $Group | 
        where {$_ -AND $_ -notmatch "command completed successfully"} | 
        select -skip 4
    }
    
    end {
    }
}