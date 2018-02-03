$ou = "OU=Users,OU=Saegertown,OU=North_America,DC=LORD,DC=LOCAL"
$users = Get-ADUser -Filter {Enabled -eq $true} -SearchBase $ou -Properties MemberOf, PrimaryGroup
$dugDn = (Get-ADGroup "SG-Zscaler-Test").DistinguishedName
foreach ($user in $users)
{
    Write-Verbose "Working on $($user.Name)"
    $groups = $user.MemberOf, $user.PrimaryGroup
    if ($dugDn -notin $groups)
    {
        Write-Error -Message "$($user.SamAccountName) not in the Zscaler test group"
    }
}