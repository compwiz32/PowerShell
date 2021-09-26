$first = "Tyler "
$middle = "Joseph "
$last = "Kanakos "

for ($i = 1; $i -lt 100; $i++) {
    write-host $first -BackgroundColor Red -ForegroundColor white -NoNewline
    write-host $middle -BackgroundColor White -ForegroundColor Red -NoNewline
    write-host $last -BackgroundColor Blue -ForegroundColor Yellow
}

$number = 28

for ($i = 0; $i -lt 2001; $i++) {
    $number
    $number = $number + 3764
    pause
}




