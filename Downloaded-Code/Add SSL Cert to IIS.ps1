$SiteName = "MySite"
$HostName = "localhost"
$CertificatePassword = '1234'
$UAPWebBrowserUrl ='https://localhost'
$SiteFolder = Join-Path -Path 'C:\inetpub\wwwroot' -ChildPath $SiteName
$certPath = 'c:\cert.pfx'


Write-Host 'Import pfx certificate' $certPath
$certRootStore = “LocalMachine”
$certStore = "My"
$pfx = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
$pfx.Import($certPath,$CertificatePassword,"Exportable,PersistKeySet") 
$store = New-Object System.Security.Cryptography.X509Certificates.X509Store($certStore,$certRootStore) 
$store.Open('ReadWrite')
$store.Add($pfx) 
$store.Close() 
$certThumbprint = $pfx.Thumbprint


Write-Host 'Add website' $SiteName
New-WebSite -Name $SiteName -PhysicalPath $SiteFolder -Force
$IISSite = "IIS:\Sites\$SiteName"
Set-ItemProperty $IISSite -name  Bindings -value @{protocol="https";bindingInformation="*:443:$HostName"}
if($applicationPool) { Set-ItemProperty $IISSite -name  ApplicationPool -value $IISApplicationPool }


Write-Host 'Bind certificate with Thumbprint' $certThumbprint
$obj = get-webconfiguration "//sites/site[@name='$SiteName']"
$binding = $obj.bindings.Collection[0]
$method = $binding.Methods["AddSslCertificate"]
$methodInstance = $method.CreateInstance()
$methodInstance.Input.SetAttributeValue("certificateHash", $certThumbprint)
$methodInstance.Input.SetAttributeValue("certificateStoreName", $certStore)
$methodInstance.Execute()