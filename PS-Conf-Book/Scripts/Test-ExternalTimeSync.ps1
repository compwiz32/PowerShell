# Test-ExternalTimeSync.ps1

$SMTPServer = 'smtp.bigfirm.biz'
$MailSender = "AD Health Check Monitor <ADHealthCheck@bigfirm.biz>"
$MailTo = "michael_kanakos@bigfirm.biz"
$PDCEmulator = (get-addomaincontroller -Discover -Service PrimaryDC).name
$ExternalTimeSvr = '0.pool.ntp.org'
$MaxTimeDrift = 15

Import-Module Active-Directory

#get external time and extract just the time from from the result
$ExternalTime = (w32tm /stripchart /dataonly /computer:$Server /samples:1)[-1].split("[")[0]
$ExternalTimeOutput = [Regex]::Match($ExternalTime,"\d+\:\d+\:\d+").value

#get time from PDCe
$PDCeTime = ([WMI]'').ConvertToDateTime((gwmi win32_operatingsystem
     -computername $PDCEmulator).LocalDateTime)

$result = (NEW-TIMESPAN –Start $ExternalTimeOutput –End $PDCeTime).Seconds

    #If result is a negative number (ie -6 seconds) convert to positive number 
    # for easy comparison
    If ($result -lt 0){ $result = $result * (-1)}

    #test if result is greater than max time drift
    If ($result -gt $MaxTimeDrift){

    $Subject = "External time sync issue on $Server"
         $EmailBody = @"
  
  
 The time on the PDCe <font color="Red"><b> $PDCEmulator </b></font> has drifted more than $MaxTimeDrift seconds from the time source $ExternalTimeSvr !
 Time of Event: <font color="Red"><b> $((get-date))</b></font><br/>
 <br/>
 THIS EMAIL WAS AUTO-GENERATED. PLEASE DO NOT REPLY TO THIS EMAIL.
"@

    Send-MailMessage -To $MailTo -From $MailSender -SmtpServer $SMTPServer 
    -Subject $Subject -Body $EmailBody -BodyAsHtml

    } #End if
  } #End Foreach