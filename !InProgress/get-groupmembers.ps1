
$Results = @()

$servers = Get-Content "C:\Scripts\Input\privilege-audit-svrlist.txt"


ForEach ($node in $servers) {
    $localgroups = Get-WmiObject win32_group -filter "localaccount='true'" -ComputerName $node | select name
    
       ForEach ($grp in $localgroups) {
       
       Write-Host "Group lookup on: " $node ", " $grp
      
       $Results+= Get-LordLocalGroupMembership -ComputerName $node -GroupName $grp.name
       } #end foreach groupmember lookup
          
    } #end foreach group lookup

