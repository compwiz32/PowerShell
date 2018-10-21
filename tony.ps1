$users = C:\scripts\Input\tony.txt

ForEach ($user in $users) {
    Get-ADUser $_ -prop title | Select-Object name, title
} 



Get-Content C:\Scripts\Input\tony.txt | ForEach-Object {get-aduser $_}