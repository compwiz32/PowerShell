function Resolve-SamAccount {
<#
.SYNOPSIS
    Helper function that resolves SAMAccount
#>
    param(
        [string]
            $SamAccount
    )

    process {
        try
        {
            $ADResolve = ([adsisearcher]"(samaccountname=$Account)").findone().properties['samaccountname']
        }
        catch
        {
            $ADResolve = $null
        }

        if (!$ADResolve) {
            Write-Warning "User `'$SamAccount`' not found in AD, please input correct SAM Account"
        }
        $ADResolve
    }
}

function Set-LocalRDPGroupMembers {
<#
.SYNOPSIS
Script to add an AD User or group to the Remote Desktop Users group

.DESCRIPTION
The script can use either a plaintext file or a computer name as input and will add the Account (user or group) to the Remote Desktop Users group on the computer

.PARAMETER InputFile
A path that contains a plaintext file with computer names

.PARAMETER Computer
This parameter can be used instead of the InputFile parameter to specify a single computer or a series of computers using a comma-separated format

.PARAMETER Account
The SamAccount name of an AD User or AD Group that is to be added to the Remote Desktop Users group

.NOTES
Name       : Set-LocalRDPGroupMembers.ps1
Author     : Mike Kanakos
Version    : 1.0.0
DateCreated: 2017-10-27
Script found at http://www.jaapbrasser.com and modified

.LINK
Script found at http://www.jaapbrasser.com

.EXAMPLE
. .\Set-LocalRDPGroupMembers.ps1

Description
-----------
This command dot sources the script to ensure the Set-LocalRDPGroupMembers function is available in your current PowerShell session

.EXAMPLE
Set-LocalRDPGroupMembers -Computer Server01 -Account JaapBrasser

Description:
Will add the the JaapBrasser account to the Remote Desktop Users group on Server01

.EXAMPLE
Set-LocalRDPGroupMembers -Computer 'Server01','Server02' -Account Contoso\HRManagers

Description:
Will add the HRManagers group in the contoso domain as a member of Remote Desktop Users group on Server01 and Server02

.EXAMPLE
Set-LocalRDPGroupMembers -InputFile C:\ListofComputers.txt -Account User01

Description:
Will add the User01 account to the Remote Desktop Users group on all servers and computernames listed in the ListofComputers file
#>
    param(
        [Parameter(ParameterSetName= 'InputFile',
                   Mandatory       = $true
        )]
        [string]
            $InputFile,
        [Parameter(ParameterSetName= 'Computer',
                   Mandatory       = $true
        )]
        [string[]]
            $Computer,
        [Parameter(Mandatory=$true)]
        [string]
            $Account
    )


    if ($Account -notmatch '\\') {
        $ADResolved = (Resolve-SamAccount -SamAccount $Account)
        $Account = 'WinNT://',"$env:userdomain",'/',$ADResolved -join ''
    } else {
        $ADResolved = ($Account -split '\\')[1]
        $DomainResolved = ($Account -split '\\')[0]
        $Account = 'WinNT://',$DomainResolved,'/',$ADResolved -join ''
    }

    if (!$InputFile) {
	    $Computer | ForEach-Object {
		    Write-Verbose "Adding '$ADResolved' to Remote Desktop Users group on '$_'"
		    try {
			    ([adsi]"WinNT://$_/Remote Desktop Users,group").add($Account)
			    Write-Verbose "Successfully completed command for '$ADResolved' on '$_'"
		    } catch {
			    Write-Warning $_
		    }
	    }
    } else {
	    if (!(Test-Path -Path $InputFile)) {
		    Write-Warning 'Input file not found, please enter correct path'
	    }
	    Get-Content -Path $InputFile | ForEach-Object {
		    Write-Verbose "Adding '$ADResolved' to Remote Desktop Users group on '$_'"
		    try {
			    ([adsi]"WinNT://$_/Remote Desktop Users,group").add($Account)
			    Write-Verbose 'Successfully completed command'
		    } catch {
			    Write-Warning $_
		    }
	    }
    }
}