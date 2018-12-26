# $outArray = @()
$pclist = get-content "C:\Scripts\input\SCCM-PC-Rename-Issue\WST.txt"


foreach ($computer in $Pclist) {
    
    Write-host "Testing $computer"
    $online= Test-Connection -ComputerName $computer -Count 1 -Buffersize 16 -Quiet
    if ($online -eq $true)
     {
        try{            
            $event = Get-WinEvent -ComputerName $computer -FilterHashTable @{ LogName = "system"; ID = 6011 } -ErrorAction Stop | select timecreated, message
          
            # Construct an object
            # $myobj = "" | Select "Date", "Message"

            # Fill the object
            # $myobj.date = $event.timecreated
            # $myobj.message = $event.message
        
            # Add the object to the out-array
            # $outarray += $myobj     
            
            Write-host "$computer was renamed" -ForegroundColor Yellow
            $Event | Export-Csv C:\Scripts\Output\SCCM-Rename-Issue\WST-renamed.csv -NoClobber -Append -NoTypeInformation
            
             } # end try

            

        catch{
            Write-Host "Computer $computer does not have event ID 6011 in log"
            Write-Output "Computer $computer does not have event ID 6011 in log" | Out-File C:\Scripts\Output\SCCM-Rename-Issue\WST-NoChange.txt -NoClobber -Append
            
            } #end catch

     } #end if
    else
     {
        # Computer is not reachable!
        Write-Host "Error: $computer not online" -Foreground white -BackgroundColor Red
        Write-Output "Error: $computer not online" | Out-File C:\Scripts\Output\SCCM-Rename-Issue\WST-offline.txt -NoClobber -Append
     } #end else

  } #end foreach

  