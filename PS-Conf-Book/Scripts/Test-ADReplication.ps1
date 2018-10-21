# Test-ADReplication.ps1

$SMTPServer = 'smtp.bigfirm.biz'
$MailSender = "AD Health Check Monitor <ADHealthCheck@bigfirm.biz>"
$MailTo = "michael_kanakos@bigfirm.biz"
$DClist = (get-adgroupmember "Domain Controllers").name

Import-Module Active-Directory

$DClist = (get-adgroupmember "Domain Controllers").name

Foreach ($server in $DClist) {
    $Result = (Get-ADReplicationFailure -Target $server).failurecount
    
        If ($result -ne $null -or $result -gt 0){
        
        $Subject = "Replication Failure on $Server"
        $EmailBody = @"
  
  
 There is a replication failure on <font color="Red"><b> $Server </b></font>!
 Time of Event: <font color="Red"><b> $((get-date))</b></font><br/>
 <br/>
 THIS EMAIL WAS AUTO-GENERATED. PLEASE DO NOT REPLY TO THIS EMAIL.
"@

    Send-MailMessage -To $MailTo -From $MailSender -SmtpServer $SMTPServer 
    -Subject $Subject -Body $EmailBody -BodyAsHtml

    } #End if
  }#End Foreach