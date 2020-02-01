###############################################################
#
#This Sample Code is provided for the purpose of illustration only
#and is not intended to be used in a production environment.  THIS
#SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED AS IS
#WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED,
#INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF
#MERCHANTABILITY ANDOR FITNESS FOR A PARTICULAR PURPOSE.  We
#grant You a nonexclusive, royalty-free right to use and modify
#the Sample Code and to reproduce and distribute the object code
#form of the Sample Code, provided that You agree (i) to not use
#Our name, logo, or trademarks to market Your software product in
#which the Sample Code is embedded; (ii) to include a valid
#copyright notice on Your software product in which the Sample
#
#Code is embedded; and (iii) to indemnify, hold harmless, and
#defend Us and Our suppliers from and against any claims or
#lawsuits, including attorneys’ fees, that arise or result from
#the use or distribution of the Sample Code.
#Please note None of the conditions outlined in the disclaimer
#above will supersede the terms and conditions contained within
#the Premier Customer Services Description.
#
###############################################################


[cmdletbinding()]
Param(
    [parameter()]
    [switch]$LatencyOnly,
    [parameter()]
    [string]$Domain,
    [array]$ListOfTCPPorts = ("88", "445", "389", "3268", "135", "139", "636", "3269", "464", "5722", "53", "9389", "5985", "5986"),
    [parameter()]
    [array]$ListOfUDPPorts = ("88", "389", "464", "123", "53"),
    [parameter()]
    [Array]$Server,
    [Switch]$Minimum,
    [Switch]$All
)

$Version = 1.3

if (-not (get-module activedirectory -ListAvailable)) {
    "Please install the Activate Directory Module"
    "        Install-WindowsFeature RSAT-AD-PowerShell"
    break
}

$VerbosePreference = [System.Management.Automation.ActionPreference]::Continue

if ($server -and $domain) { "Cannot use both -Server and -Domain"; break }
if (-not $server -and -not $domain) { while (-not $Domain) { $Domain = read-host "Domain" } }


#Function Test-port from https://gallery.technet.microsoft.com/scriptcenter/97119ed6-6fb2-446d-98d8-32d823867131

