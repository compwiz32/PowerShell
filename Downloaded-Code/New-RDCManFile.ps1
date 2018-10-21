########################################################################### 
# 
# NAME: New-RDCManFile.ps1 
# 
# AUTHOR: Markus Lassfolk 
# EMAIL: markus.lassfolk@truesec.se 
#
# Original AUTHOR: Jan Egil Ring 
# EMAIL: jer@powershell.no 
# 
# COMMENT: Script to create an XML-file for use with Microsoft Remote Desktop Connection Manager 
#          For more details, see the following blog-post: http://blog.powershell.no/2010/06/02/dynamic-remote-desktop-connection-manager-connection-list 
# 
# You have a royalty-free right to use, modify, reproduce, and 
# distribute this script file in any way you find useful, provided that 
# you agree that the creator, owner above has no warranty, obligations, 
# or liability for such use. 
# 
# VERSION HISTORY: 
# 2.1 19/08/2015 - Creating a Default Profile based on your UserName and Domain 
#                - Assume RDGW Address is  rdgw.your.domain.fqdn  if incorrect, set it manually. 
#
# 2.0 15/07/2015 - Updated for RDCMan 2.7 
#                - Only including ComputerObjects (no ClusterNames etc) 
#                - Only including Enabled Computer objects 
#                - Adds Computer Description as Comment
#                - Not using a Group. Felt no need for that as there is just one environment in each RDG File 
#                - Support for Providing a RDGateway Address 
#                - Changed file name to reflect FQDN of Domain (we have several customers with the same Netbios name) 
#                - Sort servers alphabetically in the list. 
#                
# 1.0 02.06.2010 - Initial release 
# 
########################################################################### 
 
#Importing Microsoft`s PowerShell-module for administering Active Directory 
Import-Module ActiveDirectory 
 
#Initial variables 
$EnableRDGW = $true                  # set to: $false if RDGW should not be used 
$RDGW = "rdgw.$env:USERDNSDOMAIN"    # Enter External RDGW Address if this is incorrect. 


$domain = $env:userdomain 
$OutputFile = "$home\$env:USERDNSDOMAIN.rdg" 

 
#Create a template XML 
$template = @' 
<?xml version="1.0" encoding="utf-8"?> 
<RDCMan schemaVersion="1"> 
    <version>2.2</version> 
    <file> 
    <credentialsProfiles>
      <credentialsProfile inherit="None">
        <profileName scope="Local">NAME</profileName>
        <userName>USERNAME</userName>
        <password></password>
        <domain>DOMAIN</domain>
      </credentialsProfile>
    </credentialsProfiles>
    <properties>
      <expanded>True</expanded>
      <name></name>
    </properties>
    <logonCredentials inherit="None">
    <profileName scope="File">None</profileName>
    </logonCredentials>
    <gatewaySettings inherit="None">
      <enabled>False</enabled>
      <hostName></hostName>
      <logonMethod>NTLM</logonMethod>
      <localBypass>False</localBypass>
      <credSharing>True</credSharing>
      <profileName scope="File">None</profileName>
    </gatewaySettings>
    <remoteDesktop inherit="None">
      <sameSizeAsClientArea>True</sameSizeAsClientArea>
      <fullScreen>False</fullScreen>
      <colorDepth>24</colorDepth>
    </remoteDesktop>
    <localResources inherit="None">
      <audioRedirection>Client</audioRedirection>
      <audioRedirectionQuality>Dynamic</audioRedirectionQuality>
      <audioCaptureRedirection>DoNotRecord</audioCaptureRedirection>
      <keyboardHook>FullScreenClient</keyboardHook>
      <redirectClipboard>True</redirectClipboard>
      <redirectDrives>False</redirectDrives>
      <redirectDrivesList />
      <redirectPrinters>False</redirectPrinters>
      <redirectPorts>False</redirectPorts>
      <redirectSmartCards>False</redirectSmartCards>
      <redirectPnpDevices>False</redirectPnpDevices>
    </localResources>
    <securitySettings inherit="None">
      <authentication>None</authentication>
    </securitySettings>
    <encryptionSettings inherit="FromParent">
    </encryptionSettings>
        <server> 
             <displayName></displayName> 
             <name></name> 
             <comment /> 
             <logonCredentials inherit="FromParent" /> 
             <connectionSettings inherit="FromParent" /> 
             <gatewaySettings inherit="FromParent" /> 
             <remoteDesktop inherit="FromParent" /> 
             <localResources inherit="FromParent" /> 
             <securitySettings inherit="FromParent" /> 
             <displaySettings inherit="FromParent" /> 
            </server> 
    </file> 
</RDCMan> 
'@ 
 
#Output template to xml-file 
$template | Out-File $home\RDCMan-template.xml -encoding UTF8 
 
#Load template into XML object 
$xml = New-Object xml 
$xml.Load("$home\RDCMan-template.xml") 
 
#Set file properties 
$file = (@($xml.RDCMan.file.properties)[0]).Clone() 
$file.name = "$env:USERDNSDOMAIN" 
$xml.RDCMan.file.properties | Where-Object { $_.Name -eq "" } | ForEach-Object  { [void]$xml.RDCMan.file.ReplaceChild($file,$_) } 

# Set RDGW Server Address 

if ($EnableRDGW -eq $true) {
    $xml.RDCMan.file.gatewaySettings.hostName = $RDGW
    $xml.RDCMan.file.gatewaySettings.enabled = "True"
    }

# Create a Profile with your current username and domain 
$xml.RDCMan.file.credentialsProfiles.credentialsProfile.profileName.'#text' = "$env:USERDOMAIN\$env:USERNAME"
$xml.RDCMan.file.credentialsProfiles.credentialsProfile.userName = "$env:USERNAME"
$xml.RDCMan.file.credentialsProfiles.credentialsProfile.domain = "$env:USERDOMAIN"
$xml.RDCMan.file.logonCredentials.profileName.'#text' = "$env:USERDOMAIN\$env:USERNAME"
$xml.RDCMan.file.gatewaySettings.profileName.'#text' = "$env:USERDOMAIN\$env:USERNAME"




#Use template to add servers from Active Directory to xml  
$server = (@($xml.RDCMan.file.server)[0]).Clone() 
get-adcomputer -LDAPFilter "(&(objectCategory=computer)(operatingSystem=Windows Server*)(!serviceprincipalname=*MSClusterVirtualServer*)(!(userAccountControl:1.2.840.113556.1.4.803:=2)))" -Property name,dnshostname,description | sort-object Name | select name,dnshostname,description | 
ForEach-Object { 
$server = $server.clone()     
$server.DisplayName = $_.Name     
$server.Name = $_.DNSHostName 
if ($_.Description -ne $Null) { 
    $server.comment = $_.Description 
    } 
else { 
  $server.comment = "" 
  } 

$xml.RDCMan.file.AppendChild($server) > $null} 
#Remove template server 
$xml.RDCMan.file.server | Where-Object { $_.Name -eq "" } | ForEach-Object  { [void]$xml.RDCMan.file.RemoveChild($_) } 


#Save xml to file 
$xml.Save($OutputFile) 
 
#Remove template xml-file 
Remove-Item $home\RDCMan-template.xml -Force

Write-Output "$OutputFile Created" 
