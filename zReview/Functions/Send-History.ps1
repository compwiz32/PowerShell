 function Send-History ()
 <#
.Synopsis
   Sends PowerShell Session History to Evernote

.DESCRIPTION
   Sends the command history of the current PowerShell session to Evernote via Email.
   The data sent will be appended to a note named " PowerShell Cmdlet History"

.EXAMPLE
   Send-History
   Sends mail message to Evernote containing the current PowerShell Session history

.NOTES
    NAME: Send-History
    AUTHOR: Mike Kanakos
    CREATED: 2016-09-21
    LASTEDIT: 2017-04-25
    - updated SMTP address to Exchange online
#>


 {
 
$history = history | Out-string
$date = get-date | Out-String
$CombinedText = -join $date,$history | Out-String
Send-MailMessage -To mkanakos.0640c@m.evernote.com -From michael_kanakos@lord.com -Subject "PowerShell Cmdlet History +" -body $CombinedText -SmtpServer lord-com.mail.protection.outlook.com


 }
 # End of Function


