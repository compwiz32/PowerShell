# Authors: Ryan DeVries, Drew Bonasera, Scott Smith              
# Rochester Institute of Technology - Computer System Forensics 
 
# Variables 
# Reads the hostname, sets to the local hostname if left blank 
$hostname = read-host "Enter the IP or hostname of the computer you wish to scan (Leave blank for local)" 
if ($hostname.length -eq 0){$hostname = $env:computername} 
 
# Reads the start date, sets to 1/1/2000 if left blank 
$startTmp = read-host "Enter the start date to scan from (MM/DD/YYYY, default 1/1/2000)" 
if ($startTmp.length -eq 0){$startTmp = "1/1/2000"} 
$startDate = get-date $startTmp 
 
# Reads the end date, sets to the current date and time if left blank 
$endTmp = read-host "Enter the end date to scan to (MM/DD/YYYY, default current time)" 
if ($endTmp.length -eq 0){$endTmp = get-date} 
$endDate = get-date $endTmp 
 
# Reads a Yes or No response to print only the failed login attempts, defaults to No 
$scope = read-host "Print only failed logins (Y/N, default N)" 
if ($scope.length -eq 0){$scope = "N"} 
 
# Writes a line with all the parameters selected for report 
write-host "Hostname: "$hostname "`tStart: "$startDate "`tEnd: "$endDate "`tOnly Failed Logins: "$scope "`n" 
 
# Store each event from the Security Log with the specificed dates and computer in an array 
$log = Get-Eventlog -LogName Security -ComputerName $hostname -after $startDate -before $endDate 
 
# Loop through each security event, print only failed login attempts 
if ($scope -match "Y"){ 
    foreach ($i in $log){ 
        # Logon Failure Events, marked red 
        # Local 
        if (($i.EventID -eq 4625 ) -and ($i.ReplacementStrings[10] -eq 2)){ 
            write-host "Type:  Local Logon`tDate:  "$i.TimeGenerated "`tStatus:  Failure`tUser:  "$i.ReplacementStrings[5] -foregroundcolor "red" 
        } 
        # Remote 
        if (($i.EventID -eq 4625 ) -and ($i.ReplacementStrings[10] -eq 10)){ 
            write-host "Type: Remote Logon`tDate: "$i.TimeGenerated "`tStatus: Failure`tUser: "$i.ReplacementStrings[5] "`tIP Address: "$i.ReplacementStrings[19] -foregroundcolor "red" 
        } 
    }         
} 
# Loop through each security event, print all login/logoffs with type, date/time, status, account name, and IP address if remote 
else{ 
    foreach ($i in $log){ 
        # Logon Successful Events 
        # Local (Logon Type 2) 
        if (($i.EventID -eq 4624 ) -and ($i.ReplacementStrings[8] -eq 2)){ 
            write-host "Type: Local Logon`tDate: "$i.TimeGenerated "`tStatus: Success`tUser: "$i.ReplacementStrings[5] 
        } 
        # Remote (Logon Type 10) 
        if (($i.EventID -eq 4624 ) -and ($i.ReplacementStrings[8] -eq 10)){ 
            write-host "Type: Remote Logon`tDate: "$i.TimeGenerated "`tStatus: Success`tUser: "$i.ReplacementStrings[5] "`tIP Address: "$i.ReplacementStrings[18] 
        } 
         
        # Logon Failure Events, marked red 
        # Local 
        if (($i.EventID -eq 4625 ) -and ($i.ReplacementStrings[10] -eq 2)){ 
            write-host "Type: Local Logon`tDate: "$i.TimeGenerated "`tStatus: Failure`tUser: "$i.ReplacementStrings[5] -foregroundcolor "red" 
        } 
        # Remote 
        if (($i.EventID -eq 4625 ) -and ($i.ReplacementStrings[10] -eq 10)){ 
            write-host "Type: Remote Logon`tDate: "$i.TimeGenerated "`tStatus: Failure`tUser: "$i.ReplacementStrings[5] "`tIP Address: "$i.ReplacementStrings[19] -foregroundcolor "red" 
        } 
         
        # Logoff Events 
        if ($i.EventID -eq 4647 ){ 
            write-host "Type: Logoff`t`tDate: "$i.TimeGenerated "`tStatus: Success`tUser: "$i.ReplacementStrings[1] 
        }  
    } 
}