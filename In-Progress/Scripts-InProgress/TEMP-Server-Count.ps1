$PCinfo = Get-WmiObject Win32_ComputerSystem

gwmi win32_processor -Property NumberOfCores


$Computer = Get-ADComputer -Filter * -Properties OperatingSystem | Where-Object {$_.Name -match 'SRV*'}

foreach ($Computer in $Computers)
{$PCinfo.model}




# { Get-ADComputer -Filter * -Properties OperatingSystem | Where-Object {$_.Name -match 'SRV*' or 'WIN*'} | ft Name, OperatingSystem -auto

$servers | $PCinfo.model

gpreult