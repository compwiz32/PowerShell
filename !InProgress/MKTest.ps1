$Age = @{
    Mike   = 52
    Phil   = 48
    Kevin  = 35
    Lars   = 42
    Jeremy = 36
}

$age

$splat = @{

}

$feet = Read-Host "Enter feet"
>> $meters = $feet * 0.3048
>> Write-Host "$feet feet is equal to $meters meters"


Get-Process @Splat

function FunctionName {
<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER name
Parameter description

.PARAMETER date
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>

    [CmdletBinding()]
    param (
        [string]$name,

        [datetime]$date

        [OutputType]

    )
}

function Verb-Noun {
    [CmdletBinding()]
    param (

    )

    begin {

    }

    process {

    }

    end {

    }
}
