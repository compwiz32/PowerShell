


$PWDExpire = (get-aduser michael_kanakos -prop passwordlastset).passwordlastset
$PWDExpire


$PWDExpire.adddays(186)



function FunctionName (OptionalParameters) {
    
}

funct