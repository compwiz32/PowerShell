$SMTPServer = 'smtp.lord.local'
$MailSender = "Ping Test <Pingbot@Lord.com>"
$MailTo = "michael_kanakos@lord.com"
$DClist = get-adgroupmember "Domain Controllers" | Select-Object name

$collection = @('ADWS','DHCPServer','DNS','DFS','DFSR','Eventlog','EventSystem','KDC','LanManWorkstation',
    'LanManWorkstation','NetLogon','NTDS','RPCSS','SAMSS','W32Time')


# Import-Module Active-directory


ForEach ($server in $DClist){ 

    ForEach ($service in $collection){
        Get-Service -name $service -ComputerName $server.name

        if ($service.status -eq "Stopped")
                {
                $Subject = "Windows Service $Service.Displayname is offline"
                $EmailBody = @"
  
  
 Server named <font color="Red"><b> $($Server.name) </b></font> is offline!
 Time of Event: <font color="Red"><b> $((get-date))</b></font><br/>
 <br/>
 THIS EMAIL WAS AUTO-GENERATED. PLEASE DO NOT REPLY TO THIS EMAIL.
"@

        Send-MailMessage -To $MailAdmin -From $MailTo -SmtpServer $SMTPServer -Subject $Subject -Body $EmailBody -BodyAsHtml
        } #End If

    } #End Services Foreach

 } #End of Server ForEach

#End Script