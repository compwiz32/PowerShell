$server   = 'dtn-dc-wp01'
$username = $env:USERNAME

$session = ((quser /server:$server | ? { $_ -match $username }) -split ' +')[2]

logoff $session /server:$server