########################################
#Get-ADForestHealth V2
#By Winston McMiller
#Synoposis: script leverages Repadmin.exe and DCdiag.exe across the entire forest or domain to help analysis and troubleshooting. 


Param(
  [string]$filePath,
  [string]$Domain,
  [Switch]$Report
    )

$local = $env:Computername + "."+ $env:Userdnsdomain


Function WMIDateStringToDate($Bootup) {  
    [System.Management.ManagementDateTimeconverter]::ToDateTime($Bootup)  
} 

Function Get-ForestDNSAnalysis_Local{

                $adreporttxt = "ADREPORT for" + $domain + (Get-Date -Format M.d.yyyy.hh.mm.ss) +".txt"          
                $Dcdiag= dcdiag /test:DNS /v
                $DNSLog= $dcDiag -like "*invalid DNS server*" 
				$SRVLog= $dcDiag -like "*Missing SRV record*"
				$SRVLog2=$dcDiag -like "*Error details: 9003*"
                $CFLOG= $dcDiag -like "*Missing A record at DNS server*"
				$REP=repadmin /replsummary
                $w32tm = w32tm /monitor /computers:$dc /nowarn
                $icmp = ($w32tm -like "*ICMP*") -replace "ICMP:",""                
                If($icmp -le "0ms"){$timestatus="Optimal"}                IF($icmp -gt "300000ms"){$timestatus="Critical. Over 5 mins!"}                If($icmp -gt "100000ms"){$timestatus="Possible Drift Warning"}
                
                $CPULOAD= Get-WmiObject win32_processor | Measure-Object -property LoadPercentage -Average | Select Average 
                $Systems = Get-WMIObject -class Win32_OperatingSystem -computer $dc  
                $NIC=Get-wmiobject -class Win32_NetworkAdapterConfiguration -filter "IPEnabled=True"
                $ComputerIP = $nic.IPaddress[0] 
				$dnsServers = $nic.dnsserversearchorder 
                              
                                foreach ($system in $Systems) {  
                                   $Bootup = $system.LastBootUpTime  
                                   $LastBootUpTime = WMIDateStringToDate $bootup  
                                   $now = Get-Date
                                   $Uptime = $now - $lastBootUpTime  
                                                               }                                                              
                                                    
                		$unreachableServers = foreach ($d in $dnsServers) {
						    try { 
				        if ((-not (Get-Service -Name Dns -ComputerName  $d -ErrorAction SilentlyContinue))  -as [Bool]) {
						        $d
						}
						    } catch {
						         $d
						    }
						    }

							    $ADreports=New-Object PSObject -Property @{
							    HasInvalidDNSServerIPs = $($unreachableServers -as [bool])
							    MissingSrvRecords = $($srvLog -as [bool])
							    MissingARecord = $($cflog -as [bool])
							    DnsServerSearchOrder= ($dnsServers -join ([Environment]::Newline))
							    Unreachable_DNS_ServersIP = ($unreachableServers -join ([Environment]::Newline))
                                Computer_IP_Address = $ComputerIP
							    ComputerName = $DC
                                Time_Status = $timestatus
                                Time_Sync = $ICMP
                                Last_Bootup = $LastBootUpTime
                                AverageCPULoad= $CPULOAD.Average
                                Replication_Summary= ( $rep -replace "Beginning data collection for replication summary, this may take awhile:" -join ([Environment]::Newline))}                         
                                
                                $adreports                                
                                             
              If($srvlog){
              Write-Host "Repairing Missing SRV record on $DC" -ForegroundColor Green
              nltest /dsregdns
              $Repadmin=Repadmin /syncall
                         }
                         
              $Nltest
              If($Nltest -like "*ERROR_NO_TRUST_SAM_ACCOUNT*"){
              test-computersecurechannel -repair
                                                              } 
                                                              
              If($timestatus = "Critical. Over 5 mins!"){
              w32tm /config /update
              w32tm /resync
              Stop-Service -Name w32time
              Start-Service -Name w32time
              Get-Date -Format hh.mm.ss
              Write-Host "Time Service configured for $DC...." -ForegroundColor Green 
              }                                                
              
              If($unreachableServers){
              Write-Host "Bad DNS IP:$unreachableServers on $DC" -ForegroundColor Green
  
              $title = "Delete the misconfigured IP"
              $message = "Do you want to delete the misconfigured IP from $DC? "

              $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
                     "Deletes the misconfigured IP from the DNS search order."

$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
    "Retains the DNS search order."

$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

$result = $host.ui.PromptForChoice($title, $message, $options, 0) 

switch ($result)
    {
        0 {"You selected Yes."}
        1 {"You selected No."}
    }
If($result=0){
              netsh interface ipv4 delete dnsservers "local area Connection" $unreachableServers
              netsh interface ipv4 show dnsservers "local area Connection"
              $Repadmin
              }
                
               Write-Host "_______________________________________________________________________________________________________" -ForegroundColor Blue
               Write-Host " "
  }   
             IF($Report){$adreports >> $adreporttxt}  
  }                     

