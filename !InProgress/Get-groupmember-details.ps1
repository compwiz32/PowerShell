$Groups = Get-Content "C:\Scripts\Input\Privilege-audit-grplist.txt"
$ADProps = @("Name","Enabled","LastLogonDate","WhenCreated","WhenChanged","CanonicalName")

$Table = [System.Collections.Generic.List[pscustomobject]]::New()

$Record = [ordered]@{
"Group Name" = ""
"Name" = ""
"Enabled" = ""
"Last Logon" = ""
"Account Created" = ""
"Last Changed" = ""
"Account Location" = ""
} #End Record Table


Foreach ($Group in $Groups)
{

$Arrayofmembers = Get-ADGroupMember -identity $Group -Recursive | select SamAccountName

foreach ($Member in $Arrayofmembers)
    {
    $user = Get-ADUser $Member.SamAccountName -prop $ADprops | Select-Object $ADProps
    $Record."Group Name" = $Group

    $Record."Name" = $Member.SamAccountName
    $Record."Enabled" = $User.Enabled
    $Record."Last Logon" = $User.LastLogonDate
    $Record."Account Created" = $User.WhenCreated
    $Record."Last Changed" = $User.WhenChanged
    $Record."Account Location" = $User.CanonicalName
    $objRecord = New-Object PSObject -property $Record
    
    $Table.Add($objrecord)
    } #End ForEach members

    
} #End ForEach Groups