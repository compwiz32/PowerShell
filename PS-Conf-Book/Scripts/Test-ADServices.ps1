# Test-ADServices.ps1


$SMTPServer = 'smtp.bigfirm.biz'
$MailSender = "AD Health Check Monitor <ADHealthCheck@bigfirm.biz>"
$MailTo = "michael_kanakos@bigfirm.biz"
$DClist = (get-adgroupmember "Domain Controllers").name

$collection = @('ADWS','DHCPServer','DNS','DFS','DFSR','Eventlog','EventSystem','KDC','LanManWorkstation',
    'LanManWorkstation','NetLogon','NTDS','RPCSS','SAMSS','W32Time')


Import-Module Active-Directory


ForEach ($server in $DClist){ 

    ForEach ($service in $collection){
        Get-Service -name $service -ComputerName $server

        if ($service.status -eq "Stopped")
                {
                $Subject = "Windows Service $Service.Displayname is offline"
                $EmailBody = @"
  
  
 Server named <font color="Red"><b> $Server </b></font> is offline!
 Time of Event: <font color="Red"><b> $((get-date))</b></font><br/>
 <br/>
 THIS EMAIL WAS AUTO-GENERATED. PLEASE DO NOT REPLY TO THIS EMAIL.
"@

        Send-MailMessage -To $MailAdmin -From $MailTo -SmtpServer $SMTPServer
         -Subject $Subject -Body $EmailBody -BodyAsHtml
        } #End If

    } #End Services Foreach

 } #End of Server ForEach
© 2018 GitHub, Inc.