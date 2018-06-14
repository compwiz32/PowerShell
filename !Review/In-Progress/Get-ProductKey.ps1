function Get-ProductKey {
    <#
    .SYNOPSIS
        Retrieves the product key and OS information from a local or remote system/s.

    .DESCRIPTION
        Retrieves the product key and OS information from a local or remote system/s. Queries of 64bit OS from a 32bit OS will result in
        inaccurate data being returned for the Product Key. You must query a 64bit OS from a system running a 64bit OS.

    .PARAMETER Computername
        Name of the local or remote system/s.

    .NOTES
        Author: Boe Prox
        Version: 1.1
            -Update of function from http://powershell.com/cs/blogs/tips/archive/2012/04/30/getting-windows-product-key.aspx
            -Added capability to query more than one system
            -Supports remote system query
            -Supports querying 64bit OSes
            -Shows OS description and Version in output object
            -Error Handling

    .EXAMPLE
     Get-ProductKey -Computername Server1

    OSDescription                                           Computername OSVersion ProductKey
    -------------                                           ------------ --------- ----------
    Microsoft(R) Windows(R) Server 2003, Enterprise Edition Server1       5.2.3790  bcdfg-hjklm-pqrtt-vwxyy-12345

        Description
        -----------
        Retrieves the product key information from 'Server1'
    #>
    [cmdletbinding()]
    Param (
        [parameter(ValueFromPipeLine = $True, ValueFromPipeLineByPropertyName = $True)]
        [Alias("CN", "__Server", "IPAddress", "Server")]
        [string[]]$Computername = $Env:Computername
    )
    Begin {
        $map = "BCDFGHJKMPQRTVWXY2346789"
    }
    Process {
        ForEach ($Computer in $Computername) {
            Write-Verbose ("{0}: Checking network availability" -f $Computer)
            If (Test-Connection -ComputerName $Computer -Count 1 -Quiet) {
                Try {
                    Write-Verbose ("{0}: Retrieving WMI OS information" -f $Computer)
                    $OS = Get-WmiObject -ComputerName $Computer Win32_OperatingSystem -ErrorAction Stop
                }
                Catch {
                    $OS = New-Object PSObject -Property @{
                        Caption = $_.Exception.Message
                        Version = $_.Exception.Message
                    }
                }



                Try {
                    Write-Verbose ("{0}: Attempting remote registry access" -f $Computer)
                    $remoteReg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $Computer)
                    $value = $remoteReg.OpenSubKey("SOFTWARE\Microsoft\Windows NT\CurrentVersion").GetValue('DigitalProductId')[0x34..0x42]
                    $isWin8OrNewer = [math]::Floor(($value[14] / 6)) -band 1
                    $value[14] = ($value[14] -band 0xF7) -bor (($isWin8OrNewer -band 2) * 4)
                    $ProductKey = ""
                    Write-Verbose ("{0}: Translating data into product key" -f $Computer)
                    for ($i = 24; $i -ge 0; $i--) {
                        $r = 0
                        for ($j = 14; $j -ge 0; $j--) {
                            $r = ($r * 256) -bxor $value[$j]
                            $value[$j] = [math]::Floor([double]($r / 24))
                            $r = $r % 24
                        }
                        $ProductKey = $map[$r] + $ProductKey
                    }
                }
                Catch {
                    $ProductKey = $_.Exception.Message
                }

                if ($isWin8OrNewer) {
                    $ProductKey = $ProductKey.Remove(0, 1)
                    $ProductKey = $ProductKey.Insert($r, 'N')
                }

                #insert dashes to make key more readable
                for ($i = 5; $i -lt 29; $i = $i + 6) {
                    $ProductKey = $ProductKey.Insert($i, '-')
                }
                Catch {
                    $ProductKey = $_.Exception.Message
                }
                $object = New-Object PSObject -Property @{
                    Computername  = $Computer
                    ProductKey    = $ProductKey
                    OSDescription = $os.Caption
                    OSVersion     = $os.Version
                }
                $object.pstypenames.insert(0, 'ProductKey.Info')
                $object
            }
            Else {
                $object = New-Object PSObject -Property @{
                    Computername  = $Computer
                    ProductKey    = 'Unreachable'
                    OSDescription = 'Unreachable'
                    OSVersion     = 'Unreachable'
                }
                $object.pstypenames.insert(0, 'ProductKey.Info')
                $object
            }
        }
    }
}