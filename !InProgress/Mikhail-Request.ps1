$Results= @()

$usernames = get-content (path to text file - each name on one line, no commas)

$usernames | ForEach-Object {

    $results += Get-ADComputer -Filter "name -like '*$_*'" -searchbase ( path to OU ) | select -expand name
    }

$results | sort name
