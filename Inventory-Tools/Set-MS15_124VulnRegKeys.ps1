$nodelist = Get-Content C:\Scripts\Input\MS15-124_svrs_2019_07_25B.txt
$Path64 = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Internet Explorer\MAIN\FeatureControl"
$Path32 = "HKLM:\SOFTWARE\Microsoft\Internet Explorer\MAIN\FeatureControl"

invoke-command -computername $nodelist -scriptblock {
                
    
    Try {
        #32 bit internet explorer regpath
        New-Item -Path $using:Path32 -Name FEATURE_ALLOW_USER32_EXCEPTION_HANDLER_HARDENING -ErrorAction Stop
        New-ItemProperty -Path $using:Path32\FEATURE_ALLOW_USER32_EXCEPTION_HANDLER_HARDENING -Name "iexplore.exe" -PropertyType DWORD -Value 1
    }

    Catch {
        Write-Warning "Unable to create item at $using:Path32"
    }

    Try {   
        #64 bit inter explorer regpath
        New-Item -Path $using:Path64 -Name FEATURE_ALLOW_USER32_EXCEPTION_HANDLER_HARDENING -ErrorAction Stop
        New-ItemProperty -Path $using:Path64\FEATURE_ALLOW_USER32_EXCEPTION_HANDLER_HARDENING -Name "iexplore.exe" -PropertyType DWORD -Value 1
    
    }

    Catch {
        Write-Warning "Unable to create item at $using:Path64"
    }
 
} -ErrorAction Stop #end Scriptblock

Catch {

Write-Warning "Unable to make connection to $psitem"

} #catch