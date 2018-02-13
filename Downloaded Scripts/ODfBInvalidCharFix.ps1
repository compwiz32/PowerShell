#requires -Version 3.0

<#PSScriptInfo

.VERSION 1.1.1

.GUID 4e03a473-eadb-41f9-ba78-0494dfb4d74e

.AUTHOR Michael Riston

.COMPANYNAME Riston.me

.COPYRIGHT © Michael Riston 2017

.TAGS 

.LICENSEURI 

.PROJECTURI 

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES


#> 





<# 

    .DESCRIPTION 
    Removes invalid charachters from a specified OneDrive for Business folder and creates a log for all changes made.

#> 

Param()


function Test-ODfBIllegalCharacters
{
  <#
      .SYNOPSIS
      Returns true/false if a string contains illegal characters.
      .DESCRIPTION
      Returns true/false if a string contains illegal characters.
      .EXAMPLE
      Test-ODfBIllegalCharacters -string 'sdofijs'
      False
      .EXAMPLE
      Test-ODfBIllegalCharacters -string '#%*:<>'
      True
  #>
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $false, Position = 0)]
    [System.String]
    $string = '@#%^'
  )
  
  $IllegalCharacterSearcher        = '`"' , '`#', '`%', '`*', '`:', '`<' , '`>' , '`?', '`/', '`\', '`|', '`~', '`&' , '`{', '`}'
  $IllegalCharacters               = '"', '#', '%', '*', ':', '<', '>' , '?', '/', '\', '|', '~' , '&', '{' , '}' 
  $IllegalCharactersReplacements   = "'", 'no', 'pct' , 'str_', '-', 'lt' , 'gt' , 'qst_', '_', '_', '-', '-' , 'and', '(' , ')' 
  $IllegalName = $false
  
  foreach ($i in $IllegalCharacters) 
  {
    $index = [array]::IndexOf($IllegalCharacters,$i)
    if ($string.Contains($i)) 
    {
      $IllegalName = $true
      break
    }
  }
  return $IllegalName
}

function Resolve-ODfBIllegalCharacters
{
  <#
      .SYNOPSIS
      Removes illegal characters from a string and returns a 'corrected' value [str].
      .DESCRIPTION
      Removes illegal characters from a string and returns a 'corrected' value [str].
      .EXAMPLE
      Resolve-ODfBIllegalCharacters -string 'bad_file#ame%!<<>'
      bad_filenoamepct!ltltgt
  #>
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true, Position = 0)]
    [System.String]
    $string
  )
  
  $IllegalCharacterSearcher        = '`"' , '`#', '`%', '`*', '`:', '`<' , '`>' , '`?', '`/', '`\', '`|', '`~', '`&' , '`{', '`}'
  $IllegalCharacters               = '"', '#', '%', '*', ':', '<', '>' , '?', '/', '\', '|', '~' , '&', '{' , '}' 
  $IllegalCharactersReplacements   = "'", 'no', 'pct' , 'str_', '-', 'lt' , 'gt' , 'qst_', '_', '_', '-', '-' , 'and', '(' , ')' 
  
  
  foreach ($i in $IllegalCharacters) 
  {
    $index = [array]::IndexOf($IllegalCharacters,$i)  
    $string = $string.Replace($i,$IllegalCharactersReplacements[$index])
  }
  
  return $string
}

