

$server 
$filepath
$share

Invoke-Command $server -ScriptBlock { Get-ChildItem $share -Recurse | Measure-Object -sum Length | select @{Name = "GB"; Expression = { [math]::round($_.sum / 1GB, 2) } } }




.\DFSShared$\Global\Software\autodesk