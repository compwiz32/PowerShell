$nodelist = Get-Content C:\Scripts\Input\MS15-124_Hosts.txt
$Path64 = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Internet Explorer\MAIN\FeatureControl"
$Path32 = "HKLM:\SOFTWARE\Microsoft\Internet Explorer\MAIN\FeatureControl"

invoke-command -computername $nodelist -scriptblock {
               
    Try {
        #32 bit internet explorer regpath
        New-Item -Path $using:Path32 -Name FEATURE_ALLOW_USER32_EXCEPTION_HANDLER_HARDENING
        New-ItemProperty -Path $using:Path32\FEATURE_ALLOW_USER32_EXCEPTION_HANDLER_HARDENING -Name "iexplore.exe" -PropertyType DWORD -Value 1

        #64 bit inter explorer regpath
        New-Item -Path $using:Path64 -Name FEATURE_ALLOW_USER32_EXCEPTION_HANDLER_HARDENING
        New-ItemProperty -Path $using:Path64\FEATURE_ALLOW_USER32_EXCEPTION_HANDLER_HARDENING -Name "iexplore.exe" -PropertyType DWORD -Value 1

    }#end Try
    
    Catch {
                            
    } #end Catch
        
} #end Scriptblock