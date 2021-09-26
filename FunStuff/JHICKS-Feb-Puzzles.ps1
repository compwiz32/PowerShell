#region 1. How many stopped services are on your computer?

(get-service | Where-Object status -like stop*).count

#endregion

#region 2. List services set to autostart but are not running

$selectParams = "Name", "DisplayName", "status", "StartType"
$svcs = get-service | Select-Object $selectParams
$svcs | Where-Object { $_.starttype -like "auto*" -and $_.status -like "stopped" }

#endregion

#region 3. List only the property names of the Win32_BIOS WMI class

#V5
(get-WmiObject -List Win32_BIOS).properties | Select-Object name

#V7
(Get-CimClass Win32_BIOS).CimClassProperties | Select-Object name

#endregion

#region 4. List all loaded functions displaying the name, number of parameter sets, and total number of lines in the function

$ParamSetCount = @{
    Name       = 'ParameterSetsCount';
    Expression = { ($_.parametersets).count }
}

$FunctionLineCount = @{
    Name       = 'LineCount'
    Expression = { (Get-Content $_ | Measure-Object -Line).Lines }
}

Set-Location function:\
get-item * | Select-Object Name, $ParamSetCount, $FunctionLineCount

#endregion

#region 5. Create a formatted report of Processes grouped by username

#original solution
Get-Process -IncludeUserName |
Group-Object UserName |
Select-Object @{n = "User"; e = { $_.Name }}, Count,
 @{ N = 'Group';  Expression = {$_.group.processname}} | sort count -Descending

$Processlist = Get-Process -IncludeUserName
$List = $Processlist | Group-Object UserName
$list | Select Name, Count, @{n="TotalWS";e={$_.Group.WS |
    Measure-Object -sum |
    Select-Object -ExpandProperty Sum}}

    @{Name="Owner";expression={$o = $.getOwner().User; if ($o) {$o} else {"NONE"}}}

#endregion

#region 6. Using previous code, display the username, the number of processes, the total workingset size. Set no username to NONE.

$list = Get-Process -IncludeUserName | Group-Object UserName | Select-Object @{n = "User"; e = { $_.Name }}, Count, @{ N = 'Group';  Expression = {$_.group}} | sort Username
$list | Select user, Count



$list | class ClassName {
    Select
} Name, Count, Group

foreach ($User in $List.User) {
     Measure-Object  workingset -sum
}

$list | Measure-Object Workingset -Sum  Select Name, Count, Group

foreach ($username in $List) {
    foreach ($Process in $Group) {
    }
    $item | Measure-Object Workingset -Sum

}
| Group-Object UserName
$Metrics = $Processlist | Measure-Object WorkingSet -Sum -Average
$Processlist | Select-Object @{n = "User"; e = { $_.Name }}, Count,  @{ N = 'Group';  Expression = {$_.group}} | sort Username

#endregion

#region 7. Create a report that shows files in %TEMP% by extension. Include Count,total size, % of total directory size

$Folder = Get-ChildItem $env:TEMP -Recurse
$TotalSize = $folder | Measure-Object -Sum Length | Select-Object @{ Name = 'TotalSize_MB';  Expression = {[math]::Round(($_.Sum)/1MB)}}

$folder | Where-Object { !$_.PSIsContainer } | Group-Object Extension |
    Select-Object @{n = "Extension"; e = { $_.Name }},
    Count,
    @{N = "Size_MB"; E = { [math]::Round((($_.Group | Measure-Object Length -Sum).Sum / 1MB), 2) }},
    @{N = 'Pct_of_Total'; E = { [math]::Round((((($_.Group | Measure-Object Length -Sum).Sum / 1MB) / $TotalSize.TotalSize_MB)* 100),2)}} |
         Sort-Object "Size_MB"

#endregion


#region 8. Find the total % of WS memory a process is using. Show top 10 processes,count,totalWS and PctUsedMemory


Get-Process | Sort WS -Descending | Select Name,WS -First 10




Get-Process brave -PipelineVariable pv |
    Measure-Object Workingset -sum -average |
    Select-object @{Name="Name";Expression = {$pv.name}},
    Count,
    @{Name="SumMB";Expression = {[math]::round($_.Sum/1MB,2)}},
    @{Name="AvgMB";Expression = {[math]::round($_.Average/1MB,2)}}






Get-Process svchost -PipelineVariable pv |
    Measure-Object Workingset -sum -average |
    Count,
    @{Name="SumMB";Expression = {[math]::round($_.Sum/1MB,2)}},
    @{Name="AvgMB";Expression = {[math]::round($_.Average/1MB,2)}}
#endregion

