# Disable-HTTP2Protocol
# Disables the ReKeys that control the HTTP2 protocol
# Microsoft Info: CVE-2019-9511 | HTTP/2 Server Denial of Service Vulnerability
# Link: https://portal.msrc.microsoft.com/en-us/security-guidance/advisory/CVE-2019-9511


#define regkeys and values associates with HTTP2 protocol
$regpath = "HKLM:\SYSTEM\CurrentControlSet\Services\HTTP\Parameters"
$key1Name = "EnableHttp2TIs"
$key1value = "0"


$key2Name = "EnableHttp2Cleartext"
$key2Value = "0"


try {
    #Create EnableHttp2TIs reg key and set reg key value
    New-ItemProperty -path $regpath -Name $key1Name -Value $key1value -PropertyType DWORD
} #end try

catch {
    Write-Warning "Unable to create item at $regpath"
} #end catch


try {
    #Create EnableHttp2Cleartext reg key and set reg key value
    New-ItemProperty -path $regpath -Name $key2Name -Value $key2value -PropertyType DWORD
} #end try

catch {
    Write-Warning "Unable to create item at $regpath"
} #catch
