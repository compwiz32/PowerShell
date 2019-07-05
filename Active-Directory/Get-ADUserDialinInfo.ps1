function Get-ADUserDialinInfo {
    
    <#
    .SYNOPSIS
        Returns dialin permission status from Active Directory for one or more user accounts.

    .DESCRIPTION
        Returns dialin permission status from Active Directory for one or more user accounts. Reads the AD value 
        msNPAllowDialin and displays the the current value, which would be a boolean (True or False). Function 
        reformats the True/False value to a more user friendly 'Enabled/'Disabled' output. 

    .PARAMETER UserName
        Specifies a computer to add the users to. Multiple computers can be specificed with commas and single quotes
        (-Computer 'Server01','Server02')

    .EXAMPLE
        Add-MKLocalGroupMember -Computer Server01 -Account Michael_Kanakos -Group Administrators

        Description:
        Will add the account named Michael_Kanakos to the local Administrators group on the computer named Server01

    .EXAMPLE
        Add-MKLocalGroupMember -Computer 'Server01','Server02' -Account HRManagers -Group 'Remote Desktop Users'

        Description:
        Will add the HRManagers group as a member of Remote Desktop Users group on computers named Server01 and Server02


    .NOTES
        Name       : Add-MKLocalGroupMember.ps1
        Author     : Mike Kanakos
        Version    : 3.0.3
        DateCreated: 2018-12-03
        DateUpdated: 2019-06-30

        LASTEDIT:
        - rename cmdlet name from "Add-LocalGroupMember" to "Add-MKlocalGroupMember"
        - rename file name from "Add-LocalGroupMember.ps1 to Add-MKLocalGroupMember.ps1
        - the renames are to avoid name collisons with built cmdlets

    .LINK
        https://github.com/compwiz32/PowerShell
        
    #>  
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True,Position=0)]
        [alias("User","Name","Account")] 
        [string[]]$Username
    )
    
    begin {
        
        Get-ADUser $Username -Properties msNPAllowDialin | Select-Object samaccountname, msNPAllowDialin

    }
    
    process {
        
    }
    
    end {
        
    }
}



Get-ADUser CaryStaffing -Properties msNPAllowDialin | select samaccountname, msNPAllowDialin