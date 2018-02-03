#Get-SrvFolderAdminUsage.ps1

# Script checks a list of servers to see if the AD Account srvFolderAdmin is configured 
# for any services, shares or local admin access

$compArray = get-content C:\Scripts\Input\LPDServers.txt
foreach($strComputer in $compArray)
{
Write-Host $strComputer -ForegroundColor Green
Get-WMIObject Win32_Service -ComputerName $strComputer | Where-Object{$_.StartName -eq 'srvFolderAdmin'} | Sort-Object -Property StartName | Format-Table Name, StartName, Status -AutoSize
}