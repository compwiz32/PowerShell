#--------------------------------------------------------------------------------- 
#The sample scripts are not supported under any Microsoft standard support 
#program or service. The sample scripts are provided AS IS without warranty  
#of any kind. Microsoft further disclaims all implied warranties including,  
#without limitation, any implied warranties of merchantability or of fitness for 
#a particular purpose. The entire risk arising out of the use or performance of  
#the sample scripts and documentation remains with you. In no event shall 
#Microsoft, its authors, or anyone else involved in the creation, production, or 
#delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, 
#loss of business information, or other pecuniary loss) arising out of the use 
#of or inability to use the sample scripts or documentation, even if Microsoft 
#has been advised of the possibility of such damages 
#--------------------------------------------------------------------------------- 

#requries -Version 2.0

<#
 	.SYNOPSIS
        This script is PowerShell script which can be used to get location of locked out user account.
    .DESCRIPTION
        This script is PowerShell script which can be used to get location of locked out user account.
    .PARAMETER  SamAccountName
		Specifies the SamAccountName of user that you want search.
    .EXAMPLE
        C:\PS> C:\Script\GetLockoutLocation.ps1 -SamAccountName "katrina"
        SamAccountName         : katrina
        LogonLocation          : EDGE1
        AccountLockoutTime     : 11/15/2013 1:46:53 AM
        LastBadPasswordAttempt : 11/15/2013 1:46:53 AM
        badPwdCount            : 3
#>
Param
(
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [Alias('sam')][String[]]$SamAccountName
)

#Check if ActiveDirectory module is imported.
If(-not(Get-Module -Name ActiveDirectory))
{
    Import-Module -Name ActiveDirectory
}

$DomainControllers = Get-ADDomainController -Discover -Service PrimaryDC

$Objs=@()
Foreach($DC in $DomainControllers)
{   
    #Use regular expression do string manipulation
    $EventInfos = Get-WinEvent -ComputerName $DC.Hostname -FilterHashtable @{Logname='Security';Id=4740} -ErrorAction SilentlyContinue
    [Regex]$RegexAccountName = "Account Name:\s+\w+.*"
    [Regex]$RegexDomainName = "Account Domain:\s+\w+.*"

    $EventInfos|Foreach{$MsgStr1=$_.message.LastIndexOf("Account Name:")
    $MsgStr2=$_.message.Substring($MsgStr1,$_.message.Length-$MsgStr1)
    $MsgStr3=($MsgStr2 -Split ":")
    $AccountName = ($MsgStr3 -split "`r`n")[1].Trim()
    $Location = ($MsgStr3 -split "`r`n")[6].Trim()
    $Events=New-Object -TypeName PSObject -Property @{SamAccountName = $AccountName; Location=$Location}
    $Objs+=$Events}

        
    If($SamAccountName)
    {
        Foreach($Account in $SamAccountName)
        {
            $LockedOutAccount = Get-ADUser -Filter {SamAccountName -eq $Account} -Server $DC.HostName `
            -Properties SamAccountName,AccountLockoutTime,LastBadPasswordAttempt,badPwdCount,LockedOut|`
            Where{$_.LockedOut -eq $true} | Select-Object SamAccountName,AccountLockoutTime,LastBadPasswordAttempt,badPwdCount,LockedOut
            $LockedOutInfo = $LockedOutAccount|Foreach{New-Object -TypeName PSObject `
            -Property @{SamAccountName = $_.SamAccountName;
                        LogonLocation = $($Name = $_.SamAccountName;`
                        $Objs|Where{$_.SamAccountName -eq $Name}|Sort -Unique|`
                        Select -ExpandProperty Location);
                        AccountLockoutTime = $_.AccountLockoutTime
                        LastBadPasswordAttempt = $_.LastBadPasswordAttempt;
                        badPwdCount = $_.badPwdCount}}
               
            $LockedOutInfo | Select SamAccountName,@{Expression={If($_.LogonLocation -eq $null){"Not Found"}Else{$_.LogonLocation}};`
            Label="LogonLocation"},AccountLockoutTime,LastBadPasswordAttempt,badPwdCount                                                                                            
        }
    }
    Else
    {
        $LockedOutAccount = Get-ADUser -Filter * -Server $DC.HostName `
        -Properties SamAccountName,AccountLockoutTime,LastBadPasswordAttempt,badPwdCount,LockedOut |`
        Where{$_.LockedOut-eq $true} | Select-Object SamAccountName,AccountLockoutTime,LastBadPasswordAttempt,badPwdCount,LockedOut
        $LockedOutInfo = $LockedOutAccount|Foreach{New-Object -TypeName PSObject `
        -Property @{SamAccountName = $_.SamAccountName;
                    LogonLocation = $($Name = $_.SamAccountName;`
                    $Objs|Where{$_.SamAccountName -eq $Name}|Sort -Unique|`
                    Select -ExpandProperty Location);
                    AccountLockoutTime = $_.AccountLockoutTime
                    LastBadPasswordAttempt = $_.LastBadPasswordAttempt;
                    badPwdCount = $_.badPwdCount}}

            $LockedOutInfo | Select SamAccountName,@{Expression={If($_.LogonLocation -eq $null){"Not Found"}Else{$_.LogonLocation}};`
            Label="LogonLocation"},AccountLockoutTime,LastBadPasswordAttempt,badPwdCount                                                                                            
    }
}