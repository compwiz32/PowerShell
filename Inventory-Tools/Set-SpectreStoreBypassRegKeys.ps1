# script to set REG KEYS on systems vulnerable to Spectre
# Created 2019-10-05

$regpath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
$key1Name = "FeatureSettingsOverride"
$key1value = "8"

$key2Name = "FeatureSettingsOverrideMask"
$key2Value = "3"


try {
    #Create FeatureSettingsOverride reg key
    New-ItemProperty -path $regpath -Name $key1Name -Value $key1value -PropertyType DWORD
} #end try

catch {
    Write-Warning "Unable to create item at $regpath"
} #end catch


try {
    #Create FeatureSettingsOverrideMask reg key
    New-ItemProperty -path $regpath -Name $key2Name -Value $key2value -PropertyType DWORD
} #end try

catch {
    Write-Warning "Unable to create item at $regpath"
} #catch
