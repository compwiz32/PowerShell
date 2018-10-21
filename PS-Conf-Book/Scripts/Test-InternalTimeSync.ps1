# Test-InternalTimeSync.ps1

$SMTPServer = 'smtp.bigfirm.biz'
$MailSender = "AD Health Check Monitor <ADHealthCheck@bigfirm.biz>"
$MailTo = "michael_kanakos@bigfirm.biz"
$DClist = (get-adgroupmember "Domain Controllers").name
$PDCEmulator = (get-addomaincontroller -Discover -Service PrimaryDC).name
$MaxTimeDrift = 45

Import-Module Active-Directory

ForEach ($server in $DClist){
    $Remotetime = ([WMI]'').ConvertToDateTime((gwmi win32_operatingsystem
     -computername $server).LocalDateTime)

    $Referencetime = ([WMI]'').ConvertToDateTime((gwmi win32_operatingsystem
     -ComputerName $PDCEmulator).LocalDateTime)
    
    $result = (NEW-TIMESPAN –Start $Referencetime –End $Remotetime).Seconds

    #If result is a negative number (ie -6 seconds) convert to positive number 
    # for easy comparison
    If ($result -lt 0){ $result = $result * (-1)}

    #test if result is greater than max time drift
    If ($result -gt $MaxTimeDrift){

    $Subject = "Time drift issue on $Server"
         $EmailBody = @"
  
  
 The time on Server named <font color="Red"><b> $Server </b></font> has drifted more than $MaxTimeDrift seconds!
 Time of Event: <font color="Red"><b> $((get-date))</b></font><br/>
 <br/>
 THIS EMAIL WAS AUTO-GENERATED. PLEASE DO NOT REPLY TO THIS EMAIL.
"@

    Send-MailMessage -To $MailTo -From $MailSender -SmtpServer $SMTPServer 
    -Subject $Subject -Body $EmailBody -BodyAsHtml

    } #End if
  } #End Foreach