function Test-Port {
    <#
.SYNOPSIS
    Tests port on computer.

.DESCRIPTION
    Tests port on computer.

.PARAMETER computer
    Name of server to test the port connection on.

.PARAMETER port
    Port to test

.PARAMETER tcp
    Use tcp port

.PARAMETER udp
    Use udp port

.PARAMETER UDPTimeOut
    Sets a timeout for UDP port query. (In milliseconds, Default is 1000)

.PARAMETER TCPTimeOut
    Sets a timeout for TCP port query. (In milliseconds, Default is 1000)

.NOTES
    Name: Test-Port.ps1
    Author: Boe Prox
    DateCreated: 18Aug2010
    List of Ports: http://www.iana.org/assignments/port-numbers

    To Do:
        Add capability to run background jobs for each host to shorten the time to scan.
.LINK
    https://boeprox.wordpress.org

.EXAMPLE
    Test-Port -computer 'server' -port 80
    Checks port 80 on server 'server' to see if it is listening

.EXAMPLE
    'server' | Test-Port -port 80
    Checks port 80 on server 'server' to see if it is listening

.EXAMPLE
    Test-Port -computer @("server1","server2") -port 80
    Checks port 80 on server1 and server2 to see if it is listening

.EXAMPLE
    Test-Port -comp dc1 -port 17 -udp -UDPtimeout 10000

    Server   : dc1
    Port     : 17
    TypePort : UDP
    Open     : True
    Notes    : "My spelling is Wobbly.  It's good spelling but it Wobbles, and the letters
            get in the wrong places." A. A. Milne (1882-1958)

    Description
    -----------
    Queries port 17 (qotd) on the UDP port and returns whether port is open or not

.EXAMPLE
    @("server1","server2") | Test-Port -port 80
    Checks port 80 on server1 and server2 to see if it is listening

.EXAMPLE
    (Get-Content hosts.txt) | Test-Port -port 80
    Checks port 80 on servers in host file to see if it is listening

.EXAMPLE
    Test-Port -computer (Get-Content hosts.txt) -port 80
    Checks port 80 on servers in host file to see if it is listening

.EXAMPLE
    Test-Port -computer (Get-Content hosts.txt) -port @(1..59)
    Checks a range of ports from 1-59 on all servers in the hosts.txt file

#>
    [cmdletbinding(
        DefaultParameterSetName = '',
        ConfirmImpact = 'low'
    )]
    Param(
        [Parameter(
            Mandatory = $True,
            Position = 0,
            ParameterSetName = '',
            ValueFromPipeline = $True)]
        [array]$computer,
        [Parameter(
            Position = 1,
            Mandatory = $True,
            ParameterSetName = '')]
        [array]$port,
        [Parameter(
            Mandatory = $False,
            ParameterSetName = '')]
        [int]$TCPtimeout = 1000,
        [Parameter(
            Mandatory = $False,
            ParameterSetName = '')]
        [int]$UDPtimeout = 1000,
        [Parameter(
            Mandatory = $False,
            ParameterSetName = '')]
        [switch]$TCP,
        [Parameter(
            Mandatory = $False,
            ParameterSetName = '')]
        [switch]$UDP
    )
    Begin {
        If (!$tcp -AND !$udp) { $tcp = $True }
        #Typically you never do this, but in this case I felt it was for the benefit of the function
        #as any errors will be noted in the output of the report
        $ErrorActionPreference = "SilentlyContinue"
        $report = @()
    }
    Process {
        ForEach ($c in $computer) {
            ForEach ($p in $port) {
                If ($tcp) {
                    #Create temporary holder
                    $temp = "" | Select Server, Port, TypePort, Open, Notes
                    #Create object for connecting to port on computer
                    $tcpobject = new-Object system.Net.Sockets.TcpClient
                    #Connect to remote machine's port
                    $connect = $tcpobject.BeginConnect($c, $p, $null, $null)
                    #Configure a timeout before quitting
                    $wait = $connect.AsyncWaitHandle.WaitOne($TCPtimeout, $false)
                    #If timeout
                    If (!$wait) {
                        #Close connection
                        $tcpobject.Close()
                        #Write-Verbose "Connection Timeout"
                        #Build report
                        $temp.Server = $c
                        $temp.Port = $p
                        $temp.TypePort = "TCP"
                        $temp.Open = $False
                        $temp.Notes = "Connection to Port Timed Out"
                    }
                    Else {
                        $error.Clear()
                        $tcpobject.EndConnect($connect) | out-Null
                        #If error
                        If ($error[0]) {
                            #Begin making error more readable in report
                            [string]$string = ($error[0].exception).message
                            $message = (($string.split(":")[1]).replace('"', "")).TrimStart()
                            $failed = $true
                        }
                        #Close connection
                        $tcpobject.Close()
                        #If unable to query port to due failure
                        If ($failed) {
                            #Build report
                            $temp.Server = $c
                            $temp.Port = $p
                            $temp.TypePort = "TCP"
                            $temp.Open = $False
                            $temp.Notes = "$message"
                        }
                        Else {
                            #Build report
                            $temp.Server = $c
                            $temp.Port = $p
                            $temp.TypePort = "TCP"
                            $temp.Open = $True
                            $temp.Notes = ""
                        }
                    }
                    #Reset failed value
                    $failed = $Null
                    #Merge temp array with report
                    $report += $temp
                }
                If ($udp) {
                    #Create temporary holder
                    $temp = "" | Select Server, Port, TypePort, Open, Notes

                    #Create object for connecting to port on computer
                    $udpobject = new-Object system.Net.Sockets.Udpclient

                    #Set a timeout on receiving message
                    $udpobject.client.ReceiveTimeout = $UDPTimeout

                    #Connect to remote machine's port
                    #Write-Verbose "Making UDP connection to remote server"
                    $udpobject.Connect("$c", $p)

                    #Sends a message to the host to which you have connected.
                    #Write-Verbose "Sending message to remote host"
                    $a = new-object system.text.asciiencoding
                    $byte = $a.GetBytes("$(Get-Date)")
                    [void]$udpobject.Send($byte, $byte.length)

                    #IPEndPoint object will allow us to read datagrams sent from any source.
                    #Write-Verbose "Creating remote endpoint"
                    $remoteendpoint = New-Object system.net.ipendpoint([system.net.ipaddress]::Any, 0)
                    Try {
                        #Blocks until a message returns on this socket from a remote host.
                        #Write-Verbose "Waiting for message return"
                        $receivebytes = $udpobject.Receive([ref]$remoteendpoint)
                        [string]$returndata = $a.GetString($receivebytes)
                        If ($returndata) {
                            #Write-Verbose "Connection Successful"
                            #Build report
                            $temp.Server = $c
                            $temp.Port = $p
                            $temp.TypePort = "UDP"
                            $temp.Open = $True
                            $temp.Notes = $returndata
                            $udpobject.close()
                        }
                    }
                    Catch {
                        If ($Error[0].ToString() -match "\bRespond after a period of time\b") {
                            #Close connection
                            $udpobject.Close()
                            #Make sure that the host is online and not a false positive that it is open
                            If (Test-Connection -comp $c -count 1 -quiet) {
                                #Write-Verbose "Connection Open"
                                #Build report
                                $temp.Server = $c
                                $temp.Port = $p
                                $temp.TypePort = "UDP"
                                $temp.Open = $True
                                $temp.Notes = ""
                            }
                            Else {
                                <#
                                It is possible that the host is not online or that the host is online,
                                but ICMP is blocked by a firewall and this port is actually open.
                                #>
                                #Write-Verbose "Host maybe unavailable"
                                #Build report
                                $temp.Server = $c
                                $temp.Port = $p
                                $temp.TypePort = "UDP"
                                $temp.Open = $False
                                $temp.Notes = "Unable to verify if port is open or if host is unavailable."
                            }
                        }
                        ElseIf ($Error[0].ToString() -match "forcibly closed by the remote host" ) {
                            #Close connection
                            $udpobject.Close()
                            #Write-Verbose "Connection Timeout"
                            #Build report
                            $temp.Server = $c
                            $temp.Port = $p
                            $temp.TypePort = "UDP"
                            $temp.Open = $False
                            $temp.Notes = "Connection to Port Timed Out"
                        }
                        Else {
                            $udpobject.close()
                        }
                    }
                    #Merge temp array with report
                    $report += $temp
                }
            }
        }
    }
    End {
        #Generate Report
        $report
    }
}

