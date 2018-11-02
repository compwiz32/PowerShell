function Get-AccountLockoutLocation {
	[CmdletBinding()]
	param(
		[Parameter(Position=0, Mandatory=$true)]
		[System.String]
		$UserName
	    )
	begin 
        {
	
			#Gets a list of all domain controllers in the current domain	
			$DomainControllers = Get-ADDomainController -discover -site cary

			#Selects the domain controller that has the PDC Emulator Master Role
            $PDCEmulator = Get-ADComputer  WINERIDC02 | select *
		
			#Get all of the events from the security log that has an ID of 4740
			$Events = Get-WinEvent -ComputerName $PDCEmulator.Name -FilterHashtable @{Logname='Security';Id=4740}
		
			#Select only the events that match the current user in process
			$UserEvents = $Events | Where-Object {$_.Message -like "*$UserName*"}

	    }
	process
        {
			#Get and display user information from each of the domain controllers in the domain.
			$DomainControllers | ForEach-Object{ $DC = $_; Get-ADUser -Identity $UserName -Server $_.HostName -Properties AccountLockOutTime, LastBadPasswordAttempt, BadPwdCount, LockedOut | Select Name, LockedOut,@{Name='DC';Expression={$DC.Name}}, BadPwdCount, AccountLockoutTime, LastBadPasswordAttempt} | ft
		
			#Get and display event information for each event entry.
			$UserEvents | ForEach-Object {$_ | Select @{Name='UserName';Expression={$_.Properties.Value[0]}}, @{Name='LockoutLocation';Expression={$_.Properties.Value[1]}}}
        }
	    end 
        {
	    }