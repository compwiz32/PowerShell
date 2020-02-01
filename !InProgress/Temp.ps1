
Foreach ($_ in 1..13){Remove-JobTrigger -name ResetIIS -TriggerId $_}

# ---------------------


$svrlist = get-content C:\scripts\Output\svrlist2.txt
$svrlist | ForEach-Object {
    Write-Output "Checking: $_"
    Get-WmiObject -Class Win32_Product -ComputerName $_ | where { $_.name -like '*netbackup*' -or $_.name -like '*rubrik*' } | Select-Object Pscomputername, Name, Version }


Get-WmiObject -Class Win32_Product -ComputerName crd-dc-wp01 | where { $_.name -like 'carbon*' }


# --------------

$sites | ForEach-Object { New-ADOrganizationalUnit "LRD"+$_ -Path "OU=z-ParkerMigration-US,DC=LORD,DC=LOCAL" -Server crd-dc-wp01 }

# ---------------



$sites = Get-Content C:\Scripts\Input\Sites-NA.txt

$sites | ForEach-Object {
    $letter1 = ((65..90) | Get-Random -Count 1 | ForEach-Object { [char]$_ }).ToString()
    $letter1 = $letter.ToUpper()
    $letter1

    $letter2 = ((65..90) | Get-Random -Count 1 | ForEach-Object { [char]$_ }).ToString()
    $letter2 = $letter.ToUpper()
    $letter2

    $num = Get-Random (0..10)

    $DIVLOC = -join ('LRD', $num, $letter1, $letter2)

    $temp = -join ($DIVLOC, "_", $_)
    New-ADOrganizationalUnit $temp -Path "OU=z-ParkerMigration-US,DC=LORD,DC=LOCAL" -Server crd-dc-wp02 -Credential $cred
    }


# ---------------


    Ipconfig /registerdns
    Nltest /DSREGDNS

# ---------------

    wevtutil sl "Microsoft-Windows-DNS-Client/Operational" /e:true
    ipconfig /registerdns
    sleep -Seconds 5
    wevtutil sl "Microsoft-Windows-DNS-Client/Operational" /e:false
    Get-WinEvent -name "Microsoft-Windows-DNS-Client/Operational" -MaxEvents 20 | ft -Wrap

    # ---------------