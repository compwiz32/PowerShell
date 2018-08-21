$group1 = get-adgroup 'Patch-Non_Prod_Group01'
$group2 = get-adgroup 'Patch-Non_Prod_Group02'
$group3 = get-adgroup 'Patch-Prod_Group01'
$group4 = get-adgroup 'Patch-Prod_Group02'
$group5 = get-adgroup 'Patch-Prod_Group03'
$group6 = get-adgroup 'Patch-Prod_Group04'
$group7 = get-adgroup 'Patch-Prod_Crit_Group01'
$group8 = get-adgroup 'Patch-Prod_Crit_Group02'

get-adcomputer -filter 'OperatingSystem -like "*server*"' -prop MemberOf, managedby, description, canonicalname |
Where-Object {
    ( $_.MemberOf -notcontains $Group1.DistinguishedName ) -and
    ( $_.MemberOf -notcontains $Group2.DistinguishedName ) -and
    ( $_.MemberOf -notcontains $Group3.DistinguishedName ) -and
    ( $_.MemberOf -notcontains $Group4.DistinguishedName ) -and
    ( $_.MemberOf -notcontains $Group5.DistinguishedName ) -and
    ( $_.MemberOf -notcontains $Group6.DistinguishedName ) -and
    ( $_.MemberOf -notcontains $Group7.DistinguishedName ) -and
    ( $_.MemberOf -notcontains $Group8.DistinguishedName ) -and
    ( $_.description -notlike '*inactive*') -and
    ( $_.description -notlike '*cluster*') -and
    ( $_.description -notlike '*template*') -and
    ( $_.canonicalname -notlike '*disabled*')

} | Select-Object name, @{Name = 'ManagedBy'; Expression = {(Get-ADUser ($_.managedBy)).samaccountname}}, description, memberof, canonicalname | sort name