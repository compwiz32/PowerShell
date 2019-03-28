#requires -version 3.0

<#
This function has no provision for alternate credentials unless you run
it with Invoke-Command in a PSSession.
#>

Function Get-LocalUser {

    <#
    .SYNOPSIS
    Get local account information using ADSI.
    .DESCRIPTION
    This command uses ADSI to connect to a server and enumerate local user accounts. By default it will retrieve all local user accounts or you can specify one by name.
    The command uses legacy protocols to connect and enumerate accounts. You may find it more efficient to wrap this function in an Invoke-Command expression. See examples.
    NOTE: If you run this against a domain controller you will get your domain accounts.
    .PARAMETER Computername
    The name of a computer to query. The parameter has aliases of 'CN' and 'Host'.
    .PARAMETER Name
    The name of a local user account, like Administrator. The parameter has an alias of 'User'.
    .EXAMPLE
    PS C:\> Get-LocalUser chi-core01
    Computername    : CHI-CORE01
    User            : Administrator
    Description     : Built-in account for administering the computer/domain
    Enabled         : True
    LastLogin       : 3/5/2015 7:48:56 AM
    PasswordAgeDays : 456
    PasswordLastSet : 11/11/2014 6:02:05 PM
    Computername    : CHI-CORE01
    User            : Guest
    Description     : Built-in account for guest access to the computer/domain
    Enabled         : False
    LastLogin       :
    PasswordAgeDays : 659
    PasswordLastSet : 4/22/2014 9:01:02 AM
    Computername    : CHI-CORE01
    User            : LocalAdmin
    Description     : Chicago Local administrator account
    Enabled         : True
    LastLogin       : 2/24/2015 4:17:35 PM
    PasswordAgeDays : 342
    PasswordLastSet : 3/5/2015 7:46:32 AM
    .EXAMPLE
    PS C:\> "chi-hvr1","chi-hvr2" | get-localuser -name administrator | Select Computername,User,LastLogin,Pass*
    Computername    : CHI-HVR1
    User            : Administrator
    LastLogin       : 12/21/2015 12:55:31 PM
    PasswordAgeDays : 58
    PasswordLastSet : 12/14/2015 4:32:12 PM
    Computername    : CHI-HVR2
    User            : Administrator
    LastLogin       : 4/25/2014 1:50:28 PM
    PasswordAgeDays : 889
    PasswordLastSet : 9/4/2013 11:13:25 AM
    .EXAMPLE
    PS C:\> $s = new-pssession chi-core01,chi-fp02,chi-web02
    Create several PSSessions to remote computers.
    PS C:\> $sb = ${function:Get-localuser}
    Get the function's scriptblock
    PS C:\> Invoke-Command -scriptblock $sb -session $s -argumentlist "Administrator" | Select Computername,User,Pass*,Last*
    Computername    : CHI-CORE01
    User            : Administrator
    PasswordAgeDays : 456
    PasswordLastSet : 11/11/2014 6:02:05 PM
    LastLogin       : 3/5/2015 6:48:56 AM
    Computername    : CHI-FP02
    User            : Administrator
    PasswordAgeDays : 0
    PasswordLastSet : 2/10/2016 9:13:13 AM
    LastLogin       : 4/30/2013 8:08:49 AM
    Computername    : CHI-WEB02
    User            : Administrator
    PasswordAgeDays : 379
    PasswordLastSet : 1/27/2015 3:41:15 PM
    LastLogin       : 1/27/2015 5:48:12 PM
    Invoke the scriptblock and pass an account name as an argument.
    PS C:\> invoke-command -scriptblock $sb -Session $s -HideComputerName | Select * -ExcludeProperty RunspaceID | Out-GridView -title "Local Accounts"
    Get all local accounts by invoking the scriptblock remotely and display the results with Out-GridView.
    .EXAMPLE
    PS C:\> get-localuser -Name jeff -Computername chi-dc04
    Computername    : CHI-DC04
    User            : jeff
    Description     : IT Admin V
    Enabled         : True
    LastLogin       : 2/9/2016 5:06:22 PM
    PasswordAgeDays : 884
    PasswordLastSet : 9/9/2013 10:46:11 AM
    The command can be used to query domain accounts by selecting a domain controller.
    .NOTES
    NAME        :  Get-LocalUser
    VERSION     :  1.0
    LAST UPDATED:  2/10/2016
    AUTHOR      :  Jeff Hicks
    Learn more about PowerShell:
    http://jdhitsolutions.com/blog/essential-powershell-resources/
      ****************************************************************
      * DO NOT USE IN A PRODUCTION ENVIRONMENT UNTIL YOU HAVE TESTED *
      * THOROUGHLY IN A LAB ENVIRONMENT. USE AT YOUR OWN RISK.  IF   *
      * YOU DO NOT UNDERSTAND WHAT THIS SCRIPT DOES OR HOW IT WORKS, *
      * DO NOT USE IT OUTSIDE OF A SECURE, TEST SETTING.             *
      ****************************************************************
    .INPUTS
    [string] for computer names
    .OUTPUTS
    [object]
    #>

    [cmdletbinding()]
    Param(
    [Parameter(Position = 0)]
    [Alias("user")]
    [string]$Name,
    [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName)]
    [ValidateNotNullorEmpty()]
    [Alias("CN","host")]
    [string[]]$Computername = $env:computername
    )

    Begin {

        Write-Verbose "Starting: $($MyInvocation.Mycommand)"
        #define a constant
        $ADS_UF_ACCOUNTDISABLE = 0x0002

    } #begin

    Process {

        Foreach ($item in $Computername) {
            Write-Verbose "Connecting to $($item.toUpper())"

            if ($Name) {
                Write-Verbose "Querying for local account $Name"
                [ADSI]$LocalUser = "WinNT://$item/$name,user"
            }
            else {
                Write-Verbose "Querying for all local user accounts"
                [ADSI]$Computer = "WinNT://$item"
            }

            #if connection failed there won't be a Name property defined
            if ($Localuser.name -OR $Computer.name) {

                if ($Name) {
                    Write-Verbose "Found account for $($localuser.name)"
                    $users = $Localuser
                }
                else {
                    Write-Verbose "Filtering for user objects"
                    $users = $computer.psbase.children | where {$_.SchemaClassName -match "user"}
                    Write-Verbose "Found $($users.count) users"
                }

                Write-Verbose "Getting account details from $($item.ToUpper())"
                $users | Select-Object @{name="Computername";Expression={$item.ToUpper()}},
                @{name="User";Expression={$_.psbase.properties.name.value}},
                @{Name="Description";Expression={$_.psbase.properties.description.value}},
                @{name="Enabled";Expression={
                if ($_.psbase.properties.item("userflags").value -band $ADS_UF_ACCOUNTDISABLE) {
                    $False
                 }
                 else {
                    $True
                 }
                }},
                @{name="LastLogin";Expression={[datetime]$_.psbase.properties.lastLogin.value}},
                @{Name="PasswordAgeDays";Expression= {[int]($_.psbase.properties.passwordage.value/86400)}},
                @{Name="PasswordLastSet";Expression={(Get-Date).AddSeconds(-$_.psbase.properties.passwordage.value)}}
            }
            else {
                if ($Name) {
                    Write-Warning "Failed to find user $Name on $item."
                }
                else {
                    Write-Warning "Failed to connect to $item."
                }
            }
        } #foreach computer

    } #Process

    End {

        Write-Verbose "Ending: $($MyInvocation.Mycommand)"

    } #end

    } #end function

    #create an alias
    Set-Alias -Name glu -Value Get-LocalUser

    <#
    Copyright (c) 2016 JDH Information Technology Solutions, Inc.
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
    #>