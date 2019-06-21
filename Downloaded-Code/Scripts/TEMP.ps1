################################################################################
################################################################################
## Script description                                                         ##
##                                                                            ##
## Name      : ADReport.ps1                                                   ##
## Version   : 0.2                                                            ##
## Date      : 2014-12-15                                                     ##
## Language  : PowerShell cmd-lets                                            ##
## License   : Proprietary                                                    ##
## Owner     : Krzysztof Pytko (iSiek)                                        ##
## Authors   : Krzysztof Pytko (iSiek)  <kpytko at go2 dot pl>                ##
################################################################################
################################################################################


# Load PowerShell module for Active Directory
Import-Module ActiveDirectory


# Custom function to scan specified AD domain and collect data
function Get-DomainInfo($DomainName)

    {
        
        Write-Host ""
        Write-Host -ForegroundColor white -BackgroundColor black "Collecting Active Directory data..."

        # Start of data collection for specified domain by function
        $DomainInfo = Get-ADDomain $DomainName

        # Variables definition
        $domainSID = $DomainInfo.DomainSID
        $domainDN = $DomainInfo.DistinguishedName
        $domain = $DomainInfo.DNSRoot
        $NetBIOS = $DomainInfo.NetBIOSName
        $dfl = $DomainInfo.DomainMode

        # Domain FSMO roles
        $FSMOPDC = $DomainInfo.PDCEmulator
        $FSMORID = $DomainInfo.RIDMaster
        $FSMOInfrastructure = $DomainInfo.InfrastructureMaster

        $DClist = $DomainInfo.ReplicaDirectoryServers
        $RODCList = $DomainInfo.ReadOnlyReplicaDirectoryServers

        $cmp_location = $DomainInfo.ComputersContainer
        $usr_location = $DomainInfo.UsersContainer

        $FGPPNo = "feature not supported"




        # Get Domain Controller with at least Windows Server 2008 R2 OS 
        
        $DCListFiltered = Get-ADDomainController -Server $domain -Filter { operatingSystem -like "Windows Server 2008 R2*" -or operatingSystem -like "Windows Server 2012*" -or operatingSystem -like "Windows Server Technical Preview"  } | Select * -ExpandProperty Name
        $DCListFiltered | %{ $DCListFilteredIndex = $DCListFilteredIndex+1 }
       
        # End of 2008R2 DC list


        # if only one Windows Server 2008R2 Domain Controller exists
        
        if ( $DCListFilteredIndex -eq 1 )
            
            {

                # Get information about Default Domain Password Policy
                $pwdGPO = Get-ADDefaultDomainPasswordPolicy -Server $DCListFiltered


                # check DFL and get Fine-Grained Password Policies

                if ( $dfl -like "Windows2008Domain" -or $dfl -like "Windows2008R2Domain" -or $dfl -like "Windows2012Domain" -or $dfl -like "Windows2012R2Domain" )

                    {
                    
                        $FGPPNo = (Get-ADFineGrainedPasswordPolicy -Server $DCListFiltered -Filter * | Measure-Object).Count
                    
                    }
                # End of Fine-Grained Password Policies section


                # Get information about built-in domain Administrator account
                $builtinAdmin = Get-ADuser -Identity $domainSID-500 -Server $DCListFiltered -Properties Name, LastLogonDate, PasswordLastSet, PasswordNeverExpires, whenCreated, Enabled



                # Get total number of Domain Administrator group members
                $domainAdminsNo = (Get-ADGroup -Identity $domainSID-512 -Server $DCListFiltered | Get-ADGroupMember -Recursive | Measure-Object).Count


            }
        # End main IF section







        # if there are more than one Windows Server 2008R2 Domain Controllers
        else
        
            {

                # Get information about Default Domain Password Policy from the first DC on the list
                $pwdGPO = Get-ADDefaultDomainPasswordPolicy -Server $DCListFiltered[0]



                # check DFL and get Fine-Grained Password Policies
                if ( $dfl -like "Windows2008Domain" -or $dfl -like "Windows2008R2Domain" -or $dfl -like "Windows2012Domain" -or $dfl -like "Windows2012R2Domain" )
                
                    {
                    
                        $FGPPNo = (Get-ADFineGrainedPasswordPolicy -Server $DCListFiltered[0] -Filter * | Measure-Object).Count
                    
                    }
                # End of Fine-Grained Password Policies section



                # Get information about built-in domain Administrator account
                $builtinAdmin = Get-ADuser -Identity $domainSID-500 -Server $DCListFiltered[0] -Properties Name, LastLogonDate, PasswordLastSet, PasswordNeverExpires, whenCreated, Enabled



                # Get total number of Domain Administrators group members
                $domainAdminsNo = (Get-ADGroup -Identity $domainSID-512 -Server $DCListFiltered[0] | Get-ADGroupMember -Recursive | Measure-Object).Count


            }
        # End main ELSE section


        $usr_objectsNo = 0
        $usr_active_objectsNo = 0
        $usr_inactive_objectsNo = 0
        $usr_locked_objectsNo = 0
        $usr_pwdnotreq_objectsNo = 0
        $usr_pwdnotexp_objectsNo = 0

        $grp_objectsNo = 0
        $grp_objects_localNo = 0
        $grp_objects_universalNo = 0
        $grp_objects_globalNo = 0

        $cmp_objectsNo = 0

        $cmp_os_2000 = 0
        $cmp_os_xp = 0
        $cmp_os_7 = 0
        $cmp_os_8 = 0
        $cmp_os_81 = 0

        $cmp_srvos_2000 = 0
        $cmp_srvos_2003 = 0
        $cmp_srvos_2008 = 0
        $cmp_srvos_2008r2 = 0
        $cmp_srvos_2012 = 0
        $cmp_srvos_2012r2 = 0

        # Get information about Active Directory objects
        $ou_objectsNo = (Get-ADOrganizationalUnit -Server $domain -Filter * | Measure-Object).Count

        $cmp_objects = Get-ADComputer -Server $domain -Filter * -Properties operatingSystem
        $cmp_objectsNo = $cmp_objects.Count

        $cmp_objects | %{ if ($_.operatingSystem -like "Windows 2000 Professional*") { $cmp_os_2000 = $cmp_os_2000 + 1 } }
        $cmp_objects | %{ if ($_.operatingSystem -like "Windows XP*") { $cmp_os_xp = $cmp_os_xp + 1 } }
        $cmp_objects | %{ if ($_.operatingSystem -like "Windows 7*") { $cmp_os_7 = $cmp_os_7 + 1 } }
        $cmp_objects | %{ if ($_.operatingSystem -like "Windows 8 *") { $cmp_os_8 = $cmp_os_8 + 1 } }
        $cmp_objects | %{ if ($_.operatingSystem -like "Windows 8.1*") { $cmp_os_81 = $cmp_os_81 + 1 } }

        $cmp_objects | %{ if ($_.operatingSystem -like "Windows 2000 Server*") { $cmp_srvos_2000 = $cmp_srvos_2000 + 1 } }
        $cmp_objects | %{ if ($_.operatingSystem -like "Windows Server 2003*") { $cmp_srvos_2003 = $cmp_srvos_2003 + 1 } }
        $cmp_objects | %{ if ( ($_.operatingSystem -like "Windows Server 2008*") -and ($_.operatingSystem -notlike "Windows Server 2008 R2*") ) { $cmp_srvos_2008 = $cmp_srvos_2008 + 1 } }
        $cmp_objects | %{ if ($_.operatingSystem -like "Windows Server 2008 R2*") { $cmp_srvos_2008r2 = $cmp_srvos_2008r2 + 1 } }
        $cmp_objects | %{ if ( ($_.operatingSystem -like "Windows Server 2012 *") -and ($_.operatingSystem -notlike "Windows Server 2012 R2*") ) { $cmp_srvos_2012 = $cmp_srvos_2012 + 1 } }
        $cmp_objects | %{ if ($_.operatingSystem -like "Windows Server 2012 R2*") { $cmp_srvos_2012r2 = $cmp_srvos_2012r2 + 1 } }

        $grp_objects = Get-ADGroup -Server $domain -Filter * -Properties GroupScope
        $grp_objectsNo = $grp_objects.Count
        $grp_objects | %{ if ($_.GroupScope -eq "DomainLocal") { $grp_objects_localNo = $grp_objects_localNo + 1 } }
        $grp_objects | %{ if ($_.GroupScope -eq "Universal") { $grp_objects_universalNo = $grp_objects_universalNo + 1 } }
        $grp_objects | %{ if ($_.GroupScope -eq "Global") { $grp_objects_globalNo = $grp_objects_globalNo + 1 } }

        $usr_objects = Get-ADUser -Server $domain -Filter * -Properties Enabled, LockedOut, PasswordNeverExpires, PasswordNotRequired
        $usr_objectsNo = $usr_objects.Count
        $usr_objects | %{ if ($_.Enabled -eq $True) { $usr_active_objectsNo = $usr_active_objectsNo + 1 } }
        $usr_objects | %{ if ($_.Enabled -eq $False) { $usr_inactive_objectsNo = $usr_inactive_objectsNo + 1 } }
        $usr_objects | %{ if ($_.LockedOut -eq $True) { $usr_locked_objectsNo = $usr_locked_objectsNo + 1 } }
        $usr_objects | %{ if ($_.PasswordNotRequired -eq $True) { $usr_pwdnotreq_objectsNo = $usr_pwdnotreq_objectsNo + 1 } }
        $usr_objects | %{ if ($_.PasswordNeverExpires -eq $True) { $usr_pwdnotexp_objectsNo = $usr_pwdnotexp_objectsNo + 1 } }



        # Display gathered domain details on the screen
        Write-Host ""
        Write-Host ""
        
        Write-Host -ForegroundColor yellow -BackgroundColor black "Current domain details:"
        
        Write-Host ""
        
        Write-Host "DNS domain name"
        Write-Host -ForegroundColor green $domain
        
        Write-Host ""
        
        Write-Host "NetBIOS domain name"
        Write-Host -ForegroundColor green $NetBIOS
        
        Write-Host ""



        # Check and display DFL
        Write-Host "Domain Functional Level"

        switch ($dfl)
        
            {
                Windows2000Domain { Write-Host -ForegroundColor green "Windows 2000 native" }
                Windows2003Domain { Write-Host -ForegroundColor green "Windows Server 2003" }
                Windows2008Domain { Write-Host -ForegroundColor green "Windows Server 2008" }
                Windows2008R2Domain { Write-Host -ForegroundColor green "Windows Server 2008 R2" }
                Windows2012Domain { Write-Host -ForegroundColor green "Windows Server 2012" }
                Windows2012R2Domain { Write-Host -ForegroundColor green "Windows Server 2012 R2" }
                default { Write-Host -ForegroundColor red "Unknown Domain Functional Level:"$dfl }
                
            }
            
        Write-Host ""
        # End DFL section




        # SYSVOL replication method
        Write-Host "SYSVOL replication method"
        
        $FRSsysvol = "CN=Domain System Volume (SYSVOL share),CN=File Replication Service,CN=System,"+(Get-ADDomain $domain).DistinguishedName
        $DFSRsysvol = "CN=Domain System Volume,CN=DFSR-GlobalSettings,CN=System,"+(Get-ADDomain $domain).DistinguishedName

        $frs = Get-ADObject -Filter { distinguishedName -eq $FRSsysvol }
        $dfsr = Get-ADObject -Filter { distinguishedName -eq $DFSRsysvol } 

        if ( $frs -ne $nul ) { Write-Host -ForegroundColor red "FRS" }
        
            elseif ( $dfsr -ne $nul ) { Write-Host -ForegroundColor green "DFS-R" }
        
        else { Write-Host -ForegroundColor Red "unknown" }

        Write-Host ""
        # End of SYSVOL replication section




        # List of Domain Controllers
        Write-Host "List of Domain Controllers"
        
        $DCList | Sort | %{ Write-Host -ForegroundColor green $_.TrimEnd($domain).toUpper() }

        Write-Host ""


        Write-Host "List of Read-Only Domain Controllers"

        if ( $RODCList.Count -ne 0 )
        
            {
            
                $RODCList | %{ Write-Host -ForegroundColor green $_.TrimEnd($domain).toUpper() }
            
            }

        else
        
            {
            
                Write-Host -ForegroundColor green "(none)"
            
            }

        Write-Host ""
        # End of Domain Controllers list section




        # Global Catalogs in a domain
        Write-Host "Global Catalog servers in the domain"
        
        $ForestGC | Sort | %{ if ( $_ -match $DomainName -and ((( $_ -replace $DomainName ) -split "\.").Count -eq 2 ))
        
            {
            
                Write-Host -ForegroundColor green ($_.TrimEnd($domain).toUpper()) }
            
            }

        Write-Host ""
        # End of Global Catalogs section




        # Display information about domain objects

        # Domain computer objects location
        Write-Host "Default domain computer objects location"

        if ($cmp_location.Contains("CN=Computers"))
            
            {
            
                Write-Host -ForegroundColor green $cmp_location -NoNewLine
                Write-Host -ForegroundColor yellow " (not redirected)"
            
            }

        else
        
            {
            
                Write-Host -ForegroundColor green $cmp_location -NoNewLine
                Write-Host -ForegroundColor red " (redirected)"
            
            }

        Write-Host ""
        # End of domain computer objects location


        # Domain user objects location
        Write-Host "Default domain user objects location"
        
            if ($usr_location.Contains("CN=Users"))
            
                {
                
                    Write-Host -ForegroundColor green $usr_location -NoNewLine
                    Write-Host -ForegroundColor yellow " (not redirected)"
                
                }
                
            else
            
                {
                
                    Write-Host -ForegroundColor green $usr_location -NoNewLine
                    Write-Host -ForegroundColor red " (redirected)"
                
                }
                
        Write-Host ""
        # End of domain user objects location



        # Check if orphaned objects exist
        Write-Host ""
        
        Write-Host -ForegroundColor Yellow -BackgroundColor Black "Domain objects statistic:"
        
        Write-Host ""

        $orphaned = Get-ADObject -Filter * -SearchBase "cn=LostAndFound,$($domainDN)" -SearchScope OneLevel | Measure-Object

        if ($orphaned.Count -ne 0)
        
            {
            
                Write-Host -ForegroundColor Red "$($orphaned.Count) orphaned objects have been found!"
            
            }
            
        else
        
            {
            
                Write-Host -ForegroundColor Green "No orphaned objects have been found"
            
            }
        # End of orphaned objects check



        # Check if lingering objects or conflict replication objects exist

        $lingConfRepl = Get-ADObject -LDAPFilter "(cn=*\0ACNF:*)" -SearchBase $domainDN -SearchScope SubTree | Measure-Object

        if ($lingConfRepl.Count -ne 0)
        
            {
            
                Write-Host -ForegroundColor Red "$($lingConfRepl.Count) lingering or replication conflict objects have been found!"
            
            }
            
        else
        
            {
            
                Write-Host -ForegroundColor Green "No lingering or replication conflict objects have been found"
            
            }


        Write-Host ""
        Write-Host ""
        # End of lingering objects check


        # Total number of Organizational Units
        Write-Host "Total number of Organizational Unit objects : " -NoNewLine
        Write-Host -ForegroundColor green $ou_objectsNo
        
        Write-Host ""
        
        Write-Host "Total number of computer objects : " -NoNewLine
        Write-Host -ForegroundColor green $cmp_objectsNo
        
        Write-Host ""
        
        Write-Host "  Client systems"
        Write-host -ForegroundColor yellow "  Windows 2000                   : " -NoNewLine
        Write-Host -ForegroundColor green $cmp_os_2000
        Write-host -ForegroundColor yellow "  Windows XP                     : " -NoNewLine
        Write-Host -ForegroundColor green $cmp_os_xp
        Write-host -ForegroundColor yellow "  Windows 7                      : " -NoNewLine
        Write-Host -ForegroundColor green $cmp_os_7
        Write-host -ForegroundColor yellow "  Windows 8                      : " -NoNewLine
        Write-Host -ForegroundColor green $cmp_os_8
        Write-host -ForegroundColor yellow "  Windows 8.1                    : " -NoNewLine
        Write-Host -ForegroundColor green $cmp_os_81
        
        Write-Host ""
        
        Write-Host "  Server systems"
        Write-host -ForegroundColor yellow "  Windows 2000 Server            : " -NoNewLine
        Write-Host -ForegroundColor green $cmp_srvos_2000
        Write-host -ForegroundColor yellow "  Windows Server 2003            : " -NoNewLine
        Write-Host -ForegroundColor green $cmp_srvos_2003
        Write-host -ForegroundColor yellow "  Windows Server 2008            : " -NoNewLine
        Write-Host -ForegroundColor green $cmp_srvos_2008
        Write-host -ForegroundColor yellow "  Windows Server 2008R2          : " -NoNewLine
        Write-Host -ForegroundColor green $cmp_srvos_2008r2
        Write-host -ForegroundColor yellow "  Windows Server 2012            : " -NoNewLine
        Write-Host -ForegroundColor green $cmp_srvos_2012
        Write-host -ForegroundColor yellow "  Windows Server 2012R2          : " -NoNewLine
        Write-Host -ForegroundColor green $cmp_srvos_2012r2
        
        Write-Host ""
        # End of total OUs number


        # Total number of domain users
        Write-Host ""
        
        Write-Host "Total number of user objects  : " -NoNewLine
        Write-Host -ForegroundColor green $usr_objectsNo
        Write-host -ForegroundColor yellow "  Active                      : " -NoNewLine
        Write-Host -ForegroundColor green $usr_active_objectsNo
        Write-host -ForegroundColor yellow "  Inactive                    : " -NoNewLine
        Write-Host -ForegroundColor green $usr_inactive_objectsNo
        Write-host -ForegroundColor yellow "  Locked out                  : " -NoNewLine
        Write-Host -ForegroundColor green $usr_locked_objectsNo
        Write-host -ForegroundColor yellow "  Password not required       : " -NoNewLine
        Write-Host -ForegroundColor green $usr_pwdnotreq_objectsNo
        Write-host -ForegroundColor yellow "  Password never expires      : " -NoNewLine
        Write-Host -ForegroundColor green $usr_pwdnotexp_objectsNo
        
        Write-Host ""
        # End of total domain users number


        # Total number of domain groups
        Write-Host "Total number of group objects : " -NoNewLine
        Write-Host -ForegroundColor green $grp_objectsNo
        Write-Host -ForegroundColor yellow "  Global                      : " -NoNewLine
        Write-Host -ForegroundColor green $grp_objects_globalNo
        Write-Host -ForegroundColor yellow "  Universal                   : " -NoNewLine
        Write-Host -ForegroundColor green $grp_objects_universalNo
        Write-Host -ForegroundColor yellow "  Domain Local                : " -NoNewLine
        Write-Host -ForegroundColor green $grp_objects_localNo
        
        Write-Host ""
        # End of total domain groups number




        # Total number of domain administrators
        Write-Host ""
        
        Write-Host "Total number of Domain Administrators: " -NoNewline
        
        if ( $domainAdminsNo -ge 1 -and $domainAdminsNo -le 5 )
        
            {
            
                Write-Host -ForegroundColor green $domainAdminsNo
            
            }

        else
        
            {
            
            Write-Host -ForegroundColor red $domainAdminsNo
            
            }
        
        Write-Host ""
        Write-Host ""
        # End of total domain administrators number



        # Details about built-in domain Administrator account
        Write-Host -ForegroundColor yellow -BackgroundColor black "Built-in Domain Administrator account details:"
        
        Write-Host ""
        
        Write-Host "Account name: " -NoNewline
        Write-Host -ForegroundColor green $builtinAdmin.Name

        Write-Host "Account status: " -NoNewline

        if ( $builtinAdmin.Enabled )
        
            {
            
                Write-Host -ForegroundColor red "enabled"
            
            }
            
        else

            {
            
                Write-Host -ForegroundColor green "disabled"
            
            }

        Write-Host "Password never expires: " -NoNewline
        
        if ( $builtinAdmin.PasswordNeverExpires )
        
            {
            
                Write-Host -ForegroundColor red "yes"
            
            }
            
        else
        
            {
            
                Write-Host -ForegroundColor green "no"
            
            }

        Write-Host ""
        
        Write-Host "Promoted to domain account"
        Write-Host -ForegroundColor green $builtinAdmin.whenCreated
        
        Write-Host ""
        
        Write-Host "Last password change"
        Write-Host -ForegroundColor green $builtinAdmin.PasswordLastSet
        
        Write-Host ""
        
        Write-Host "Last logon date"
        Write-Host -ForegroundColor green $builtinAdmin.LastLogonDate

        Write-Host ""
        Write-Host ""
        # End of domain objects information section




        # FSMO roles for domain
        Write-Host -ForegroundColor yellow -BackgroundColor black "FSMO roles details:"
        
        Write-Host ""
        
        Write-Host "PDC Emulator master"
        Write-Host -ForegroundColor green $FSMOPDC.toUpper()
        
        Write-Host ""
        
        Write-Host "RID master"
        Write-Host -ForegroundColor green $FSMORID.toUpper()
        
        Write-Host ""
        
        Write-Host "Infrastructure master"
        Write-Host -ForegroundColor green $FSMOInfrastructure.toUpper()
        
        Write-Host ""
        # End of domain FSMO section



        # Check default domain policy existance
        $gpoDefaultDomain = Get-ADObject -Server $domain -LDAPFilter "(&(objectClass=groupPolicyContainer)(cn={31B2F340-016D-11D2-945F-00C04FB984F9}))"
        $gpoDefaultDomainController = Get-ADObject -Server $domain -LDAPFilter "(&(objectClass=groupPolicyContainer)(cn={6AC1786C-016F-11D2-945F-00C04fB984F9}))"

        Write-Host -ForegroundColor yellow -BackgroundColor black "Default Domain policies check:"
        
        Write-Host ""

        if ($gpoDefaultDomain -ne $nul)
        
            {
            
                Write-Host "Default Domain policy             : " -NoNewLine
                Write-Host -ForegroundColor Green "exists"
            
            }
            
        else
        
            {
            
                Write-Host -ForegroundColor Red "does not exist"
            
            }


        if ($gpoDefaultDomainController -ne $nul)
        
            {
            
                Write-Host "Default Domain Controllers policy : " -NoNewLine
                Write-Host -ForegroundColor Green "exists"
            
            }
            
        else
        
            {
            
                Write-Host -ForegroundColor Red "does not exist"
            
            }

        Write-Host ""
        # End of default domain policies check



        # Default Domain Password Policy details
        Write-Host -ForegroundColor yellow -BackgroundColor black "Default Domain Password Policy details:"
        
        Write-Host ""
        
        Write-Host "Minimum password age: " -NoNewLine
        Write-Host -ForegroundColor green $pwdGPO.MinPasswordAge.days "day(s)"
        Write-Host "Maximum password age: " -NoNewLine
        Write-Host -ForegroundColor green $pwdGPO.MaxPasswordAge.days "day(s)"
        Write-Host "Minimum password length: " -NoNewline
        Write-Host -ForegroundColor green $pwdGpo.MinPasswordLength "character(s)"
        Write-Host "Password history count: " -NoNewLine
        Write-Host -ForegroundColor green $pwdGPO.PasswordHistoryCount "unique password(s)"

        Write-Host "Password must meet complexity: " -NoNewLine
        
        if ( $pwdGPO.ComplexityEnabled )
        
            {
            
                Write-Host -ForegroundColor green "yes"
            
            }
            
        else
        
            {
            
                Write-Host -ForegroundColor red "no"
            
            }

        Write-Host "Password uses reversible encryption: " -NoNewLine
        
        if ( $pwdGPO.ReversibleEncryptionEnabled )
        
            {
            
                Write-Host -ForegroundColor red "yes"
            
            }
            
        else
        
            {
            
                Write-Host -ForegroundColor green "no"
            
            }

        Write-Host ""
        
        Write-Host "Account lockout treshold: " -NoNewLine
        
        if ($pwdGPO.LockoutThreshold -eq 0 )
        
            {
            
                Write-Host -ForegroundColor red "Account never locks out"
            
            }
            
        else
        
            {
            
                Write-Host -ForegroundColor green $pwdGPO.LockoutThreshold "invalid logon attempts"
                Write-Host "Account lockout duration time: " -NoNewline
                
                if ( $pwdGPO.LockoutDuration.days -eq 0 -and $pwdGPO.LockoutDuration.hours -eq 0 -and $pwdGPO.LockoutDuration.minutes -eq 0 )
                
                    {
                    
                        Write-Host -ForegroundColor red "Password may be unlocked by an administrator only"
                    
                    }
                    
                else
                
                    {
                    
                        Write-Host -ForegroundColor yellow $pwdGPO.LockoutDuration.days "day(s)"$pwdGPO.LockoutDuration.hours "hour(s)"$pwdGPO.LockoutDuration.minutes "min(s)"
                        Write-Host "Account lockout counter resets after: " -NoNewline
                        Write-Host -ForegroundColor yellow $pwdGPO.LockoutObservationWindow.days "day(s)"$pwdGPO.LockoutObservationWindow.hours "hour(s)"$pwdGPO.LockoutObservationWindow.minutes "min(s)"
                    
                    }
                    
            }
            # End of Default Domain Password Policy details




            # Display total number of Fine-Grained Password Policies
            Write-Host ""
            
            Write-Host "Fine-Grained Password Policies: " -NoNewline
            Write-Host -ForegroundColor green $FGPPNo
            
            Write-Host ""


    }
    # End of custom Get-DomainInfo function




    # Main script section
    Clear-Host

    Write-Host -ForegroundColor white -BackgroundColor black "Collecting Active Directory data..."

    # Checking if PowerShell script was executed with a parameter

    if ( $args.Length -gt 0 )
    
        {
        
            # Collecting information about specified Forest configuration
            $ForestInfo=Get-ADForest $args[0]
        
        }
        
    else
    
        {
        
            # Collecting information about current Forest configuration
            $ForestInfo=Get-ADForest
       
        }
    # End of parameter check





    # Forest variables definition
    $forest=$ForestInfo.RootDomain
    $allDomains=$ForestInfo.Domains

    $ForestGC=$ForestInfo.GlobalCatalogs
    $UPNsuffix=$ForestInfo.UPNSuffixes

    $ffl=$ForestInfo.ForestMode

    $FSMODomainNaming=$ForestInfo.DomainNamingMaster
    $FSMOSchema=$ForestInfo.SchemaMaster

    $forestDomainSID = Get-ADDomain (Get-ADForest).Name | Select domainSID


    $ADRecBinSupport="feature not supported"

    if ( $ffl -like "Windows2008R2Forest" -or $ffl -like "Windows2012Forest" -or $ffl -like "Windows2012R2Forest" )
    
        {
        
            $ADRecBin=(Get-ADOptionalFeature -Server $forest -Identity 766ddcd8-acd0-445e-f3b9-a7f9b6744f2a).EnabledScopes | Measure-Object

            if ( $ADRecBin.Count -ne 0 )
            
                {
                
                    $ADRecBinSupport="Enabled"
                
                }
                
            else
            
                {
                
                    $ADRecBinSupport="Disabled"
                
                }

        }
    # End of forest variables section




    # Define Schema partition variables
    
    $SchemaPartition = $ForestInfo.PartitionsContainer.Replace("CN=Partitions","CN=Schema")
    $SchemaVersion = Get-ADObject -Server $forest -Identity $SchemaPartition -Properties * | Select objectVersion
    
    # End of Schema partition variables definition


    $forestDN = $ForestInfo.PartitionsContainer.Replace("CN=Partitions,CN=Configuration,","")
    $configPartition = $ForestInfo.PartitionsContainer.Replace("CN=Partitions,","")



    # Display collected data
    Clear-Host
    Write-Host -ForegroundColor white -BackgroundColor black "Active Directory report v0.2 by Krzysztof Pytko (iSiek)"

    Write-Host ""
    Write-Host ""


    # Display information about Forest
    Write-Host -ForegroundColor yellow -BackgroundColor black "Forest details:"
    
    Write-Host ""
    
    Write-Host "Forest name"
    Write-Host -ForegroundColor green $forest
    
    Write-Host ""




    # Determine and display schema version
    Write-Host "Active Directory schema version"

    switch ($SchemaVersion.objectVersion)

        {
        
            13 { Write-Host -ForegroundColor green $SchemaVersion.objectVersion "- Windows 2000 Server" }
            30 { Write-Host -ForegroundColor green $SchemaVersion.objectVersion "- Windows Server 2003"  }
            31 { Write-Host -ForegroundColor green $SchemaVersion.objectVersion "- Windows Server 2003 R2" }
            44 { Write-Host -ForegroundColor green $SchemaVersion.objectVersion "- Windows Server 2008" }
            47 { Write-Host -ForegroundColor green $SchemaVersion.objectVersion "- Windows Server 2008 R2" }
            51 { Write-Host -ForegroundColor green $SchemaVersion.objectVersion "- Windows Server 8 Developers Preview" }
            52 { Write-Host -ForegroundColor green $SchemaVersion.objectVersion "- Windows Server 8 Beta" }
            56 { Write-Host -ForegroundColor green $SchemaVersion.objectVersion "- Windows Server 2012" }
            69 { Write-Host -ForegroundColor green $SchemaVersion.objectVersion "- Windows Server 2012 R2" }
            72 { Write-Host -ForegroundColor green $SchemaVersion.objectVersion "- Windows Server Technical Preview" }
            default { Write-Host -ForegroundColor red "unknown - "$SchemaVersion.objectVersion }
       
        }
    
    Write-Host ""
    # End of schema version section



    # Determine and display Exchange version
    Write-Host "Microsoft Exchange version"

    $ExchangeSystemObjects = Get-ADObject -Server $forest -LDAPFilter "(&(objectClass=container)(name=Microsoft Exchange System Objects))" -SearchBase $forestDN -Properties objectVersion
    $ExchangeSchemaVersion = Get-ADObject -Server $forest -LDAPFilter "(&(objectClass=attributeSchema)(name=ms-Exch-Schema-Version-Pt))" -SearchBase $SchemaPartition -Properties rangeUpper

    $ExchangeSchema = $ExchangeSystemObjects.objectVersion + $ExchangeSchemaVersion.rangeUpper

    if ($ExchangeSchemaVersion -ne $nul)
    
        {
        
            switch ($ExchangeSchema)
            
                {
                
                    13806  { Write-Host -ForegroundColor green "Exchange Server 2003" }
                    21265 { Write-Host -ForegroundColor green "Exchange Server 2007" }
                    22337 { Write-Host -ForegroundColor green "Exchange Server 2007 Service Pack 1" }
                    25843 { Write-Host -ForegroundColor green "Exchange Server 2007 Service Pack 2" }
                    25846 { Write-Host -ForegroundColor green "Exchange Server 2007 Service Pack 3" }
                    27261 { Write-Host -ForegroundColor green "Exchange Server 2010" }
                    27766 { Write-Host -ForegroundColor green "Exchange Server 2010 Service Pack 1" }
                    27772 { Write-Host -ForegroundColor green "Exchange Server 2010 Service Pack 2" }
                    27774 { Write-Host -ForegroundColor green "Exchange Server 2010 Service Pack 3" }
                    28373 { Write-Host -ForegroundColor green "Exchange Server 2013" }
                    28490 { Write-Host -ForegroundColor green "Exchange Server 2013 Cumulative Update 1" }
                    28517 { Write-Host -ForegroundColor green "Exchange Server 2013 Cumulative Update 2" }
                    28519 { Write-Host -ForegroundColor green "Exchange Server 2013 Cumulative Update 3" }
                    28528 { Write-Host -ForegroundColor green "Exchange Server 2013 Cumulative Update 4 - Service Pack 1" }
                    28536 { Write-Host -ForegroundColor green "Exchange Server 2013 Cumulative Update 5" }
                    28539 { Write-Host -ForegroundColor green "Exchange Server 2013 Cumulative Update 6" }
                    default {  Write-Host -ForegroundColor red "unknown - "$ExchangeSchemaVersion.rangeUpper }
                    
                }

            $ExchOrganization = (Get-ADObject -Server $forest -Identity "cn=Microsoft Exchange,cn=Services,$configPartition" -Properties templateRoots).templateRoots
            $ExchOrgName = (Get-ADObject -Server $forest -Identity $($ExchOrganization -Replace "cn=Addressing," , "") -Properties name).name

            Write-Host ""
            
            Write-Host "Microsoft Exchange Organization name"
            Write-Host -ForegroundColor Green $ExchOrgName

        } #end if
        
    else
    
        {
        
            Write-Host -ForegroundColor green "(not present)"
        
        }
        
    Write-Host ""
    # End of Exchange version



    # Determine and display Lync version
    Write-Host "Microsoft Lync server version"

    $LyncSchemaVersion = Get-ADObject -Server $forest -LDAPFilter "(&(objectClass=attributeSchema)(name=ms-RTC-SIP-SchemaVersion))" -SearchBase $SchemaPartition -Properties rangeUpper

    if ($LyncSchemaVersion -ne $nul)
    
        {
        
            switch ($LyncSchemaVersion.rangeUpper)
            
                {
                
                    1006 { Write-Host -ForegroundColor green "Live Communications Server 2005" }
                    1007 { Write-Host -ForegroundColor green "Office Communications Server 2007 Release 1" }
                    1008 { Write-Host -ForegroundColor green "Office Communications Server 2007 Release 2" }
                    1100 { Write-Host -ForegroundColor green "Lync Server 2010" }
                    1150 { Write-Host -ForegroundColor green "Lync Server 2013" }
                    default {  Write-Host -ForegroundColor red "unknown - "$LyncSchemaVersion.rangeUpper }
                
                }

        }# end if
        
    else
    
        {
        
            Write-Host -ForegroundColor green "(not present)"
        
        }
        
    Write-Host ""
    # End of Lync version



    # Determine and display FFL
    Write-Host "Forest Functional Level"
    
    switch ($ffl)
    
        {
        
            Windows2000Forest { Write-Host -ForegroundColor green "Windows 2000" }
            Windows2003Forest { Write-Host -ForegroundColor green "Windows Server 2003" }
            Windows2008Forest { Write-Host -ForegroundColor green "Windows Server 2008" }
            Windows2008R2Forest { Write-Host -ForegroundColor green "Windows Server 2008 R2" }
            Windows2012Forest { Write-Host -ForegroundColor green "Windows Server 2012" }
            Windows2012R2Forest { Write-Host -ForegroundColor green "Windows Server 2012 R2" }
            default { Write-Host -ForegroundColor red "Unknown Forest Functional Level:"$ffl }
        
        }
        
    Write-Host ""
    # End of FFL section



    # Forest tombstoneLifetime
    $tombstoneLifetime = (Get-ADobject -Server $forest -Identity "cn=Directory Service,cn=Windows NT,cn=Services,$configPartition" -Properties tombstoneLifetime).tombstoneLifetime
    
    Write-Host "Tombstone lifetime"
    
    if ($tombstoneLifetime -ne $nul)
    
        {
        
            Write-Host -ForegroundColor Green $tombstoneLifetime" day(s)"
        
        }
        
    else
    
        {
        
            Write-Host -ForegroundColor Green "60 days (default setting)"
        
        }
        
    Write-Host ""
    # End of forest tombstoneLifetime



    # AD Recycle Bin support
    
    Write-Host "Active Directory Recycle Bin"
    Write-Host -ForegroundColor green $ADRecBinSupport
    
    Write-Host ""
    
    # End of AD Recycle Bin section




    # List of all Domains in a Forest
    
    Write-Host "Domains in this forest"
    $allDomains | Sort | %{ Write-Host -ForegroundColor green $_ }
    
    Write-Host ""
    
    # End of list section




    # Trusts enumeration
    Write-Host "List of trusts"
    
    $ADTrusts = Get-ADObject -Server $forest -Filter { objectClass -eq "trustedDomain" } -Properties CanonicalName,trustDirection

    if ($ADTrusts.Count -gt 0)
    
        {
        
            foreach ($Trust in $ADTrusts)

                {

                    switch ($Trust.trustDirection)
                    
                        {
                        
                            3 { $trustInfo=($Trust.CanonicalName).Replace("/System/","  <===>  ") }
                            2 { $trustInfo=($Trust.CanonicalName).Replace("/System/","  <----  ") }
                            1 { $trustInfo=($Trust.CanonicalName).Replace("/System/","  ---->  ") }
                        
                        }


                    Write-Host -ForegroundColor green $trustInfo

                }

        }

    else
    
        {
        
            Write-Host -ForegroundColor green "(none)"
        
        }
        
    Write-Host ""
    # End of trusts list




    # List of all partitions in a forest
    $partitions = Get-ADObject -Server $forest -Filter * -SearchBase $ForestInfo.PartitionsContainer -SearchScope OneLevel -Properties name,nCName,msDS-NC-Replica-Locations | Select name,nCName,msDS-NC-Replica-Locations | Sort-Object name
    
    Write-Host "List of all partitions"
    
    Write-Host ""
    
    
    foreach ($part in $partitions)
        
        {
            
            Write-Host -BackgroundColor Yellow -ForegroundColor Black $part.name
            Write-Host -ForegroundColor Green $part.nCName
            
            Write-Host ""
            
            $DNSServers = $part."msDS-NC-Replica-Locations" | Sort-Object
            
                       
            # If any DNS server holds partition
            if ($DNSServers -ne $nul)
                
                {
                    
                    Write-Host -ForegroundColor Yellow "DNS servers"
                    
                    # Get DNS Servers for selected partition
                    foreach ($DNSServer in $DNSServers)
                    
                        {
                        
                            Write-Host ( ($DNSServer -Split ",")[1] -Replace "CN=","")
                            
                        }
                        
                     # End of DNS servers list for selected partition
                        
                }
             # End IF section for DNS servers
             
            
            Write-Host ""
            Write-Host ""
            
        }
    
    Write-Host ""
    # End of list of all partitions in a forest
    
    
    Write-Host "Sites and Subnets information"
    
    Write-Host ""



    # Sites enumeration
    $ConfigurationPart = ($ForestInfo.PartitionsContainer -Replace "CN=Partitions,","")
    $AllSites = Get-ADObject -Server $forest -Filter { objectClass -eq "site" } -SearchBase $ConfigurationPart -Properties *

    # Loop for Sites and Subnets
    foreach ( $Site in $AllSites )
        
        {
        
            Write-Host -ForegroundColor black -BackgroundColor yellow "Site:"$Site.Name
            Write-Host
            Write-Host -ForegroundColor yellow "Server(s) in site:"
            Write-Host

            $ServersInSite = Get-ADObject -Server $forest -Filter { objectClass -eq "server" } -SearchBase $Site.distinguishedName -SearchScope Subtree -Properties Name | Select Name | Sort-Object Name

            # Loop for Domain Controller details
            foreach ($Server in $ServersInSite)
            
                {

                    # If any DC is in Site
                    if ( $Server -ne $nul )
                    
                        {
                            
                            $dcDetails = Get-ADDomainController $Server.Name

                            $dcDN = $dcDetails.ComputerObjectDN -Replace $dcDetails.Name,""
                            $dcDN = $dcDN -Replace "CN=,",""

                            $dcFRS = "CN=Domain System Volume (SYSVOL share),CN=NTFRS Subscriptions,$($dcdetails.computerobjectdn)"
                            $dcDFSR = "CN=SYSVOL Subscription,CN=Domain System Volume,CN=DFSR-LocalSettings,$($dcdetails.computerobjectdn)"


                            $dcFRSinfo = Get-ADObject -Filter { distinguishedName -eq $dcFRS } -Properties fRSRootPath
                            $dcDFSRinfo = Get-ADObject -Filter { distinguishedName -eq $dcDFSR } -Properties msDFSR-RootPath, msDFSR-RootSizeInMb


                            
                            # Display Domain Controller details
                            Write-Host -ForegroundColor green "$($Server.Name) ($($dcDN))"
                            Write-Host "IP address (v4)    : "$dcDetails.ipv4address

                            # IPv6 address
                            if ($dcDetails.ipv6address -ne $nul)
                            
                                {
                                
                                    Write-Host "IP address (v6)    : "$dcDetails.ipv6address
                                
                                }
                                
                            else
                            
                                {
                                
                                    Write-Host "IP address (v6)    :  (none)"
                              
                                }
                            # End of IPv6 address section
                            
                            
                            
                            # Operating system type and its service pack level
                            Write-Host "OS type            : "$dcDetails.operatingSystem

                            if ($dcDetails.operatingSystemServicePack -ne $nul)
                            
                                {
                                
                                    Write-Host "Service Pack       : "$dcDetails.operatingSystemServicePack
                                
                                }
                            # End of operating system and service pack level section
                            

                            
                            # SYSVOL replication method on DC
                            # SYSVOL FRS section
                            if ($dcFRSinfo -ne $nul)
                            
                                {
                                
                                    Write-Host "SYSVOL replication :  FRS"
                                    Write-Host "SYSVOL location    : "$dcFRSinfo.fRSRootPath.toUpper()
                               
                                }
                            # End of SYSVOL FRS section


                            
                            # SYSVOL DFS-R section
                            if ($dcDFSRinfo -ne $nul)
                            
                                {
                                
                                    Write-Host "SYSVOL replication :  DFS-R"
                                    Write-Host "SYSVOL location    : "$dcDFSRinfo."msDFSR-RootPath".toUpper()


                                    # SYSVOL size
                                    if ($dcDFSRinfo."msDFSR-RootSizeInMb" -ne $nul)
                                    
                                        {
                                        
                                            Write-Host "SYSVOL quota       : "$dcDFSRinfo."msDFSR-RootSizeInMb"
                                        
                                        }
                                        
                                    else
                                    
                                        {
                                        
                                            Write-Host "SYSVOL quota       :  4GB (default setting)"
                                        
                                        }
                                    # End of SYSVOL size
                                    

                                }
                            # End of SYSVOL DFS-R section


                        }
                    # End of section where DC is in Site    
                    
                    
                    # If no DC in Site
                    else
    
                    {
                    
                        Write-Host -ForegroundColor green "(none)"
                    
                    }
                    # End of section where no DC in Site


                    Write-Host ""

                } # End of sub foreach for Domain Controllers details
                
                

        # List Subnets for selected Site
        $subnets = $Site.siteObjectBL

        Write-Host -ForegroundColor yellow "Subnets:"

        # If any Subnet assigned
        if ( $subnets -ne $nul )
                    
            {
            
                # List all Subnets for selected Site
                foreach ($subnet in $subnets)

                    {
                                
                        $SubnetSplit = $Subnet.Split(",")
                        Write-Host $SubnetSplit[0].Replace("CN=","")
                                
                    }
                # End of listing Subnets

            }
        # End of existing Subnets section
        
        
        # If no Subnets in Site
        else
                    
            {
                        
                Write-Host -ForegroundColor green "(none)"
                        
            }
        # End of no Subnets section
            
            
        
        # End of listing Subnets
       
        Write-Host ""
        Write-Host ""

        } # End of main foreach for Sites and Subnets
        
    # End of Sites section






    # Site Links enumeration

    Write-Host -ForegroundColor yellow -BackgroundColor black "Site link(s) information:"
    
    Write-Host ""

    $siteLinks = Get-ADObject -Server $forest -Filter { objectClass -eq "siteLink" } -SearchBase $ConfigurationPart -Properties name, cost, replInterval, siteList | Sort-Object replInterval

    foreach ($link in $siteLinks)
    
        {
        
            Write-Host "Site link name       : " -NoNewLine
            Write-Host -ForegroundColor green $link.name
            Write-Host "Replication cost     : " -NoNewLine
            Write-Host -ForegroundColor green $link.cost
            Write-Host "Replication interval : " -NoNewLine
            Write-Host -ForegroundColor green $link.replInterval" minutes"
            Write-Host "Sites included       : " -NoNewLine

            foreach ($linkList in $link.siteList)
            
                {
                
                    $siteName = Get-ADObject -Identity $linkList -Properties Name
                    Write-Host -ForegroundColor green $siteName.name"; " -NoNewLine
                
                }

            Write-Host ""
            Write-Host ""
            Write-Host ""

        }


    Write-Host ""
    # End of Site Links section




    # Get Global Catalogs in the forest
    
    Write-Host "Global Catalog servers in the forest"
    $ForestGC | Sort | %{ Write-Host -ForegroundColor green $_.toUpper() }
    
    Write-Host ""
    
    # End of Global Catalogs section






    # Display additional suffixes
    Write-Host "Additional UPN suffixes"
    
    if ( $UPNSuffix.Count -ne 0 )
    
        {
        
        $UPNsuffix | Sort | %{ Write-Host -ForegroundColor green $_ }
        
        }
        
    else

        {
        
            Write-Host -ForegroundColor green "(none)"
        
        }

    Write-Host ""
    Write-Host ""
    # End of suffixes section





    # Forest FSMO roles display
    Write-Host -ForegroundColor yellow -BackgroundColor black "FSMO roles details:"
    
    Write-Host ""
    
    Write-Host "Schema master"
    Write-Host -ForegroundColor green $FSMOSchema.toUpper()
    
    Write-Host ""
    
    Write-Host "Domain Naming master"
    Write-Host -ForegroundColor green $FSMODomainNaming.toUpper()

    Write-Host ""
    Write-Host ""
    # End of Forest FSMO section



    # Forest wide groups members
    Write-Host -ForegroundColor yellow -BackgroundColor black "Forest wide groups details:"
    
    Write-Host ""
    
    # Schema Administrators
    $schemaGroupID = ((Get-ADDomain(Get-ADForest).name).domainSID).value+"-518"
    $schemaAdminsNo = Get-ADGroup -Server $forest -Identity $schemaGroupID | Get-ADGroupMember -Recursive

    if ($schemaAdminsNo.Count -eq 2)
        {
        
            Write-Host "Total number of Schema Administrators     : " -NoNewLine
            Write-Host -ForegroundColor Green $schemaAdminsNo.Count
            
        }
        
     else
     
        {
        
            Write-Host "Total number of Schema Administrators     : " -NoNewLine
            Write-Host -ForegroundColor Red $schemaAdminsNo.Count
            
        }
        
        
    # Enterprise Admins
    $entGroupID = ((Get-ADDomain(Get-ADForest).name).domainSID).value+"-519"
    $enterpriseAdminsNo = Get-ADGroup -Server $forest -Identity $entGroupID | Get-ADGroupMember -Recursive

    if ($enterpriseAdminsNo.Count -eq 1)
        {
        
            Write-Host "Total number of Enterprise Administrators : " -NoNewLine
            Write-Host -ForegroundColor Green $enterpriseAdminsNo.Count
            
        }
        
     else
     
        {
        
            Write-Host "Total number of Enterprise Administrators : " -NoNewLine
            Write-Host -ForegroundColor Red $enterpriseAdminsNo.Count
            
        }
    
    
    Write-Host ""
    # End of forest wide groups members
    
    
    

    # Custom Get-DomainInfo function executed for every domain in the forest
    
    $allDomains | Sort | %{ Get-DomainInfo ($_) }
    
    # End of loop

    Write-Host ""
    Write-Host ""

    Write-Host -ForegroundColor white -BackgroundColor black "The end of Active Directory report"

    Write-Host ""
    Write-Host ""
    # End of data display
