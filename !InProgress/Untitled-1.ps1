$pscred = get-credential 'a-mike_kanakos'
Invoke-Command -credential $pscred  {Get-CimInstance win32_group -filter "LocalAccount='True'" |
Select PSComputername,Name,@{Name="Members";Expression={
 (Get-CimAssociatedInstance -InputObject $_ -ResultClassName Win32_UserAccount).Name -join ";"
}}} -computername "wst-fs-wp02"






[cmdletbinding()]
Param([string]$computer="WST-FS-WP02")

$query="Associators of {Win32_Group.Domain='$computer',Name='Administrators'} where Role=GroupComponent"

write-verbose "Querying $computer"
write-verbose $query

Get-CIMInstance -query $query -computer "Wst-fs-wp02" |
Select @{Name="Member";Expression={$_.Caption}},Disabled,LocalAccount,
@{Name="Type";Expression={([regex]"User|Group").matches($_.Class)[0].Value}},
@{Name="Computername";Expression={$_.ComputerName.ToUpper()}}