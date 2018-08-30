$2012DCs = get-content C:\Scripts\Input\2012DCs.txt

foreach ($DC in $2012DCs) {
Invoke-Command -ComputerName $DC {Remove-Item C:\Windows\System32\dns\dns201*.log}
}
