
$Serverlist = @()
$groups = Get-ADGroup -Filter "Name -like 'Patch*'"

foreach ($patchgroup in $groups) {
    $Serverlist += ((Get-ADGroupMember -Identity "$($patchgroup.name)") |
            Get-Adcomputer -prop managedby, memberof )



        }

foreach ($svr in $serverlist){



}






@{Name = 'ManagedBy'; Expression = {(Get-ADUser ($_.managedBy)).samaccountname}}

