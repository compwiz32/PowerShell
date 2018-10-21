# Get-DCDiskspace.ps1

$SMTPServer = 'smtp.bigfirm.biz'
$MailSender = "AD Health Check Monitor <ADHealthCheck@bigfirm.biz>"
$MailTo = "michael_kanakos@bigfirm.biz"
$DClist = (get-adgroupmember "Domain Controllers").name
$FreeDiskThreshold = 20

ForEach ($server in $DClist){

$disk = Get-WmiObject Win32_LogicalDisk -Filter "DriveType=3" -ComputerName $server

        $Size = "{0:n0} GB" -f (($disk | Measure-Object -Property Size -Sum).sum/1gb)
        $FreeSpace = "{0:n0} GB" -f (($disk | Measure-Object -Property FreeSpace -Sum).sum/1gb)


        $freepercent = [math]::round((($free / $size) * 100),0)
                $Diskinfo = [PSCustomObject]@{
                Drive = $disk.Name
                "Total Disk Size (GB)" = $size
                "Free Disk Size (GB)" = $FreeSpace
                "Percent Free (%)" = $freepercent
          } #End $DiskInfo Calculations
    
    If ($Diskinfo.'Percent Free (%)' -lt $FreeDiskThreshold){
         $Subject = "Low Disk Space: Server $Server"
         $EmailBody = @"
  
  
 Server named <font color="Red"><b> $Server </b></font> is running low on disk space on drive C:!
 <br/>
 $Diskinfo
 <br/>
 Time of Event: <font color="Red"><b> $((get-date))</b></font><br/>
 <br/>
 THIS EMAIL WAS AUTO-GENERATED. PLEASE DO NOT REPLY TO THIS EMAIL.
"@

     Send-MailMessage -To $MailTo -From $MailSender -SmtpServer $SMTPServer 
     -Subject $Subject -Body $EmailBody -BodyAsHtml
  
    } #End If


} # End ForEach