# Test-ExternalDNSServers.ps1

$SMTPServer = 'smtp.bigfirm.biz'
$MailSender = "AD Health Check Monitor <ADHealthCheck@bigfirm.biz>"
$MailTo = "michael_kanakos@bigfirm.biz"
$DClist = (get-adgroupmember "Domain Controllers").name
$ExternalDNSServers = '208.67.222.222 ','208.67.220.220'

Import-Module Active-Directory

ForEach ($server in $DClist){

    ForEach ($DNSServer in $ExternalDNSServers) {
        
       if  ((!(Invoke-Command -ComputerName $Server {Test-Connection -ComputerName $DNSServer -quiet -count 1)))
         {
             $Subject = "External DNS $DNSServer is unreachable"
             $EmailBody = @"
  
  
 A Test connection from <font color="Red"><b> $Server </b></font> to $DNSServer was unsuccessful!
 Time of Event: <font color="Red"><b> $((get-date))</b></font><br/>
 <br/>
 THIS EMAIL WAS AUTO-GENERATED. PLEASE DO NOT REPLY TO THIS EMAIL.
"@

    Send-MailMessage -To $MailTo -From $MailSender -SmtpServer $SMTPServer 
    -Subject $Subject -Body $EmailBody -BodyAsHtml

        } #End if
    }# End Foreach (DCLIst)
 } # End ForEach (ExternalDNSServers)