Function Get-ForestDNSAnalysis{
                
                $adreporttxt= "ADREPORT for" + $domain + (Get-Date -Format M.d.yyyy.hh.mm.ss) +".txt"  
                $Dcdiag = invoke-command -computername $DC -scriptblock {dcdiag /test:DNS /v}
                $DNSLog= $dcDiag -like "*invalid DNS server*" 
				$SRVLog= $dcDiag -like "*Missing SRV record*"
				$SRVLog2=$dcDiag -like "*Error details: 9003*"
				$CFLOG= $dcDiag -like "*Missing A record at DNS server*"
				$REP = invoke-command -computername $DC -scriptblock {repadmin /replsummary | where {$_ -ne ""}}
                $w32tm = invoke-command -computername $DC -scriptblock{w32tm /monitor /computers:$dc /nowarn}
                $icmp = ($w32tm -like "*ICMP*") -replace "ICMP:",""                                If($icmp[0] -le "0ms"){$timestatus="Optimal"}                IF($icmp[0] -gt "300000ms"){$timestatus="Critical. Over 5 mins!"}                If($icmp[0] -gt "100000ms"){$timestatus="Possible Drift Warning"}
                
                $CPULOAD = invoke-command -computername $DC -scriptblock {Get-WmiObject win32_processor | Measure-Object -property LoadPercentage -Average | Select Average }
                $Systems = invoke-command -computername $DC -scriptblock {Get-WMIObject -class Win32_OperatingSystem}
                $Nic=invoke-command -computername $DC -scriptblock {Get-wmiobject -class Win32_NetworkAdapterConfiguration -filter "IPEnabled=True"}
                $ComputerIP = $nic.IPaddress[0] 
				$dnsServers = $nic.dnsserversearchorder 
                              
                                foreach ($system in $Systems) {  
                                   $Bootup = $system.LastBootUpTime  
                                   $LastBootUpTime = WMIDateStringToDate $bootup  
                                   $now = Get-Date
                                   $Uptime = $now - $lastBootUpTime  
                                   $d = $Uptime.Days  
                                   $h = $Uptime.Hours  
                                   $m = $uptime.Minutes  
                                   $ms= $uptime.Milliseconds  
                                                                 }  
			        
						$unreachableServers = foreach ($d in $dnsServers) {
						    try { 
				            if ((-not (Get-Service -Name Dns -ComputerName  $d -ErrorAction SilentlyContinue))  -as [Bool]) {
						        $d
						}
						    } catch {
						         $d
						    }
						    }

							    $adreports=New-Object PSObject -Property @{
							    HasInvalidDNSServerIPs = $($unreachableServers -as [bool])
							    MissingSrvRecords = $($srvLog -as [bool])
							    MissingARecord = $($cflog -as [bool])
							    DnsServerSearchOrder= ($dnsServers -join ([Environment]::Newline))
							    Unreachable_DNS_ServersIP = ($unreachableServers -join ([Environment]::Newline))
                                Computer_IP_Address = $ComputerIP
							    ComputerName = $DC
                                Time_Status = $timestatus
                                Time_Sync = $ICMP
                                Last_Bootup = $LastBootUpTime
                                AverageCPULoad= $CPULOAD.Average
                                Replication_Summary= ( $rep -replace "Beginning data collection for replication summary, this may take awhile:" -join ([Environment]::Newline))}                         
                   
                   $adreports
                   
                                             
              If($srvlog){
              Write-Host "Repairing Missing SRV record on $DC" -ForegroundColor Green
              $Nltest=invoke-command -computername $DC -scriptblock {nltest /dsregdns}
              $Repadmin=invoke-command -computername $DC -scriptblock {Repadmin /syncall}
                         }
                         
              $Nltest
              If($Nltest -like "*ERROR_NO_TRUST_SAM_ACCOUNT*"){
              invoke-command -computername $DC -scriptblock {test-computersecurechannel -repair}

              If($timestatus = "Critical. Over 5 mins!"){
              invoke-command -computername $DC -scriptblock {w32tm /config /update}
              invoke-command -computername $DC -scriptblock {Stop-Service -Name w32time}
              invoke-command -computername $DC -scriptblock {Start-Service -Name w32time}
              invoke-command -ComputerName $DC -ScriptBlock {w32tm /resync}
              invoke-command -computername $DC -scriptblock {Get-Date -Format hh.mm.ss}
              Write-Host "Time Service configured for $DC...." -ForegroundColor Green 
              }
                                                              }   
              
              If($unreachableServers){
              Write-Host "Bad DNS IP:$unreachableServers on $DC" -ForegroundColor Green
  
              $title = "Delete the misconfigured IP"
              $message = "Do you want to delete the misconfigured IP from $DC? "

              $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
                     "Deletes the misconfigured IP from the DNS search order."

$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
    "Retains the DNS search order."

$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

$result = $host.ui.PromptForChoice($title, $message, $options, 0) 

switch ($result)
    {
        0 {"You selected Yes."}
        1 {"You selected No."}
    }
If($result=0){
              invoke-command -computername $DC -scriptblock {netsh interface ipv4 delete dnsservers "local area Connection" $args[0] } -Args $unreachableServers
              invoke-command -computername $DC -scriptblock {netsh interface ipv4 show dnsservers "local area Connection"}
              $Repadmin
              }
                IF($Report){$adreports >> $adreporttxt}
  
  }
                Write-Host "_______________________________________________________________________________________________________" -ForegroundColor Blue
               Write-Host " "
  }
              
If($Domain){
Write-Host "Enumerating $Domain Domain...." -ForegroundColor Green
  ipmo activedirectory
                $DCS=(get-addomain $domain).ReplicaDirectoryServers
                Foreach($DC in $DCS){
                If($local -eq $DC){Get-ForestDNSAnalysis_Local}
                If($local -ne $DC){Get-ForestDNSAnalysis}
} 
}
    
If($filePath){
$Domains=Get-Content $filepath
ForEach($Domain in $Domains){
Write-Host "Enumerating $Domain Domain...." -ForegroundColor Green
$DCS=(get-addomain $domain).ReplicaDirectoryServers
                Foreach($DC in $DCS){
                If($local -eq $DC){Get-ForestDNSAnalysis_Local}
                If($local -ne $DC){Get-ForestDNSAnalysis}
                            }
            }
            }