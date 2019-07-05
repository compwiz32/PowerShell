function Get-ADUserDialinInfo {
    
    <#
    .SYNOPSIS
        Returns dial-in permission status from Active Directory for one or more user accounts.

    .DESCRIPTION
        Returns dial-in permission status from Active Directory for one or more user accounts. Reads the AD value 
        'msNPAllowDialin' and displays the the current value, which is a boolean (True or False). Function 
        reformats the True/False value to a more user friendly 'Enabled/'Disabled' output. 

    .PARAMETER UserName
        Specifies a user to query. Multiple users can be queried with commas and single quotes
        (-User 'Mike_Kanakos','Joe_Smith')

    .EXAMPLE
        Get-ADUserDialinInfo -User Mike_Kanakos

        User:           DialInStatus:
        -----           -------------
        Mike_Kanakos    Enabled

    .EXAMPLE
        Get-ADUserDialinInfo -User Mike_Kanakos, Joe_Smith

        User:           DialInStatus:
        -----           -------------
        Mike_Kanakos    Enabled
        Joe_Smith       Disabled


    .NOTES
        Name       : Get-ADUserDialinInfo.ps1
        Author     : Mike Kanakos
        Version    : 1.0.1
        DateCreated: 2019-07-05
        DateUpdated: 2019-07-05

        LASTEDIT:
        - Scaffold function
        - Build logic and output
    

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
        
    }
    
    process {
        
        $Results = [System.Collections.Generic.List[object]]::new()
        
        foreach ($User in $Username) {
            $results.Add = Get-ADUser $Username -Properties msNPAllowDialin | Select-Object Name, msNPAllowDialin
        }
        
    }
    
    end {
        
    }
}



Get-ADUser CaryStaffing -Properties msNPAllowDialin | select samaccountname, msNPAllowDialin