[‎7/‎24/‎2019 3:55 PM]  Aul, Steve L:  
No Title 
 $Names = Get-ChildItem -Path F:\TestUsers2 | ?{ $_.PSIsContainer } | Select-Object Name
foreach ($Name in $Names)
{
    Get-ChildItem -Path "f:\TestUsers2\User1" -Recurse -exclude Z_Scans | Select -ExpandProperty FullName | Where {$_ -notlike '*Z_Scans*'} | sort length -Descending | Remove-Item -Recurse -WhatIf
}


$FullNames = Get-ChildItem -Path F:\TestUsers2 | ?{ $_.PSIsContainer } | Select-Object FullName
foreach ($FullName in $FullNames)
{
    Get-ChildItem $FullName -Recurse -exclude Z_Scans | Select -ExpandProperty FullName | Where {$_ -notlike '*Z_Scans*'} | sort length -Descending | Remove-Item -Recurse -WhatIf
}



$Names = Get-ChildItem -Path F:\TestUsers2 | Where-Object { $_.PSIsContainer } | Select-Object Name

foreach ($Name in $FullNames)
{
    $parentpath = "F:\TestUsers2\"
    $A = Get-ChildItem -Path "$parentpath\$Name"
    Write-Host $A
}  
 

