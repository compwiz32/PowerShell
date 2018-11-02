$counter = 0
$type = "*.locky"
# $Member_servers = get-adcomputer -filter {Operatingsystem -Like "*Server*"}
$Member_servers = Get-ADComputer erisqld02

$ServersTotal = $Member_servers.count
  foreach($Server in $Member_servers) {
  "Checking " + $Server.name | echo
  $counter += 1
  
  # $drives = get-wmiobject -query "SELECT * from win32_logicaldisk where drivetype = '3'" -computername $server.name
  $drives = Get-WmiObject Win32_Share | Where-Object {$_.type -eq ‘0’}

    
  foreach($drive in $drives) {
    $driveletter = %{$drive.deviceid}
"Checking: " + $driveletter + " on " + $server.name + "  (" + $counter + "/" + $ServersTotal + ")" | echo
    $driveletter = $driveletter.trim(":”) + “$”
    $searchlocation = “\\” + $server.name + “\” + $driveletter + “\"
    # gci $searchlocation -Filter *.locky -Recurse | select fullname | export-csv locky_scan_results.csv
    gci $searchlocation -Filter $type -Recurse | select Directory -Unique | Out-GridView
  }
}



\\ERISQLD02\autodeskvault

# dir c:\work\$type -Recurse | Select Directory
