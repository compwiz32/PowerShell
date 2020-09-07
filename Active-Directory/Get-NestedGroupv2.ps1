function Get-NestedGroup {

    <#
    .SYNOPSIS
        Gets a list of nested groups inside an Active Directory group

    .DESCRIPTION
        Gets a list of nested groups inside an Active Directory group using LDAPFilter

    .PARAMETER Group
        The name of an Active Directory group

    .PARAMETER Server
        The name of Domain controller to use for query. Valid entries are a server name or servername:3268 for a
        Global Catalog query.

    .EXAMPLE
        PS C:\> get-nestedgroup "Server Admins"

        ParentGroup            : Server Admins
        NestedGroup            : NYC Server Admins
        NestedGroupMemberCount : 8
        ObjectClass            : group
        ObjectPath             : contoso.com/Groups/NYC Server Admins
        DistinguishedName      : CN=NYC Server Admins,OU=Groups,DC=contoso,DC=com

        Returns the nested groups that are inside the group named "Server Admins".

        NOTE: NestedGroupMemberCount is the number of objects (aka members) inside the nested group.
        In this example, "NYC Server Admins" contains 8 objects. This number IS NOT the number of nested groups
        inside NYC Server Admins.

    .EXAMPLE

        PS C:\> $selectprops = "ParentGroup","NestedGroup","NestedGroupMemberCount"
        PS C:\> Get-NestedGroup "Exchange Recipient Administrators" | Select-Object $selectprops | format-table

        ParentGroup                       NestedGroup                          NestedGroupMemberCount
        -----------                       -----------                          ----------------------
        Exchange Recipient Administrators Exchange Organization Administrators                      5
        Exchange Recipient Administrators Global Service Desk                                     117
        Exchange Recipient Administrators Mail Admins                                               1

        Returns the nested groups in a table format. Uses a variable to specify the parameters for Select-Object

    .EXAMPLE
        PS C:\> Get-NestGroup $NYCGrps | Format-Table

        There are no nested groups inside NYC-Desktops
        There are no nested groups inside NYC-Servers
        There are no nested groups inside NYC-Laptops
        There are no nested groups inside NYC-Admins
        There are no nested groups inside NYC-HelpDesk

        Checks the six groups saved in the variable $NYCGrps for nested groups. In this example, none of
        six groups have any nested groups.

    .INPUTS
        Inputs (if any)
    .OUTPUTS
        Output (if any)
    .NOTES
        AUTHOR:      Mike Kanakos
        VERSION:     1.0.4
        DateCreated: 2020-04-15
        DateUpdated: 2019-07-28
    #>

    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName, Mandatory = $True)]
        [String[]]$Group,

        [Parameter()]
        [String]$Server = (Get-ADReplicationsite | Get-ADDomainController -SiteName $_.name -Discover -ErrorAction SilentlyContinue).name
    )

    begin { }


    process {
        foreach ($item in $Group) {
            $ADGrp = Get-ADGroup -Identity $item -Server $Server
            $QueryResult = Get-ADGroup -LDAPFilter "(&(objectCategory=group)(memberof=$($ADGrp.DistinguishedName)))" -Properties canonicalname -Server $Server
            if ( $null -ne $QueryResult) {
                foreach ($grp in $QueryResult) {
                    $GrpLookup = Get-ADGroup -Identity "$($Grp.DistinguishedName)" -Properties Members, CanonicalName -Server $Server

                    $NestedGroupInfo = [PSCustomObject]@{
                        'ParentGroup'            = $item
                        'NestedGroup'            = $Grp.Name
                        'NestedGroupMemberCount' = $GrpLookup.Members.count
                        'ObjectClass'            = $Grp.ObjectClass
                        'ObjectPath'             = $GrpLookup.CanonicalName
                        'DistinguishedName'      = $GrpLookup.DistinguishedName
                    } #end PSCustomObject

                    $NestedGroupInfo
                } #end of foreach inside if statement
            }
            else {
                Write-Information "There are no nested groups inside $item" -InformationAction Continue
            } #end if/else

            # checking for groups of nested groups
            foreach ($NestedGrp in $QueryResult) {
                $NestedQueryResult = Get-ADGroup -LDAPFilter "(&(objectCategory=group)(memberof=$($ADGrp.DistinguishedName)))" -Properties canonicalname -Server $Server

                If ($null -ne $NestedQueryResult) {
                    foreach ($SubGrp in $NestedQueryResult) {
                        $SubGrpLookup = Get-ADGroup -Identity "$($SubGrp.DistinguishedName)" -Properties Members, CanonicalName -Server $Server
                    }

                    $SubNestedGroupInfo = [PSCustomObject]@{
                        'ParentGroup'            = $NestedGrp
                        'NestedGroup'            = $SubGrp.Name
                        'NestedGroupMemberCount' = $SubGrpLookup.Members.count
                        'ObjectClass'            = $SubGrp.ObjectClass
                        'ObjectPath'             = $SubGrpLookup.CanonicalName
                        'DistinguishedName'      = $SubGrpLookup.DistinguishedName
                    } #end PSCustomObject

                    $SubNestedGroupInfo
                }
                else {
                    Write-Information "There are no nested groups inside $NestedGrp" -InformationAction Continue
                } #end if/else
            }
        } #end parent foreach
    } #end process block

    end {}
}#end function
