Function Get-FSMORoles
{
 <#
    .SYNOPSIS
       Displays where the FSMO roles are assigned for the current AD domain and AD Forest

    .DESCRIPTION
        Displays where the FSMO roles are assigned for the current AD domain and AD Forest

    .EXAMPLE
        Get-FSMORoles

        Displays where the FSMO roles are assigned for the current AD domain and AD Forest

        PS C:\Scripts\Git-Repo\powershell> Get-FSMORoles

        Role                  Name                   IP Address   Site
        ----                  ----                   ----------   ----
        Schema Master         DC.NWTRADERS.LOCAL     10.10.20.20  USA-NY
        PDC Emulator          DC.NWTRADERS.LOCAL     10.10.20.20  USA-NY
        Domain Naming Master  DC.NWTRADERS.LOCAL     10.10.20.20  USA-NY
        Infrastructure Master DC.NWTRADERS.LOCAL     10.10.20.20  USA-NY
        RID Master            DC.NWTRADERS.LOCAL     10.10.20.20  USA-NY


    .NOTES
        Name       : Get-FSMORoles.ps1
        Author     : Mike Kanakos
        Version    : 1.0.3
        DateCreated: 2016-02-04
        DateUpdated: 2019-01-15
        Credit     : found code online and cobbled together - unknwon source

    .LINK
    https://github.com/compwiz32/PowerShell
#>

    param ()

    $SchemaMaster = ([System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()).SchemaRoleOwner
    $DomainNamingMaster = ([System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()).NamingRoleOwner
    $InfraMaster = ([System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()).InfrastructureRoleOwner
    $PDCEmulator = ([System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()).PdcRoleOwner
    $RIDMaster = ([System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()).RidRoleOwner


    # Create an array to store SchemaMaster values
    $DisplayObjSchema = New-Object psobject
    $DisplayObjSchema | Add-Member -type NoteProperty -Name 'Role' -Value 'Schema Master'
    $DisplayObjSchema | Add-Member -type NoteProperty -Name 'Name' -Value $SchemaMaster.Name
    $DisplayObjSchema | Add-Member -type NoteProperty -Name 'IP Address' -Value $SchemaMaster.IPAddress
    $DisplayObjSchema | Add-Member -type NoteProperty -Name 'Site' -Value $SchemaMaster.SiteName

    # Create an array to store PDC Emulator values
    $DisplayObjPDC = New-Object psobject
    $DisplayObjPDC | Add-Member -type NoteProperty -Name 'Role' -Value 'PDC Emulator'
    $DisplayObjPDC | Add-Member -type NoteProperty -Name 'Name' -Value $PDCEmulator.Name
    $DisplayObjPDC | Add-Member -type NoteProperty -Name 'IP Address' -Value $PDCEmulator.IPAddress
    $DisplayObjPDC | Add-Member -type NoteProperty -Name 'Site' -Value $PDCEmulator.SiteName

    # Create an array to store Domain Naming Master values
    $DisplayObjDomNaming = New-Object psobject
    $DisplayObjDomNaming | Add-Member -type NoteProperty -Name 'Role' -Value 'Domain Naming Master'
    $DisplayObjDomNaming | Add-Member -type NoteProperty -Name 'Name' -Value $DomainNamingMaster.Name
    $DisplayObjDomNaming | Add-Member -type NoteProperty -Name 'IP Address' -Value $DomainNamingMaster.IPAddress
    $DisplayObjDomNaming | Add-Member -type NoteProperty -Name 'Site' -Value $DomainNamingMaster.SiteName

    # Create an array to store Infrastructure Master values
    $DisplayObjINFRA = New-Object psobject
    $DisplayObjINFRA | Add-Member -type NoteProperty -Name 'Role' -Value 'Infrastructure Master'
    $DisplayObjINFRA | Add-Member -type NoteProperty -Name 'Name' -Value $InfraMaster.Name
    $DisplayObjINFRA | Add-Member -type NoteProperty -Name 'IP Address' -Value $InfraMaster.IPAddress
    $DisplayObjINFRA | Add-Member -type NoteProperty -Name 'Site' -Value $InfraMaster.SiteName

    # Create an array to store RID Master values
    $DisplayObjRID = New-Object psobject
    $DisplayObjRID | Add-Member -type NoteProperty -Name 'Role' -Value 'RID Master'
    $DisplayObjRID | Add-Member -type NoteProperty -Name 'Name' -Value $RIDMaster.Name
    $DisplayObjRID | Add-Member -type NoteProperty -Name 'IP Address' -Value $RIDMaster.IPAddress
    $DisplayObjRID | Add-Member -type NoteProperty -Name 'Site' -Value $RIDMaster.SiteName

    # Create another array to store the all the previous arrays in one large array
    $Array = @()
    $Array += $DisplayObjSchema, $DisplayObjPDC, $DisplayObjDomNaming, $DisplayObjINFRA, $DisplayObjRID


    #Display results
    $Array

}

