$Name = "tyler loves to fart"
$Length = $name.Length
$space = " "

for ($i = 0; $i -le $length; $i++){

    if ($i -gt 1) {
        Write-Host "." -NoNewline
    }
    $Name.Substring(0,$i)
}

for ($i = $Length; $i--){
    $Name.Substring(0,$i)
}