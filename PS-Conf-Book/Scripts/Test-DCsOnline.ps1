# Test-DCsOnline.ps1

$SMTPServer = 'smtp.bigfirm.biz'
$MailSender = "AD Health Check Monitor <ADHealthCheck@bigfirm.biz>"
$MailTo = "michael_kanakos@bigfirm.biz"
$DClist = (get-adgroupmember "Domain Controllers").name

Import-Module Active-Directory

ForEach ($server in $DClist){

    if  ((!(Test-Connection -ComputerName $Server -quiet -count 1)))
     {
         $Subject = "Server $Server is offline"
         $EmailBody = @"
  
  
 Server named <font color="Red"><b> $Server </b></font> is offline!
 Time of Event: <font color="Red"><b> $((get-date))</b></font><br/>
 <br/>
 THIS EMAIL WAS AUTO-GENERATED. PLEASE DO NOT REPLY TO THIS EMAIL.
"@

    Send-MailMessage -To $MailTo -From $MailSender -SmtpServer $SMTPServer 
    -Subject $Subject -Body $EmailBody -BodyAsHtml

    } #End if
  }#End Foreach