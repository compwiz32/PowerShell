function Get-RunAsAccountUsage {
<#
.SYNOPSIS
Get RunAsAccountUsage for services and scheduled tasks on the specified computer using Windows Management Instrumentation (WMI) and schtasks.exe

.DESCRIPTION
Get RunAsAccountUsage for services and scheduled tasks on the specified computer using Windows Management Instrumentation (WMI) and schtasks.exe

.PARAMETER ComputerName
The computer to perform action against. Defaults to the local computer if not specified. Accepts ValueFromPipeline and ValueFromPipelineByPropertyName.

.PARAMETER RunAsUser
Filters returned objects based on username or domain name

.PARAMETER Logfile
Path to log-file (only errors is logged)

.EXAMPLE
Get-RunAsAccountUsage -ComputerName srv01 -RunAsUser contoso

.EXAMPLE
Get-RunAsAccountUsage -ComputerName (Get-Content c:\computernames.txt)

.EXAMPLE
Import-Module ActiveDirectory;Get-ADComputer -filter * | Select-Object @{l='computername';e={$_.Name}} | Get-RunAsAccount -RunAsUser contoso
.NOTES
AUTHOR:    Jan Egil Ring
BLOG:      http://blog.powershell.no
LASTEDIT:  22.11.2011
#Requires -Version 2.0
#>

    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [string[]]$ComputerName = "localhost",
        [string]$RunAsUser,
        [string]$Logfile
    )
    BEGIN {
    
       if ($logfile) {
        New-Item -Path $Logfile -ItemType file -Force | Out-Null
        }                   

    }

    PROCESS {

            foreach ($computer in $computername) {

                Get-RunAsAccountWorker -computername $computer

            }
      }
}

# Worker function
function Get-RunAsAccountWorker {
    param($computername)
    $continue = $True
    try {
        if ((Test-Connection -ComputerName $computername -Count 1 -Quiet) -and ($computersystem = Get-WmiObject -Class win32_computersystem -Computername $computername -ErrorAction stop)) {
        Write-Verbose "Connected to computer $computername"
        
        $connectivity = "Success"

        $output = @()

        #$services = Get-WmiObject win32_service -filter "(StartName Like '[^NT Authority]%') AND (StartName <> 'localsystem')" -ComputerName $computername -ErrorAction Stop | Select name,Startname
        $services = Get-WmiObject win32_service -filter "(StartName Like '%$runasuser%')" -ComputerName $computername -ErrorAction Stop | Select-Object name,startname

        if ($services) {
        
        foreach ($service in $services) {
        
        Write-Verbose "Processing NIC $($service.name)"

        $outputservice = @{}
        $outputservice.Computername = $computersystem.name
        $outputservice.Connectivity = "Success"
        $outputservice.Type = "Service"
        $outputservice.Name = $service.name
        $outputservice.RunAsAccount = $service.startname
        
        $output += $outputservice

        }

        }

        if ($RunAsUser) {
        $tasks = Get-ScheduledTask -ComputerName $computername -RunAsUser $RunAsUser | Select-Object taskname,runasuser
        }
        else {
        $tasks = Get-ScheduledTask -ComputerName $computername | Select-Object taskname,runasuser
        }

        if ($tasks) {
        
        foreach ($task in $tasks) {
        
        Write-Verbose "Processing task $($task.taskname)"

        $outputtask = @{}
        $outputtask.Computername = $computersystem.name
        $outputtask.Connectivity = "Success"
        $outputtask.Type = "ScheduledTask"
        $outputtask.Name = $task.taskname
        $outputtask.RunAsAccount = $task.runasuser
        
        $output += $outputtask

        }

        }
        

      }
          else {
        $outputinfo = @{}
        $outputinfo.Computername = $($computername)
        $outputinfo.Connectivity = "Failed (ping)"
        $outputinfo.Type = $null
        $outputinfo.Name = $null
        $outputinfo.RunAsAccount = $null
        
        $output += $outputinfo
    }
      



    } 
    
    catch {
        Write-Verbose "An error occured connecting to computer $computername"
        Write-Verbose $error[0].exception
        
        $outputinfo = @{}
        $outputinfo.Computername = $($computername)
        $outputinfo.Connectivity = "Failed (RPC)"
        $outputinfo.Type = $null
        $outputinfo.Name = $null
        $outputinfo.RunAsAccount = $null
        
        $output += $outputinfo

        if ($logfile) {
        $computername | Out-File -FilePath $Logfile -Append
        $error[0].exception | Out-File -FilePath $Logfile -Append
        }
    }
        
        Write-Verbose "Writing output object"
                
        if ($output) {
        foreach ($ht in $output) {
        
        New-Object -TypeName PSObject -Property $ht


             }

        }

        else {

        $outputinfo = @{}
        $outputinfo.Computername = $($computername)
        $outputinfo.Connectivity = "Success"
        $outputinfo.Type = $null
        $outputinfo.Name = $null
        $outputinfo.RunAsAccount = $null

        New-Object -TypeName PSObject -Property $outputinfo

        }

}

# Helper function by Claus Nielsen
# http://www.powershellmagazine.com/2011/11/21/managing-scheduled-tasks-in-your-environment-part-i

function Get-ScheduledTask
{
    [CmdletBinding()]

    param(
        [Parameter(
        Mandatory=$true,
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)]
        [String[]]$ComputerName,

        [Parameter(Mandatory=$false)]
        [String[]]$RunAsUser,

        [Parameter(Mandatory=$false)]
        [String[]]$TaskName,

        [parameter(Mandatory=$false)]
        [alias("WS")]
        [switch]$WithSpace
     )

    Begin
    {

        $Script:Tasks = @()
    }

    Process
    {
        $schtask = schtasks.exe /query /s $ComputerName  /V /FO CSV | ConvertFrom-Csv
        Write-Verbose  "Getting scheduled Tasks from: $ComputerName"

        if ($schtask)
        {
            foreach ($sch in $schtask)
            {
                if ($sch."Run As User" -match "$($RunAsUser)" -and $sch.TaskName -match "$($TaskName)")
                {
                    Write-Verbose  "$Computername ($sch.TaskName).replace('\','') $sch.'Run As User'"
                    $sch  | Get-Member -MemberType Properties | ForEach -Begin {$hash=@{}} -Process {
                        If ($WithSpace)
                        {
                            ($hash.($_.Name)) = $sch.($_.Name)
                        }
                        Else
                        {
                            ($hash.($($_.Name).replace(" ",""))) = $sch.($_.Name)
                        }
                    } -End {
                        $script:Tasks += (New-Object -TypeName PSObject -Property $hash)
                    }
          }
            }
        }
    }

    End
    {
        $Script:Tasks
    }
}