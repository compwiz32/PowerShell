Function Get-PageFileInfo {
<#
  .Synopsis
    Returns info about the page file size of a Windows computer. Defaults to local machine.

  .Description
    Returns the pagefile size info in MB. Also returns the PageFilePath, PageFileTotalSize,
    PagefileCurrentUsage, and PageFilePeakusage. Also returns if computer is using a TempPafeFile
    and if the machine's pagefile is managed by O/S (AutoManaged = true) or
    statically set (AutoManaged = False)

  .Example
    Get-PageFileInfo -computername SRV01
    Returns pagefile info for the computer named SRV01

    Computer             : SRV01
    FilePath             : C:\pagefile.sys
    AutoManagedPageFile  : True
    TotalSize (in MB)    : 8192
    CurrentUsage (in MB) : 60
    PeakUsage (in MB)    : 203
    TempPageFileInUse    : False


  .Example
    Get-PageFileInfo SRV01, SRV02
    Returns pagefile info for two computers named SRV01 & DC02.

    Computer             : SRV01
    FilePath             : C:\pagefile.sys
    AutoManagedPageFile  : True
    TotalSize (in MB)    : 8192
    CurrentUsage (in MB) : 60
    PeakUsage (in MB)    : 203
    TempPageFileInUse    : False

    Computer             : SRV02
    FilePath             : C:\pagefile.sys
    AutoManagedPageFile  : True
    TotalSize (in MB)    : 8192
    CurrentUsage (in MB) : 0
    PeakUsage (in MB)    : 0
    TempPageFileInUse    : False

  .Example
    Get-PageFileInfo SRV01, SRV02, SRV03 | Format-Table
    Returns pagefile info for three computers named SRV01, SRV02 & SRV03 in a table format.


    Computer  FilePath        AutoManagedPageFile TotalSize (in MB) CurrentUsage (in MB) PeakUsage (in MB) TempPageFileInUse
    --------  --------        ------------------- ----------------- -------------------- ----------------- -----------------
    SRV01    C:\pagefile.sys                True              8192                   60               203             False
    SRV02    C:\pagefile.sys                True             13312                    0                 0             False
    SRV03    C:\pagefile.sys                True              2432                    0                 0             False


  .Parameter computername
    The name of the computer to query. Required field.

  .NOTES
    Name       : Get-PageFileInfo.ps1
    Author     : Mike Kanakos
    Version    : 1.0.2
    DateCreated: 2018-08-28
    DateUpdated: 2019-01-15

  .LINK
    https://github.com/compwiz32/PowerShell


#>

[CmdletBinding()]
  Param(
      [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
      [string[]]$ComputerName
  )

# Main Part of function

Foreach ($computer in $ComputerName){

$online= Test-Connection -ComputerName $computer -Count 2 -Quiet

if ($online -eq $true){
  $PageFileResults = Get-CimInstance -Class Win32_PageFileUsage -ComputerName $Computer | Select-Object *
  $CompSysResults = Get-CimInstance win32_computersystem -ComputerName $Computer -Namespace 'root\cimv2'

  $PageFileStats = [PSCustomObject]@{
    Computer = $computer
    FilePath = $PageFileResults.Description
    AutoManagedPageFile = $CompSysResults.AutomaticManagedPagefile
    "TotalSize(in MB)" = $PageFileResults.AllocatedBaseSize
    "CurrentUsage(in MB)"  = $PageFileResults.CurrentUsage
    "PeakUsage(in MB)" = $PageFileResults.PeakUsage
    TempPageFileInUse = $PageFileResults.TempPageFile
    } #END PSCUSTOMOBJECT

  } #END IF

else{
  # Computer is not reachable!
  Write-Host "Error: $computer not online" -Foreground white -BackgroundColor Red
  } # END ELSE

$PageFileStats

  } #END FOREACH


} #END FUNCTION
