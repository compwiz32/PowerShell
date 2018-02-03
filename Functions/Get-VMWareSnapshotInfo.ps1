function Get-VMWareSnapshotInfo {

    <#
  .Synopsis
  Returns a list of snapshots in place in VmWare vCenter.

  .Description
  Returns a list of snapshots in place in VMWare vSphere environment. You need to make a connection to the vSphere environment
  before you can run this cmdlet.

  .Example
  Get-VMWareSnapshotInfo
  Displays all snapshots in place on all VM's

  .Example
  Get-VMWareSnapshotInfo | format-table
  Displays all snapshots in place on all VM's in a table format

  .Example
  Get-VMWareSnapshotInfo | out-gridview
  Displays all snapshots in place on all VM's in a .net table in a seperate window that is searchable

  .Example
  Get-VMWareSnapshotInfo | export-csv c:\temp\snapshots.csv -NoTypeInformation
  Dumps snapshot report to a CSV file for importing into Excel. The NoTypoInforamtion parameter removes an annoying first line
  that is created when exporting that is not useful or needed.

  .Example
  Get-VMWareSnapshotInfo | Where-Object {$_.name -notlike 'NBU_SNAP*' } | format-table
  Displays all snapshots in place on all VM's in a table format but filters out any snapshots created by NetBackup

    .Notes
  NAME: Get-VMWareSnapshotInfo
  AUTHOR: Mike Kanakos
  LASTEDIT: 2018-01-12
  .Link

#>


    [CmdletBinding()]
    Param ()

    Get-VM -PipelineVariable vm | Get-Snapshot -PipelineVariable snap | Select-Object @{N = 'VM'; E = {$vm.Name}}, Name, Description, SizeMB, Created, `
    @{N = 'VMSN'; E = {($vm.ExtensionData.Layout.Snapshot | Where-Object {$_.Key -eq $snap.ExtensionData.Snapshot}).SnapShotFile `
                | Where-Object {$_ -match ".vmsn$"}}
    }

} #END OF FUNCTION