function Repair-ODfBNamingIssues
{
  <#
      .SYNOPSIS
      Resolves all illegal characters under a specific path that prevent ODfB from synchronizing properly.
      .DESCRIPTION
      Resolves all illegal characters under a specific path that prevent ODfB from synchronizing properly. 
      Log file created in My Documents folder. Log file specifies type of item (Directory/File), Original Path name, and new name.
      .EXAMPLE
      Repair-ODfBNamingIssues -FolderPath c:\working
      Found Illegal Name: C:\working\f2lj#%35#$\2348^^%%\no$^#@^\#@&(){}
      C:\working\f2lj#%35#$\2348^^%%\no$^#@^\no@and()()
      Found Illegal Name: C:\working\f2lj#%35#$\2348^^%%\no$^#@^
      C:\working\f2lj#%35#$\2348^^%%\no$^no@^
      PS C:\tools\odfbtest> Repair-ODfBNamingIssues -FolderPath c:\working
      Found Illegal Name: C:\working\f2lj#%35#$\2348^^%%\no$^#@^\#@&(){}
      C:\working\f2lj#%35#$\2348^^%%\no$^#@^\no@and()()
      Found Illegal Name: C:\working\f2lj#%35#$\2348^^%%\no$^#@^
      C:\working\f2lj#%35#$\2348^^%%\no$^no@^
      PS C:\tools\odfbtest> Repair-ODfBNamingIssues -FolderPath c:\working
      Found Illegal Name: C:\working\f2lj#%35#$\2348^^%%\no$^#@^\#@&(){}
      C:\working\f2lj#%35#$\2348^^%%\no$^#@^\no@and()()
      Found Illegal Name: C:\working\f2lj#%35#$\2348^^%%\no$^#@^
      C:\working\f2lj#%35#$\2348^^%%\no$^no@^
      .EXAMPLE
      Repair-ODfBNamingIssues -FolderPath c:\working -TestRun
      TEST RUN INVOCATION - Will not move files
      TEST RUN INVOCATION - Will not move files
      TEST RUN INVOCATION - Will not move files
      TEST RUN INVOCATION - Will not move files
      TEST RUN INVOCATION - Will not move files
      Found Illegal Name: C:\working\f2ljnopct35#@%%$\2348^^pctpct\@#$@#$^%#$@#
      C:\working\f2ljnopct35#@%%$\2348^^pctpct\@no$@no$^pctno$@no
      Found Illegal Name: C:\working\f2ljnopct35#@%%$
      C:\working\f2ljnopct35no@pctpct$
      Found Illegal Name: C:\working\f2ljnopct35#@%%$\2348^^pctpct\2343$#@%#$%^324325#@$!#$@!32.txt
      C:\working\f2ljnopct35#@%%$\2348^^pctpct\2343$no@pctno$pct^324325no@$!no$@!32.txt
  #>
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true, Position = 0, HelpMessage = 'Enter the Path to the OneDrive for Business Folder you wish to check.')]
    [Object]
    $FolderPath,
    
    [Parameter(Mandatory = $false, Position = 1)]
    [Switch]
    $TestRun = $false
  )
  
  $AllFolders = Get-ChildItem $FolderPath -Recurse -Directory
  
  $log = Join-Path -Path ([Environment]::GetFolderPath('MyDocuments')) -ChildPath "ODfB_Renamer-Runtime-$(Get-Date -Format yyyy-MM-dd.HH.mm.ss).log"
  "Type`tOrigFullPath`tNewFileName" | Out-File -FilePath $log
  
  try 
  {
    CMTrace.exe $log
  }      #Open CM Trace to view live log
  catch 
  {

  }                    #Don't throw an error

  if ($TestRun) 
  {
    for ($ctr = 0; $ctr -lt 5; $ctr++) 
    {
      Write-Host -Object 'TEST RUN INVOCATION - Will not move files' -ForegroundColor Green -BackgroundColor Black
    }
  }

  foreach ($f in ($AllFolders | Sort-Object -Property FullName -Descending)) 
  { 
    #Process each folder name and confirm.
    #Do this -descending to get level n before level 0 (Prevents recursive mistakes)
    
    #Test that this folder has no illegal characters.
    if (Test-ODfBIllegalCharacters -string $f.BaseName) 
    {
      Write-Host -Object 'Found Illegal Name: ' -NoNewline
      Write-Host -Object "$($f.FullName)" -ForegroundColor Red
      Write-Host -Object "$($f.FullName.Replace(($f.BaseName),(Resolve-ODfBIllegalCharacters -string $f.BaseName)))" -ForegroundColor Cyan
      
      $newname = "$($f.FullName.Replace(($f.BaseName),(Resolve-ODfBIllegalCharacters -string $f.BaseName)))"
      if (!$TestRun) 
      {
        Move-Item -Path $f.FullName -Destination $newname -Force
      }
      "Directory`t$($f.FullName)`t$($newname)" | Out-File -FilePath $log -Append
    }
  }
  
  $AllFiles = Get-ChildItem $FolderPath -Recurse -File
  foreach ($f in ($AllFiles | Sort-Object -Property FullName -Descending)) 
  { 
    #Process each folder name and confirm.
    #Do this -descending to get level n before level 0 (Prevents recursive mistakes)
    
    #Test that this folder has no illegal characters.
    if (Test-ODfBIllegalCharacters -string $f.BaseName) 
    {
      Write-Host -Object 'Found Illegal Name: ' -NoNewline
      Write-Host -Object "$($f.FullName)" -ForegroundColor Red
      Write-Host -Object "$($f.FullName.Replace(($f.BaseName),(Resolve-ODfBIllegalCharacters -string $f.BaseName)))" -ForegroundColor Cyan
      
      $newname = "$($f.FullName.Replace(($f.BaseName),(Resolve-ODfBIllegalCharacters -string $f.BaseName)))"
      if (!$TestRun) 
      {
        Move-Item -Path $f.FullName -Destination $newname -Force
      }
      "File`t$($f.FullName)`t$($newname)" | Out-File -FilePath $log -Append
    }
  }
}

Write-Host -Object '-------------------------------------------------------------------------' -ForegroundColor Green
Write-Host -Object '-----------------' -ForegroundColor Green -NoNewline
Write-Host -Object 'OneDrive for Business Invalid Char tool' -ForegroundColor Red -NoNewline
Write-Host -Object '-----------------' -ForegroundColor Green 
Write-Host -Object '-------------------------------------------------------------------------' -ForegroundColor Green
Write-Host -Object 'Stopping Explorer.exe' -ForegroundColor Blue -BackgroundColor DarkGray
Get-Process -Name explorer | Stop-Process -Force -Verbose
Write-Host -Object 'Executing Script' -ForegroundColor Green -BackgroundColor Black
Repair-ODfBNamingIssues -FolderPath (Read-Host -Prompt 'Enter the path of the OneDrive for Business Folder.')
Write-Host -Object 'Starting Explorer.exe' -ForegroundColor Blue -BackgroundColor DarkGray
Start-Process -FilePath explorer.exe
