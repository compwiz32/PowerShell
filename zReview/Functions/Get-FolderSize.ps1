function Get-FolderSize
{
  # Usage: Get-FolderLength.ps1 D:\Homedirs
  param ( [Parameter(Mandatory=$true)] [String]$Path )
  $FileSystemObject = New-Object -com  Scripting.FileSystemObject
  $folders = (Get-Childitem $path | ? {$_.Attributes -eq "Directory"})
  foreach ($folder in $folders)
  {
    $folder | Add-Member -MemberType NoteProperty -Name "SizeMB" –Value(($FileSystemObject.GetFolder($folder.FullName).Size) / 1MB)
  }
  $folders | sort -Property SizeMB -Descending | select fullname,@{n=’Size MB’;e={"{0:N2}" –f $_.SizeMB}}
}