Invoke-Command -ComputerName  'boe-pc' -ScriptBlock  {Get-ChildItem Cert:\LocalMachine\My  |   Where {$_.NotAfter -lt  (Get-Date).AddDays(14)}} | ForEach {

        [pscustomobject]@{

                            Computername =  $_.PSComputername
                            Subject =  $_.Subject
                            ExpiresOn =  $_.NotAfter

                            DaysUntilExpired = Switch ((New-TimeSpan -End $_.NotAfter).Days) {
                                {$_  -gt 0} {$_}
                                Default  {'Expired'}

                            }

        }

  } 