function PortNote ($Port) {

    Switch ($Port) {

        88	{ $Return = "Must Fix, Kerberos Auth." }
        389	{ $Return = "Must Fix, LDAP" }
        636	{ $Return = "Must Fix, LDAPS" }
        445	{ $Return = "Must Fix, DFSR, Group Policy, Login scripts." }
        3268	{ $Return = "Must Fix, Global Catalog LDAP, UPN based login, Replication." }
        3269	{ $Return = "Must Fix, Global Catalog LDAPs, Secure UPN based login,Replication" }
        139	{ $Return = "Closed Ok, Legacy Linux access to DCs may be affected" }
        464 { $Return = "Must Fix, Kerberos based Password changes will be affected" }
        5722 { $Return = "Closed Ok, IF Target DC is WS 2008 R2 and below." }
        9389 { $Return = "Fix Recommended, PowerShell GET-AD* cmdlets will not work" }
        5985 { $Return = "Fix Recommended, PowerShell Remoting will not work" }
        5986 { $Return = "Closed Ok, PowerShell Remoting over SSL will not work IF it is configured." }
        123	{ $Return = "Must Fix, NTP based Time sync will fail" }
        53 { $Return = "Must Fix, IF the DC is being used as DNS server or relay" }
        135 { $Return = "Must Fix, RPC Endpoint Mapper" }

    }

    $Return
}

$Results = @()
Write-verbose "Version $version"


if ($Server) {

    $Server | foreach {

        $name = $_

        try {
            #Write-verbose "Resolving $_ ..."
            $Result = [System.Net.Dns]::GetHostByName($_).hostname
        }

        Catch {
            Write-host "`n`n`nERROR: Could not resolve $name, check the name, or DNS Servers and try again" -ForegroundColor Red
            Write-Verbose "DNS Servers:"
            (Get-WmiObject Win32_NetworkAdapterConfiguration).DNSServerSearchOrder | Sort-Object -Unique
            break

        }

    }
    $ServerList = $Server



}
else {

    import-module activedirectory -verbose:$false

    #First try to get obtain a list via Get-ADDomain
    Write-Verbose "Obtaining Domain Info ... "
    $DomainInfo = get-addomain -Identity $Domain

    $ForestInfo = get-adforest -Identity $DomainInfo.forest
    $MySite = (nltest /dsgetsite)[0]
    $ServerList = @()

    $Serverlist += new-object PSObject -Property (@{"Name" = $DomainInfo.PDCEmulator ; "Reason" = "PDC" })
    $Serverlist += new-object PSObject -Property (@{"Name" = $DomainInfo.RidMaster ; "Reason" = "RID Master" })
    $Serverlist += new-object PSObject -Property (@{"Name" = $DomainInfo.InfrastructureMaster ; "Reason" = "Infra Master" })
    $Serverlist += new-object PSObject -Property (@{"Name" = $ForestInfo.DomainNamingMaster ; "Reason" = "Domain Naming Master" })
    $Serverlist += new-object PSObject -Property (@{"Name" = $ForestInfo.SchemaMaster ; "Reason" = "Schema Master" })
    $ServerListtmp = $ServerList
    $serverList = @()
    $ServerListTmp | Group-Object -Property Name | foreach {
        $Serverlist += new-object PSObject -Property (@{"Name" = $_.Name ; "Reason" = $_.Group.Reason -join ", " })
    }


    If ($Minimum) {

        Write-Verbose "Selecting FSMO DCs and Potential Replica Partners ... "

        #Get Site info
        $SitesToResolve = @()
        $sListTmp = @()
        $PotentialPartners = @()
        $ConfigPath = $ForestInfo.PartitionsContainer -replace "CN=Partitions,", ""
        [adsi]$SiteLinks = "LDAP://CN=IP,CN=Inter-Site Transports,CN=Sites,$ConfigPath"

        #Go through each sitelink and where mysite is listed, record linked sites.
        $SiteLinks.children | foreach {
            $sName = $_.Name
            $sList = $_.SiteList
            $sList | foreach { $sListTmp += $(($_ -split "CN=")[1] -Replace ",", "") }

            if ($sListTmp -contains $MySite) {

                $sList | foreach { $SitesToResolve += $_ }

            }

        }

        #For each site in the list, get a list of DCs
        $SitesToResolve = $SitesToResolve | Sort-Object -Unique
        $SitesToResolve | foreach {
            $SiteName = $(($_ -split "CN=")[1] -Replace ",", "")
            [adsi]$Site = "LDAP://CN=Servers,$_"
            ($Site.Children | Select dNSHostName).dNSHostName | foreach {

                if ($ServerList.Name -notcontains $_) {

                    $Serverlist += new-object PSObject -Property (@{"Name" = $_ ; "Reason" = "Potential Replica Partner [$SiteName]" })
                }
            }
        }


    }
    else {

        Write-Verbose "Selecting ALL $Domain DCs..."
        $DomainInfo.ReplicaDirectoryServers | foreach {

            if ($ServerList.Name -notcontains $_) {

                $Serverlist += new-object PSObject -Property (@{"Name" = $_ ; "Reason" = "$Domain DC" })
            }

        }
    }

    if ($Serverlist.count -lt 1) {

        #Otherwise fallback to DNS Resolution
        Write-Verbose "Failed.`nFalling back to DNS for Domain controller resolution..."
        $ServerList = [System.Net.DNS]::Resolve($Domain).AddressList.IPAddressToString
    }

    if ($Serverlist.count -lt 1) {

        #Otherwise fallback to DNS Resolution
        Write-Verbose "Could not obtain a list of DCs for $domain"
        break
    }
}

