$Path64 = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Internet Explorer\MAIN\FeatureControl"
$Path32 = "HKLM:\SOFTWARE\Microsoft\Internet Explorer\MAIN\FeatureControl"


New-Item -Path $Path64 -Name FEATURE_ALLOW_USER32_EXCEPTION_HANDLER_HARDENING
New-ItemProperty -Path $Path64\FEATURE_ALLOW_USER32_EXCEPTION_HANDLER_HARDENING -Name "iexplore.exe" -PropertyType DWORD -Value 1


New-Item -Path $Path32 -Name FEATURE_ALLOW_USER32_EXCEPTION_HANDLER_HARDENING
New-ItemProperty -Path $Path32\FEATURE_ALLOW_USER32_EXCEPTION_HANDLER_HARDENING -Name "iexplore.exe" -PropertyType DWORD -Value 1