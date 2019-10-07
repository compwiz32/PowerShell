#script to set REG KEYS on systems to make LDAP authentication over SSL/TLS more secure


$regpath = "HKLM:\System\CurrentControlSet\Services\NTDS\Parameters"
$key1Name = "LdapEnforceChannelBinding"
$key1value = "1"
$keytype = "DWORD"


try {
    #Create FeatureSettingsOverride reg key
    New-ItemProperty -path $regpath -Name $key1Name -Value $key1value -PropertyType $keytype
} #end try

catch {
    Write-Warning "Unable to create item at $regpath"
} #end catch