# Test Port connectivity and Latency
$MyName = $([System.Net.Dns]::GetHostByName($env:computerName).Hostname)
Write-verbose "Source: $MyName"
$ServerList | ForEach-Object {

    $Server = $_.Name

    if ($Server -ne $MyName) {

        Write-Verbose "   Testing $Server [$($_.Reason)]..."


        #Test Latency
        try {
            $PingTest = Test-connection -ComputerName $Server -count 1 -ErrorAction SilentlyContinue
        }
        catch {
            Write-Verbose "$Server ping failed"
        }

        if ($LatencyOnly) {
            $Results += new-object PSObject -property (@{
 
                    "Latency"       = $PingTest.responsetime
                    "ComputerName"  = $Server
                    "Type"          = "TCP"
                    "RemoteAddress" = $PingTest.IPV4Address

                }) #new-object
        }

        else {

            #Test TCP ports

            $ListOfTCPPorts | foreach {

                $TCPResults = Test-port -computer $Server -port $_ -TCP

                $Results += new-object PSObject -property (@{
 
                        "Passed"        = $TCPResults.Open
                        "ComputerName"  = $Server
                        "Port"          = $_
                        "Type"          = "TCP"
                        "RemoteAddress" = $PingTest.IPV4Address
                        "Latency"       = $PingTest.responsetime
                        "Notes"         = if ($($TCPResults.open) -eq $false) { PortNote -Port $_ }
 
                    }) #new-object
            }


            #Test UDP ports
            $ListOfUDPPorts | foreach {

                $UDPResults = Test-port -computer $Server -port $_ -UDP

                $Results += new-object PSObject -property (@{
 
                        "Passed"        = $UDPResults.Open
                        "ComputerName"  = $Server
                        "Port"          = $_
                        "Type"          = "UDP"
                        "RemoteAddress" = $PingTest.IPV4Address
                        "Latency"       = $PingTest.Responsetime
                        "Notes"         = if ($($UDPResults.open) -eq $false) { PortNote -Port $_ }
 
                    }) #new-object
            }



        } #LatencyOnly

    }

}

if ($latencyonly) {
    $results | Sort-Object -Property Latency | ft -autosize
    $results | Sort-Object -Property Latency | ft -autosize | out-file PortTest.txt
    "Wrote PortTest.txt"
}
else {
    $Results | Sort-Object -Property Passed -Descending | ft Passed, Type, Port, ComputerName, RemoteAddress, Latency, Notes -autosize
    $Results | Sort-Object -Property Passed -Descending | ft Passed, Type, Port, ComputerName, RemoteAddress, Latency, Notes -autosize | out-file PortTest.txt
    "Wrote PortTest.txt"
}
