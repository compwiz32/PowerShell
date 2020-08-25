function Get-ADObjectOwner {

    <#
    .SYNOPSIS
        Retrieves the owner information of an object from Active Directory

    .DESCRIPTION
        Retrieves the owner information of an object from Active Directory. Can find the owner info for a user,
        computer, group or diistinguished name.

    .PARAMETER User
        The name of a user object in Active Directory to lookup.

    .PARAMETER Computer
        The name of a computer object in Active Directory to lookup.

    .PARAMETER Group
        The name of a group object in Active Directory to lookup.

    .PARAMETER DistinguishedName
        The distinguished name of an Active Directory object to lookup. This is useful for looking up owner
        information for an Active Directory OU or miscellaneous AD object.

    .EXAMPLE
        PS C:\> Get-ADObjectOwner -user mkanakos

        User     Owner
        ----     -----
        mkanakos CONTOSO\Domain Admins

        Returns the owner info for the user named MKANAKOS.

    .EXAMPLE
        PS C:\> Get-ADObjectOwner -computer DC01, DC02

        Computer   Owner
        --------   -----
        DC01       CONTOSO\Domain Admins
        DC02       CONTOSO\Domain Admins

        Returns the owner information for two computers.

    .EXAMPLE
        PS C:\> Get-ADObjectOwner -group "Domain Users"

        Group        Owner
        -----        -----
        Domain Users BUILTIN\Administrators

        Returns the owner information for the "domain users" group.

    .EXAMPLE
        PS C:\> Get-ADObjectOwner -distinguishedname "CN=MKTestUser1,OU=MKTestOU,DC=contoso,DC=com"

        ADObject                          Owner
        --------                          -----
        CONTOSO.com/MKTestOU/MKTestUser1  CONTOSO\mkanakos

        Returns the owner information for a specific AD object.

    .NOTES
        NAME:        Get-ADObjectOwner.ps1
        AUTHOR:      Mike Kanakos
        DateCreated: 2020-08-04

    #>

    [CmdletBinding(DefaultParameterSetName = "DistinguishedName")]
    param (
        [Parameter(Mandatory, Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'User',
            HelpMessage = "Enter the name of an AD user account to lookup")]
        [ValidateNotNullOrEmpty()]
        [string[]]$User,

        [Parameter(Mandatory,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'Computer',
            HelpMessage = "Enter the name of an AD computer account to lookup")]
        [ValidateNotNullOrEmpty()]
        [String[]]$Computer,

        [Parameter(Mandatory,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'Group',
            HelpMessage = "Enter the name of an AD group to lookup")]
        [ValidateNotNullOrEmpty()]
        [String[]]$Group,

        [Parameter(
            Mandatory,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'DistinguishedName',
            HelpMessage = "The DN of an the object you want to get owner for")]
        [ValidateNotNullOrEmpty()]
        [string[]]$DistinguishedName
    )

    begin {}

    process {

        switch ($PSCmdlet.ParameterSetName) {
            user {
                foreach ($item in $User) {
                    $DistinguishedName = (Get-ADUser $item).DistinguishedName
                    $lookup = (Get-ADObject $($DistinguishedName) -Properties ntsecuritydescriptor | Select-Object -ExpandProperty ntsecuritydescriptor).owner
                    $results = [PSCustomObject]@{
                        User  = $item
                        Owner = $lookup
                    }
                    $results
                } #end foreach
            } #end user switch
            computer {
                foreach ($item in $Computer) {
                    $DistinguishedName = (Get-ADComputer $item).DistinguishedName
                    $lookup = (Get-ADObject $($DistinguishedName) -Properties ntsecuritydescriptor | Select-Object -ExpandProperty ntsecuritydescriptor).owner
                    $results = [PSCustomObject]@{
                        Computer = $item
                        Owner    = $lookup
                    }
                    $results
                } #end foreach
            } #end computer switch
            Group {
                foreach ($item in $Group) {
                    $DistinguishedName = (Get-ADGroup $item).DistinguishedName
                    $lookup = (Get-ADObject $($DistinguishedName) -Properties ntsecuritydescriptor | Select-Object -ExpandProperty ntsecuritydescriptor).owner
                    $results = [PSCustomObject]@{
                        Group = $item
                        Owner = $lookup
                    }
                    $results
                } #end foreach
            } #end Group switch

            Default {
                foreach ($item in $DistinguishedName) {
                    $lookup = Get-ADObject $item -Properties ntsecuritydescriptor, canonicalname
                    $results = [PSCustomObject]@{
                        ADObject = $Lookup.canonicalname
                        Owner    = $($lookup | Select-Object -ExpandProperty ntsecuritydescriptor).owner
                    }
                    $results
                } #end foreach
            } #end default switch
        } #end Switch statement
    } #end process block

    end {}
} #end of function
