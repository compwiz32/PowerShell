$PScred = get-credential

Get-ADOrganizationalUnit -filter * -property Description -credential $PScred |

foreach {
  $u=Get-ADuser -filter * -searchbase $_.distinguishedname -searchscope Onelevel -credential $PScred
  $totalu=($u | measure-object).count
  $Enabledu=($u | where {$_.Enabled} | Measure-Object).count
  $Disabledu=$totalu-$Enabledu
  $c=Get-ADcomputer -filter * -searchbase $_.distinguishedname -searchscope Onelevel -credential $PScred
  $totalc=($c | measure-object).count
  $Enabledc=($c | where {$_.Enabled} | Measure-Object).count
  $Disabledc=$totalc-$Enabledc
  $g=Get-ADGroup -Filter * -searchbase $_.distinguishedname -searchscope Onelevel -credential $PScred
  $Totalg=($g | measure-object).count
  New-Object psobject -Property @{
    Name=$_.Name;
    OU=$_.Distinguishedname;
    Description=$_.Description;
    TotalUsers=$Totalu;
    EnabledUser=$Enabledu;
    DisabledUser=$Disabledu
    TotalComputers=$Totalc;
    EnabledComp=$Enabledc;
    DisabledComp=$Disabledc
    TotalGroups=$Totalg
    }
} | OGV