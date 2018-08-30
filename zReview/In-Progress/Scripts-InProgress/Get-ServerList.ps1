$servers = Get-content C:\Scripts\output\serversNA.txt

ForEach ($server in $servers)
{Get-Object {Get-WmiObject win32_computerSystem -ComputerName $_ | select name, Model}











$items = Get-Content "C:\temp\partial_name.csv"
$Results = "C:\temp\PCName_by_Serial"

ForEach ($Serial in $items)
{
$Value = "*$Serial*"
If ($Name = Get-ADComputer -Filter {Name -Like $Value} | Select Name)
{
#Write-host $Name, $Item
"$Name,$Serial" | Out-File $Results -Append
}
Else{
"Serial $Serial not found" |Out-File $Results -append
}
}  