
$Servers = get-adcomputer -filter {operatingsystem -like '*server*' -and Enabled -eq $true} -prop operatingsystem, description
$Results = @{}


Foreach($Computer in $Servers){
    Write-Host "Querying: $($Computer.Name)"
    $Connection = Test-Connection $Computer.Name -Quiet -Count 2

    If(!$Connection) {
        $Results.Add('Status',"Offline")
        $Results.Add('Computer',$Computer.Name)
        Write-Warning "Computer: $($Computer.Name) appears to be offline!"
    } #end If

    Else {
        if(Get-WmiObject -ComputerName $Computer.name Win32_ComputerSystem | where {$_.manufacturer -eq "Nutanix*"} ) {



        Get-WmiObject -ComputerName $Computer.Name Win32_PnPSignedDriver |
        where {$_.DeviceName -like "*Nutanix virtio ether*"} | Select-Object DeviceName, DriverVersion

        $Results.Add('Computer',$Computer.Name)
        $Results.Add('DeviceName',$_.DeviceName)
        $Results.Add('DriverVersion', $_.DriverVersion)
        $Results.Add('Status', (If($Connection){"Online"} Else {"Offline"}))

        } #End Inner Else

    } # Outer Else
}#Foreach Computer Loop

[pscustomobject]$Results | Select-Object Computer, Status, DeviceName, DriverVersion


