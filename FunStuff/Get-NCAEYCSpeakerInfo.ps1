
$data = import-excel C:\temp\JKEXCEL.xlsx


$selectparams = 'Session','Session Title','Room','Applicable Age Group','Target Audience','Main Presenter First Name','Main Presenter Last Name','Main Presenter Employer','Co-Presenter First Name','Co-Presenter Last Name','CoP2 Employer','CoP2 FN','CoP2 LN','CoP3 FN','CoP3 LN','CoP3 Employer','Session Description'


$session1Data = $data |select $selectparams | Where-Object {$_.session -eq '1'}
$session2Data = $data |select $selectparams | Where-Object {$_.session -eq '2'}
$session3Data = $data |select $selectparams | Where-Object {$_.session -eq '3'}
$session4Data = $data |select $selectparams | Where-Object {$_.session -eq '4'}
$session5Data = $data |select $selectparams | Where-Object {$_.session -eq '5'}