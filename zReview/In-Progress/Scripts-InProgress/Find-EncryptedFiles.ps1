# $counter = 0
$type = "*.locky"
# $Member_servers = get-adcomputer -filter {Operatingsystem -Like "*Server*"}
$Servers = Get-ADComputer srvwin0791

# $ServersTotal = $Member_servers.count
  foreach($Server in $Servers) {
  "Checking " + $Server.name | echo
  # $counter += 1
    # $drives = get-wmiobject -query "SELECT * from win32_logicaldisk where drivetype = '3'" -computername $server.name
  
  $shares = Get-WmiObject Win32_Share -computername $server.name | Where-Object {$_.type -eq ‘0’} 
      
  foreach($share in $shares) {
    # $trimmedshare = $share.Name    
    # $trimmedshare = $share.trim(":”) + “$”
    "Checking: " + $share.Name + " on " + $server.name | echo
    $searchlocation = “\\” + $server.name + “\” + $share.name + “\"
    # gci $searchlocation -Filter *.locky -Recurse | select fullname | export-csv locky_scan_results.csv
    gci $searchlocation -Filter $type -Recurse | select Directory -Unique | Out-GridView
  }
}
