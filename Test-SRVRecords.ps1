$SMTPServer = 'smtp.bigfirm.biz'
$MailSender = "AD Health Check Monitor <ADHealthCheck@bigfirm.biz>"
$MailTo = "michael_kanakos@bigfirm.biz"
$DCList = (get-adgroupmember "Domain Controllers").name
$DCCount = (get-adgroupmember "Domain Controllers").count
$PDCEmulator = (get-addomaincontroller -Discover -Service PrimaryDC).name
$MSDCSZoneName = '_msdcs.lord.local'
$ZoneName = 'lord.local'
$DC_SRV_Record = '_ldap._tcp.dc'
$GC_SRV_Record = '_ldap._tcp.gc'
$KDC_SRV_Record = '_kerberos._tcp.dc'
$PDC_SRV_Record = '_ldap._tcp.pdc' 
$Results = @{}

# Import-Module Active-Directory

$Results.DC_SRV_RecordCount = ((Get-DnsServerResourceRecord -ZoneName $MSDCSZoneName -Name $DC_SRV_Record  -RRType srv -ComputerName $PDCEmulator).count)
$Results.GC_SRV_RecordCount = ((Get-DnsServerResourceRecord -ZoneName $MSDCSZoneName -Name $GC_SRV_Record  -RRType srv -ComputerName $PDCEmulator).count)
$Results.KDC_SRV_RecordCount = ((Get-DnsServerResourceRecord -ZoneName $MSDCSZoneName -Name $KDC_SRV_Record  -RRType srv -ComputerName $PDCEmulator).count)

#$Results.PDCRecordCount = ((Get-DnsServerResourceRecord -ZoneName $MSDCSZoneName -Name $PDC_SRV_Record  -RRType srv -ComputerName $PDCEmulator).Count)

ForEach ($Record in $Results.key){
    If ($Record -ne $DCCount){
    
    $Subject = "There is an SRV record missing from DNS"
         $EmailBody = @"
  
  
 The <font color="Red"><b> $Record </b></font> does not match the numnber of Domain Controller in Active Directory. Please check for missing SRV records. 
 Time of Event: <font color="Red"><b> $((get-date))</b></font><br/>
 <br/>
 THIS EMAIL WAS AUTO-GENERATED. PLEASE DO NOT REPLY TO THIS EMAIL.
"@

    Send-MailMessage -To $MailTo -From $MailSender -SmtpServer $SMTPServer 
    -Subject $Subject -Body $EmailBody -BodyAsHtml

    } #End if
  }#End Foreach

#End of script