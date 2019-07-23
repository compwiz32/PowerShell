# FindEmptyGroups.ps1
# PowerShell Version 2 script to find all empty groups in the domain.
# This will be groups where the member attribute is empty, and also where
# no user or computer has the group designated as their primary group.
# You can select to search for all empty groups, or only empty security groups.
# Author: Richard L. Mueller
# Version 1.0 - November 27, 2016

# Specify the supported parameters.
Param(
    [Switch]$Help,
    [Switch]$Security
)

# Script version and date.
$Version = "Version 1.0 - November 27, 2016"
$Today = Get-Date

# Flag any parameters not recognized and abort the script. Any parameters that do not match
# the supported parameters (specified by the Param statement above) will populate the $Args
# collection, an automatic variable. If all of the parameters supplied are recognized, then
# $Args will be empty.
$Abort = $False
ForEach ($Arg In $Args)
{
    If ($Arg -Like "-*")
    {
        Write-Host "Argument not recognized: $Arg" -ForegroundColor Red -BackgroundColor Black
    }
    Else
    {
        Write-Host "Value not recognized:    $Arg" -ForegroundColor Red -BackgroundColor Black
    }
    $Abort = $True
}
# Breaking out of the above ForEach would not break out of the script. Breaking out
# of the If statment will.
If ($Abort)
{
    # Display a brief help listing the supported parameters.
    Write-Host "Syntax: FindEmptyGroups.ps1 [-Security] [-Help]" `
        -ForegroundColor Yellow -BackgroundColor Black
    Write-Host "For help use FindEmptyGroups.ps1 -Help" `
        -ForegroundColor yellow -BackgroundColor Black
    Break
}

If ($Help)
{
    # User has requested help information.
    "FindEmptyGroups.ps1"
    "$Version"
    "PowerShell script to find all empty groups in the domain."
    "This will be groups with no members, including no users or computers where the group"
    "    is designated as their ""Primary"" group."
    "Parameters"
    "    -Security: A switch, so the script only considers security groups."
    "        Otherwise, the script considers all groups, including distribution groups."
    "    -Help: A switch that outputs this help."
    "Note: The first one (or several) letters of each parameter can be used as aliases."
    "Some usage examples:"
    ".\FindEmptyGroups.ps1 > .\Report.txt"
    "    Find all empty groups in the domain. Redirect output to a text file."
    ".\FindEmptyGroups.ps1 -S"
    "    Find all empty security groups in the domain."
    "Example output:"
    "-----"
    "FindEmptyGroups.ps1"
    "$Version"
    "All empty groups:"
    "Date: 11/25/2016 09:51:55"
    "CN=Contractors,OU=Sales,OU=West,DC=MyDomain,DC=com (ContractorsWest)"
    "cn=Contractors,OU=Sales,OU=East,DC=MyDomain,DC=com (ContractorsEast)"
    "CN=WINS Users,CN=Users,DC=MyDomain,DC=com (WINS Users)"
    "CN=DnsAdmins,CN=Users,DC=MyDomain,DC=com (DnsAdmins)"
    "Total number of empty groups: 4"
    Break
}

If ($Security)
{
    # Retrieve all security groups where the member attribute is empty.
    $Groups = Get-ADGroup `
        -LDAPFilter "(&(groupType:1.2.840.113556.1.4.803:=2147483648)(!(member=*)))" `
        | Select distinguishedName, sAMAccountName, SID
}
Else
{
    # Retrieve all groups where the member attribute is empty.
    $Groups = Get-ADGroup `
        -LDAPFilter "(!(member=*))" `
        | Select distinguishedName, sAMAccountName, SID
}

# Enumerate these groups. Check if any users or computers has them designated as their
# "primary" group. This will be users or computers where the primaryGroupID attribute
# equals the primaryGroupToken attribute of the group.
$Count = 0
If ($Security) {"All empty security groups:"}
Else {"All empty groups:"}
"Date: $Today"
ForEach ($Group In $Groups)
{
    # Retrieve the primaryGroupToken (the RID) of the group.
    # This is an operational (constructed) attribute, so it is easier to parse the SID.
    $SID = [String]$Group.SID
    $RID = $SID.Split("-")[-1]

    # Check if there are any users or computers where the primaryGroupID attribute
    # equals the primaryGroupToken of this group.
    $PrimaryMembers = Get-ADObject -LDAPFilter "(primaryGroupID=$RID)"
    If (-Not $PrimaryMembers)
    {
        # This is a group with no members.
        $DN = $Group.distinguishedName
        $NTName = $Group.sAMAccountName
        # Output the group DN and sAMAccountName.
        "$DN ($NTName)"
        # Count the number of empty groups.
        $Count = $Count + 1
    }
}
"Total number of empty groups: $Count"
