<#
Find and fix broken permissions inheritance.

All envrionments perform differently. Please test this code before using it
in production.

THIS CODE AND ANY ASSOCIATED INFORMATION ARE PROVIDED “AS IS” WITHOUT WARRANTY 
OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE 
IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR
PURPOSE. THE ENTIRE RISK OF USE, INABILITY TO USE, OR RESULTS FROM THE USE OF 
THIS CODE REMAINS WITH THE USER.

Author: Aaron Guilmette
		aaron.guilmette@microsoft.com
#>

<#
.SYNOPSIS
Find objects without permissions inheritance enabled and optionally
update.

.DESCRIPTION
This script will search Active Directory for objects with permissions
inheritance disabled.

.PARAMETER Confirm
Confirm changes to Active Directory objects.

.PARAMETER Identity
Optionally specify sAMAccountName or distinguishedDName of a user to check.

.PARAMETER Logfile
Specify logfile for operations.

.PARAMETER SearchBase
Set the BaseDN for the search query.  Defaults to the DN of the current
domain.

.EXAMPLE
.\Fix-BrokenInheritance.ps1 -LogFile output.txt
Find objects with disabled inheritance and output to logfile output.txt.

.EXAMPLE
.\Fix-BrokenInheritance.ps1 -Logfile output.txt -Confirm
Find objects with disabled inheritance, update them, and log changes
to output.txt.

.EXAMPLE
.\Fix-BrokenInheritance.ps1 -Identity "CN=Joe,CN=Users,DC=contoso,DC=com"
Checks object CN=Joe for disabled inheritance.

.LINK
https://gallery.technet.microsoft.com/Find-and-Fix-Broken-Object-5ae18ab1

#>
Param(
    [Parameter(Mandatory=$false,HelpMessage="Active Directory Base DN")]
		[string]$SearchBase = (Get-ADDomain).DistinguishedName,
	[Parameter(Mandatory=$false,HelpMessage="Log File")]
		[string]$LogFile,
	[Parameter(Mandatory=$false,HelpMessage="Enter User ID (sAMAccountName or DN)")]
		[string]$Identity,
    [Parameter(Mandatory=$false,HelpMessage="Confirm")]
        [switch]$Confirm
	)

If (!(Get-Module ActiveDirectory))
	{
	Import-Module ActiveDirectory
	}

# Start Logfile
If ($LogFile)
	{
	$head = """" + "DistinguishedName" + """" + "," + """" + "UPN" + """" + "," + """" + "InheritanceDisabled-Before" + """" + "," + """" + "InheritanceDisabled-After" + """" + "," + """" + "adminSDHolderProtected" + """"
	$head | Out-File $LogFile
	}

# Instantiate Directory Searcher
If (!($Identity))
	{
	$DirectorySearcher = New-Object System.DirectoryServices.DirectorySearcher([ADSI]"LDAP://$SearchBase","(&(objectcategory=user)(objectclass=user))")
	}
Else
	{
	Write-Host "Searching for User $($Identity)"
	If ($Identity -like "CN=*")
        {
        $DirectorySearcher = New-Object System.DirectoryServices.DirectorySearcher([ADSI]"LDAP://$Identity")
	    }
    Else
        {
        $DirectorySearcher = New-Object System.DirectoryServices.DirectorySearcher([ADSI]"LDAP://$SearchBase","(&(objectcategory=user)(objectclass=user)(samaccountname=$($Identity)))")
	    }
    }

# Find All Matching Users
$Users = $DirectorySearcher.FindAll()

Foreach ($obj in $users)
    {
    # Set 'objBefore' to the current object so we can track any changes
    $objBefore = $obj.GetDirectoryEntry()
    
    # Check to see if user has Inheritance Disabled; $True is inheritance disabled, $False is inheritance enabled
    If ($objBefore.psBase.ObjectSecurity.AreAccessRulesProtected -eq $True)
        {
        Write-Host "User: $($objBefore.sAMAccountName) Inheritance is disabled: $($objBefore.psBase.ObjectSecurity.AreAccessRulesProtected) ; adminSDHolder: $($objBefore.Properties.AdminCount)"
        $objBeforeACL = $($objBefore.psBase.ObjectSecurity.AreAccessRulesProtected)
        #$user.psBase.ObjectSecurity | GM "*get*access*"
        
        # If Confirm switch was enabled to make changes
        If ($Confirm)
            {
            Write-Host -ForegroundColor Green "Updating $($objBefore.sAMAccountName)."
            $objBefore.psbase.ObjectSecurity.SetAccessRuleProtection($false,$true)
            $objBefore.psbase.CommitChanges()
            }
        
        # Set 'objAfter' so we can see the updated change
        $objAfter = $obj.GetDirectoryEntry()
        $objAfterACL = $($objAfter.psBase.ObjectSecurity.AreAccessRulesProtected)
        
        # If logging is enabled, write a log file
        If ($LogFile)
		    {
		    $LogData = """" + $objBefore.DistinguishedName + """" + "," + """" + $objBefore.UserPrincipalName + """" + "," + """" + $objBeforeACL + """" + "," + """" + $objAfterACL + """" + "," + """" + $objBefore.Properties.AdminCount + """"
		    $LogData | Out-File $LogFile -Append
		    }
        }
    Else
        {
        # User has inheritance enabled, so do nothing
        }
    }