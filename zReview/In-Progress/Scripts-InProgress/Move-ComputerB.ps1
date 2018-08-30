function Show-Menu
{
     param (
           [string]$Title = 'Server OU Menu'
     )
     cls
     Write-Host "================ $Title ================"
     
     Write-Host "1: Press '1' for the Servers > Low OU"
     Write-Host "2: Press '2' for the Servers > Moderate-A OU"
     Write-Host "3: Press '3' for the Servers > Moderate-B OU"
     Write-Host "4: Press '4' for the Servers > High OU"
     Write-Host "Q: Press 'Q' to quit."
}


# Prompt for Computer Name
$Computer = Read-Host "Computer Name"


# Prompt for OU to move to
do
{
     Show-Menu
     $input = Read-Host "Which OU should $Computer belong to?"
     switch ($input)
     {
           '1' {
                $ServerOU = "OU=Low,OU=Servers,OU=North_America,DC=LORD,DC=LOCAL"
                
                'Server will be moved to the' $ServerOU 'OU'
                } 
           
           '2' {
                $ServerOU = "OU=Moderate-A,OU=Servers,OU=North_America,DC=LORD,DC=LOCAL"
                
                'Server will be moved to the' $ServerOU 'OU'
               }

           '3' {
                $ServerOU = "OU=Moderate-B,OU=Servers,OU=North_America,DC=LORD,DC=LOCAL"
                
                'Server will be moved to the' $ServerOU 'OU'
                }

           '4' {
                $ServerOU = "OU=High,OU=Servers,OU=North_America,DC=LORD,DC=LOCAL"
                
                'Server will be moved to the' $ServerOU 'OU'
           }
           'q' {
                return
           }
     }
     pause
}
until ($input -eq 'q')

Get-ADComputer $Computer | Move-ADObject -TargetPath $ServerOU