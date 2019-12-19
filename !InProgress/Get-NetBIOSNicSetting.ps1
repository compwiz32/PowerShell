
# REG Path to NetBIOS setting ()
$key = "HKLM:SYSTEM\CurrentControlSet\services\NetBT\Parameters\Interfaces"

Get-ChildItem $key | foreach {
        Write-Host("Checking $key\$($_.pschildname)")
        $NetbiosOptions_Value = (Get-ItemProperty "$key\$($_.pschildname)").NetbiosOptions
        Write-Host("The REGKEY value of NetbiosOptions Key is: $NetbiosOptions_Value")
        Write-Host " "
    }