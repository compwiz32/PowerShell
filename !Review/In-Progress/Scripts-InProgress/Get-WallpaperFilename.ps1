$strcomputer = "CRDNAB-G884Q12"
$w = get-wmiobject Win32_Desktop -ComputerName  $strcomputer
$w.Wallpaper

