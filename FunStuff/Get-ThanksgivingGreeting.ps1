function Get-ThanksgivingGreeting {
    [CmdletBinding()]
    param (
    )
    
    begin {
    cls
    $count = 0
    $Greeting1 = "Happy Thanksgiving !!!"
    $Greeting2 = "Eats lots of Turkey!!!"
    $Greeting3 = "Be thankful for the blessings in your life !!!"
}
    
    process {
        while ($count -lt 6) {
            $count++
            Write-host ""
            Write-host ""
            Write-host -foregroundcolor Green $Greeting1;sleep 2;sleep 1
            Write-host -foregroundcolor Red $Greeting2;sleep 2;sleep 1
            Write-host -foregroundcolor Yellow $Greeting3;sleep 2;cls;sleep 1
        } 
    }
    
    end {
    }
}
