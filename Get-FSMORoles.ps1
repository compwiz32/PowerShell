# Get-FSMO-Roles
# Mike Kanakos - 2016-02-04

# Assign .net connections to variables
$SchemaMaster = ([System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()).SchemaRoleOwner
$DomainNamingMaster = ([System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()).NamingRoleOwner
$InfraMaster = ([System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()).InfrastructureRoleOwner
$PDCEmulator = ([System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()).PdcRoleOwner
$RIDMaster = ([System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()).RidRoleOwner


# Create an array to store SchemaMaster values
$DisplayObj = New-Object psobject
$DisplayObj | Add-Member -type NoteProperty -Name 'Role' -Value 'Schema Master'
$DisplayObj | Add-Member -type NoteProperty -Name 'Name' -Value $SchemaMaster.Name 
$DisplayObj | Add-Member -type NoteProperty -Name 'IP Address' -Value $SchemaMaster.IPAddress
$DisplayObj | Add-Member -type NoteProperty -Name 'Site' -Value $SchemaMaster.SiteName 

# Create an array to store PDC Emulator values
$DisplayObj2 = New-Object psobject
$DisplayObj2 | Add-Member -type NoteProperty -Name 'Role' -Value 'PDC Emulator'
$DisplayObj2 | Add-Member -type NoteProperty -Name 'Name' -Value $PDCEmulator.Name 
$DisplayObj2 | Add-Member -type NoteProperty -Name 'IP Address' -Value $PDCEmulator.IPAddress
$DisplayObj2 | Add-Member -type NoteProperty -Name 'Site' -Value $PDCEmulator.SiteName 

# Create an array to store Domain Naming Master values
$DisplayObj3 = New-Object psobject
$DisplayObj3 | Add-Member -type NoteProperty -Name 'Role' -Value 'Domain Naming Master'
$DisplayObj3 | Add-Member -type NoteProperty -Name 'Name' -Value $DomainNamingMaster.Name 
$DisplayObj3 | Add-Member -type NoteProperty -Name 'IP Address' -Value $DomainNamingMaster.IPAddress
$DisplayObj3 | Add-Member -type NoteProperty -Name 'Site' -Value $DomainNamingMaster.SiteName

# Create an array to store Infrastructure Master values
$DisplayObj4 = New-Object psobject
$DisplayObj4 | Add-Member -type NoteProperty -Name 'Role' -Value 'Infrastructure Master'
$DisplayObj4 | Add-Member -type NoteProperty -Name 'Name' -Value $InfraMaster.Name 
$DisplayObj4 | Add-Member -type NoteProperty -Name 'IP Address' -Value $InfraMaster.IPAddress
$DisplayObj4 | Add-Member -type NoteProperty -Name 'Site' -Value $InfraMaster.SiteName

# Create an array to store RID Master values
$DisplayObj5 = New-Object psobject
$DisplayObj5 | Add-Member -type NoteProperty -Name 'Role' -Value 'RID Master'
$DisplayObj5 | Add-Member -type NoteProperty -Name 'Name' -Value $RIDMaster.Name 
$DisplayObj5 | Add-Member -type NoteProperty -Name 'IP Address' -Value $RIDMaster.IPAddress
$DisplayObj5 | Add-Member -type NoteProperty -Name 'Site' -Value $RIDMaster.SiteName

# Create another array to store the all the previous arrays in one large array
$Array = @()
$Array += $DisplayObj, $DisplayObj2, $DisplayObj3, $DisplayObj4, $DisplayObj5


#Display results
$Array
