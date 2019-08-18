
#import info from spreadsheet
$data = import-excel C:\temp\JKEXCEL.xlsx
$output = @()


#select fields from sheet that jen asked for
$selectparams = 'Session','Session Title','Room','Applicable Age Group','Target Audience','Main Presenter First Name' `
,'Main Presenter Last Name','Main Presenter Employer','Co-Presenter First Name','Co-Presenter Last Name' `
,'Co-Presenter Employer','CoP2 Employer','CoP2 FN','CoP2 LN','CoP3 FN','CoP3 LN','CoP3 Employer','Session Description'

# $results = $data | Select-Object $selectparams | Where-Object {$_.session -eq '1'}

$results = $data | Select-Object $selectparams

Foreach ($record in $results){
    $Properties = [ordered]@{
        Session = [int]$Record.Session
        SessionTitle = $Record."Session Title"
        RoomNumber = [string]$Record.Room
        ApplicableAgeGroup = $Record."Applicable Age Group"
        TargetAudience = $Record."Target Audience"
        MainPresenterName = $Record."Main Presenter First Name" + "_" + $Record."Main Presenter Last Name"
        MainPresenterEmployer = $Record."Main Presenter Employer"
        CoPresenterName = $Record."Co-Presenter First Name" + "_" + $Record."Co-Presenter Last Name"
        CoPresenterEmployer = $Record."Co-Presenter Employer"
        CoPresenter2Name = $Record."CoP2 FN" + "_" + $Record."CoP2 LN"
        CoPresenter2Employer = $Record."CoP2 Employer"
        CoPresenter3Name = $Record."CoP3 FN" + "_" + $Record."CoP3 LN"
        CoPresenter3Employer = $Record."CoP3 Employer"
        SessionDescription = $Record."Session Description"
    }

    $obj = New-Object -TypeName psobject  -Property $Properties
    $output += $obj

}

$output

# $session1Data = $data |select $selectparams | Where-Object {$_.session -eq '1'}
# $session2Data = $data |select $selectparams | Where-Object {$_.session -eq '2'}
# $session3Data = $data |select $selectparams | Where-Object {$_.session -eq '3'}
# $session4Data = $data |select $selectparams | Where-Object {$_.session -eq '4'}
# $session5Data = $data |select $selectparams | Where-Object {$_.session -eq '5'}