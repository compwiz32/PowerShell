# Delete all IIS log files older than 90 day(s)
$Path = "C:\inetpub\logs\LogFiles\w3svc1"
$Daysback = "-90"

$CurrentDate = Get-Date
$DatetoDelete = $CurrentDate.AddDays($Daysback)
Get-ChildItem $Path | Where-Object { $_.LastWriteTime -lt $DatetoDelete } | Remove-Item