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

        Counting # of files in: \\localhost\Temp
        
        ComputerName : localhost
        ShareName    : Temp
        Count        : 5
        SizeInMB     : 0.01
        SizeInGB     : 0

        
    .EXAMPLE
        Get-RemoteServerFileCount | Format-Table

        This command will return the filecounts from the shares on local machine

        Counting # of files in: \\localhost\Temp
        
        ComputerName ShareName             Count SizeInMB SizeInGB
        ------------ ---------             ----- -------- --------
        localhost    Temp                      5     0.01        0

    .EXAMPLE
        Get-RemoteServerFileCount -computername SRV01 | format-table
        This command will return the filecounts from the shares on server named SVR01
     
        Counting # of files in: \\SRV01\admin
        Counting # of files in: \\SRV01\Shared
        Counting # of files in: \\SRV01\Users

        ComputerName ShareName              Count  SizeInMB SizeInGB
        ------------ ---------              -----  -------- --------
        SVR01        admin                   2909   4630.99     4.52
        SVR01        Shared                 69775 130606.77   127.55
        SVR01        Users                   3638   1171.61     1.14

    .EXAMPLE
        Get-RemoteServerFileCount -computername SRV01 | export-csv c:\scripts\output\results.csv -notypeinformation

        Outputs the results of Get-RemoteServerFileCount to a CSV named EXPORT.CSV. This cmd produces no output to the console.


    .NOTES
        NAME: Get-Get-RemoteServerFileCount
        AUTHOR: Mike Kanakos
        CREATED: 2019-06-19
        LASTEDIT: 2019-06-24
        VERSION: v.0.0.4

        formatted table output with correxct header names
        
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

        $shares = Get-WmiObject -Class Win32_Share -ComputerName $ComputerName -Filter "NOT name LIKE '%$%'"
        $list = [System.Collections.Generic.List[psobject]]::new()
    
        ForEach ($share in $shares){
        
            $path = "\\$($ComputerName)\$($share.name)"
            
            Write-Host "Counting # of files in: " -foregroundColor Green -nonewline
            Write-Host $path -foregroundColor White

            $Results = Get-ChildItem -Path $path -File -recurse | Measure-Object -property length -sum | 
                Select-Object @{n='ComputerName';e={"$ComputerName"}},
                @{n='ShareName';e={$share.name}}, 
                @{n='FileCount';e='Count'},
                @{n='SizeInMB';e={[math]::Round(($_.Sum / 1MB),2)}}, 
                @{n='SizeInGB';e={[math]::Round(($_.Sum / 1GB),2)}}
                                
            $list.add($Results)
        
        } #end Foreach

        $list


    } 
    

      
    end {
        
    }
}

