# Set-PSWebProxy.ps1
#Mike Kanakos - 2017-10-11

# Set Zscaler Proxy web address
$proxyString = "http://atl2.sme.zscalertwo.net"
$proxyUri = new-object System.Uri($proxyString)

#Set the proxy settings in the OS
[System.Net.WebRequest]::DefaultWebProxy = new-object System.Net.WebProxy ($proxyUri, $true)
[System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials