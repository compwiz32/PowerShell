function Get-RemoteServerFileCount {
    <#
    .Synopsis
        Returns file counts from shares on local or remote computers 

    .DESCRIPTION
        Returns file counts from shares on local or remote computers. Uses Net view (old school!) to pull shares from servers and then parses the results
        into a useable table. This command was made for older server that don;t have PS v5 cmdlets loaded. 

    .PARAMETER Computername
        Name of computer that will be queried. Valid aliases are "Name","MachineName" or "Computer"

    .EXAMPLE
        Get-RemoteServerFileCount

        This command will return the filecounts from the shares on local machine

        \> Get-RestartInfo -Computername Server01 

        Computer : localhost
        Date     : 1/7/2019 5:16:50 PM
        Action   : shutdown
        Reason   : No title for this reason could be found
        User     : NWTRADERS.MSFT\Tom_Brady
        Process  : C:\WINDOWS\system32\shutdown.exe (CRDNAB-PC06LY52)
        Comment  :

        Computer : localhost
        Date     : 1/4/2019 5:36:58 PM
        Action   : shutdown
        Reason   : No title for this reason could be found
        User     : NWTRADERS.MSFT\Tom_Brady
        Process  : C:\WINDOWS\system32\shutdown.exe (CRDNAB-PC06LY52)
        Comment  :

        Computer : localhost
        Date     : 1/4/2019 9:10:11 AM
        Action   : restart
        Reason   : Operating System: Upgrade (Planned)
        User     : NT AUTHORITY\SYSTEM
        Process  : C:\WINDOWS\servicing\TrustedInstaller.exe (CRDNAB-PC06LY52)



    .EXAMPLE
        Get-Restartinfo SERVER01 | select-object Computer, Date, Action, Reason, User

        This command will return all the shutdown/restart eventlog info for server named SERVER01


        PS C:\Scripts\> Get-RestartInfo SERVER01 | Format-Table -AutoSize

        Computer    Date                  Action  Reason                                  User
        --------    ----                  ------  ------                                  ----
        SERVER01    12/15/2018 6:21:45 AM restart No title for this reason could be found NT AUTHORITY\SYSTEM
        SERVER01    11/17/2018 6:57:53 AM restart No title for this reason could be found NT AUTHORITY\SYSTEM
        SERVER01    9/29/2018  6:47:50 AM restart No title for this reason could be found NT AUTHORITY\SYSTEM


    .NOTES
        NAME: Get-Get-RemoteServerFileCount
        AUTHOR: Mike Kanakos
        CREATED: 2019-06-19
        LASTEDIT: 2019-06-19
        
    .Link
        https://github.com/compwiz32/PowerShell
    
    #>
    
    
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [alias("Name","MachineName","Computer")]
        [string[]]
        $ComputerName = 'localhost'
    )
    
    begin {
        
    }
    
    process {
    
        # $shares = net view \\$ComputerName | Select-Object -Skip 7 | ?{$_ -match 'disk*'} | %{$_ -match '^(.+?)\s+Disk*'|out-null;$matches[1]}
        $shares = Get-WmiObject -Class Win32_Share -ComputerName $ComputerName -Filter "NOT name LIKE '%$%'"

        
        ForEach ($share in $shares){
                        
            $Results = Get-ChildItem -Path \\$($ComputerName)\$($share.name) -recurse | Measure-Object -property length -sum | Select-Object Count, ({N = 'SizeinGB';E = 'Sum'}/1gb)
            $Results
        }

    }
    
    end {
        
    }
}

