$thisDC=Get-ADDomainController
                    $Me=$thisDC.NTDSSettingsObjectDN
                    $DomainPart=$thisDC.DefaultPartition
                    $MyName=$env:ComputerName
                    $MyNameFQDN=([System.Net.Dns]::GetHostByName(($env:computerName))).Hostname

                    $toConnect=Get-ADObject -Filter {objectClass -eq "nTDSConnection" } -SearchBase "CN=Configuration,$DomainPart" -Properties fromServer
                    $FromConnect=Get-ADObject -Filter {objectClass -eq "nTDSConnection" } -SearchBase $Me -Properties fromServer

                    $toPartnersDN=($toConnect | where fromServer -eq $me).DistinguishedName
                    $toPartners=$toPartnersDN | %{ $nbname=($_ -split ",")[2] -replace "CN=";$nbname }

                    $fromPartnersDN= $fromConnect | select -expand fromServer
                    $fromPartners=$fromPartnersDN | %{ $nbname=($_ -split ",")[1] -replace "CN=";$nbname}

                    "`n$MyName belongs to SITE: $(($me  -split ",")[3] -replace "CN=")`n"

                    "$Myname Replicates to:"
                    "------------"
                     $fromPartners 

                     ""
                    "$Myname Replicates from:"
                    "------------"
                    $toPartners

                    $cmd={ipconfig /flushdns;ping %host%}
                    $cmd -replace "%host%",$MyNameFQDN

                    $fromPartners  | % {
                        Invoke-Command -ComputerName $_ -ScriptBlock {$cmd}
                    }
                      $fromPartners  | % {
                        Invoke-Command -ComputerName $_ -ScriptBlock {$cmd }
                    } 

