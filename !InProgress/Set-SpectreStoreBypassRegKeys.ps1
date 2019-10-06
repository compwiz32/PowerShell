
$regpath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
$keyName = "FeatureSettingsOverride"

# $registryPath = "HKCU:\Software\ScriptingGuys\Scripts"
# $Name = "Version"
$value = "1"
New-ItemProperty -Path $registryPath -Name $name -Value $value `
    -PropertyType DWORD -Force | Out-Null


New-ItemProperty -path




    Reg Key - HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management, Value - FeatureSettingsOverride, REG DWORD - "8"