# Launch PowerShell ISE as an Admin code
# v1.0  10/24/2011
# Created by Jason Himmelstein
# http://blog.sharepointlonghorn.com

# Farm account name
$AccountInfo = "domain\a-mike_kanakos"

# Load the Farm Account Creds
$cred = Get-Credential $AccountInfo

# Create a new process with UAC elevation
Start-Process $PsHome\powershell.exe -Credential $cred -ArgumentList "-Command Start-Process $PSHOME\powershell_ise.exe -Verb Runas" -Wait