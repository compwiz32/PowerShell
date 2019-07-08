<#
.SYNOPSIS
Get weather data from the specified zipcode.
.DESCRIPTION
Get weather data releated to the current conditions, forecast, and hourly conditions from the specified zipcode. Weather data is retrieved from the National Weather Service.
.PARAMETER ZipCode
The zipcode for the location to grab weather data from.
.PARAMETER Current
Get the current conditions.
.PARAMETER Forecast
Get the weekly forecast.
.PARAMETER Hourly
Get the next twelve hours of hourly conditions.
.EXAMPLE
Get-Weather -ZipCode 36602 -Current
.EXAMPLE
Get-Weather -ZipCode 36602 -Hourly
.NOTES
If too many switches are provided, the first switch provided will be the only one to return data.
#>
function Get-Weather {

    [cmdletbinding()]

    param(
        [string]$ZipCode,
        [switch]$Current,
        [switch]$Forecast,
        [switch]$Hourly
    )

    #Grabs JSON data from OpenStreetMap to get location data.
    function osmLocation {
        param (
            [string]$zip
        )
        
        $apiCall = Invoke-RestMethod -Uri "https://nominatim.openstreetmap.org/search?format=jsonv2&namedetails=1&postalcode=$($zip)&countrycodes=US" | Select-Object -First 1

        return $apiCall
    }

    #Grabs data from the National Weather Service relative to the Lat/Lon of the zipcode provided.
    function nwsPointData {
        param(
            [string]$Latitude,
            [string]$Longitude
        )

        $apiCall = Invoke-RestMethod -Uri "http://api.weather.gov/points/$($Latitude),$($Longitude)"

        return $apiCall
    }

    #This is a general API caller. Returns the JSON.
    function runAPICall {
        param(
            [string]$apiUri
        )

        $apiCall = Invoke-RestMethod -Uri $apiUri

        return $apiCall
    }

    function getRainChance {

        param(
            [string]$iconurl
        )

        $regexIcons = ($iconurl | Select-String 'https:\/\/api\.weather\.gov\/icons\/.*?\/(?:day|night)\/(?:(?<condition1>.*)\/(?<condition2>.*?)|(?<condition>.*))(?=\?size=.*)')

        #$regexIcons.Matches.Groups
        if ((($regexIcons.Matches.Groups | Where-Object -Property "Name" -eq "condition1").Value) -and (($regexIcons.Matches.Groups | Where-Object -Property "Name" -eq "condition2").Value)) {

            $conditionOne = (($regexIcons.Matches.Groups | Where-Object -Property "Name" -eq "condition1").Value | Select-String -Pattern "(?:.*?,)(?<chance>.*)").Matches.Groups | Where-Object -Property "Name" -eq "chance" | Select-Object -ExpandProperty "Value"
            $conditionTwo = (($regexIcons.Matches.Groups | Where-Object -Property "Name" -eq "condition2").Value | Select-String -Pattern "(?:.*?,)(?<chance>.*)").Matches.Groups | Where-Object -Property "Name" -eq "chance" | Select-Object -ExpandProperty "Value"

            if (!$conditionOne) {
                $conditionOne = 0
            }
            if (!$conditionTwo) {
                $conditionTwo = 0
            }

            $percentChance = "$($conditionOne)% -> $($conditionTwo)%"
        }
        elseif (($regexIcons.Matches.Groups | Where-Object -Property "Name" -eq "condition").Value) {
            $condition = ($regexIcons.Matches.Groups | Select-String -Pattern "(?:.*?,)(?<chance>.*)" | Where-Object -Property "Name" -eq "chance")
            if ($condition) {
                $percentChance = $condition.Value.ToString() + "%"
            }
            else {
                $percentChance = "0%"
            }
        }
        else {
            $percentChance = "0%"
        }

        return $percentChance
    }

    #Grabs the current conditions from the first observation station.
    function getCurrentConditions {
        param (
            [string]$apiUri
        )
        $obsvstationsData = runAPICall -apiUri $apiUri
        $observations = runAPICall -apiUri "$($obsvstationsData.observationStations | Select-Object -First 1)/observations"


        foreach ($observation in $observations.features) {
            $currentConditions = New-Object -TypeName pscustomobject

            <#
            Running a check for if the temperature property has a qc:Z value for quality control.
            
            Unfortunately the NWS API does not update current conditions as quickly as they should be and we have to run through each update period for a qc:V value. 
            If we don't do this, then most values will return null.
            The biggest issue we can get from this, is the fact that current conditions are far behind on time.
            Even if ignore the quality control values, the current conditions are unreliable and outdated.
            Hopefully NWS will fix this eventually.
            #>
            if (!($observation.properties.temperature.qualityControl -eq "qc:Z")) {
    
                $percentChange = New-Object System.Globalization.CultureInfo -ArgumentList "en-us", $false
                $percentChange.NumberFormat.PercentDecimalDigits = 2

                Add-Member -InputObject $currentConditions -MemberType NoteProperty -Name "Condition" -Value $observation.properties.textDescription
                Add-Member -InputObject $currentConditions -MemberType NoteProperty -Name "Temperature (F)" -Value ((($observation.properties.temperature.value) * 1.8) + 32)
                Add-Member -InputObject $currentConditions -MemberType NoteProperty -Name "Dew Point" -Value (([Math]::Round($observation.properties.dewpoint.value, 2) / 100 )).ToString("P", $percentChange)
                Add-Member -InputObject $currentConditions -MemberType NoteProperty -Name "Humidity" -Value (([Math]::Round($observation.properties.relativeHumidity.value, 2) / 100 )).ToString("P", $percentChange)
                Add-Member -InputObject $currentConditions -MemberType NoteProperty -Name "Wind Speed" -Value $observation.properties.windSpeed.value
                Add-Member -InputObject $currentConditions -MemberType NoteProperty -Name "Timestamp" -Value $observation.properties.timestamp
                Add-Member -InputObject $currentConditions -MemberType ScriptMethod -Name "ConvertTempToCelcius" -Value {
                    return (($this.'Temperature (F)' - 32) * .5556)
                }
                Add-Member -InputObject $currentConditions -MemberType ScriptMethod -Name "ConvertDewPointToDouble" -Value {
                    return [double]::Parse($this.'Dew Point'.TrimEnd("%")) 
                }
                Add-Member -InputObject $currentConditions -MemberType ScriptMethod -Name "ConvertHumidityToDouble" -Value {
                    return [double]::Parse($this.Humidity.TrimEnd("%")) 
                }
            
                return $currentConditions
            }
        }
    }

    #Grabs the forecast data from the NWS API.
    function getForecast {
        param (
            [string]$apiUri
        )

        $forecastData = runAPICall -apiUri $apiUri

        foreach ($period in $forecastData.properties.periods) {
            $forecastPeriod = New-Object -TypeName pscustomobject

            $percentChance = getRainChance -iconurl $period.icon

            Add-Member -InputObject $forecastPeriod -MemberType NoteProperty -Name "Day" -Value $period.name
            Add-Member -InputObject $forecastPeriod -MemberType NoteProperty -Name "Temperature (F)" -Value $period.temperature
            Add-Member -InputObject $forecastPeriod -MemberType NoteProperty -Name "Short Forecast" -Value $period.shortForecast
            Add-Member -InputObject $forecastPeriod -MemberType NoteProperty -Name "Chance of Rain" -Value $percentChance

            $forecastPeriod

        }
    }

    #Grabs the hourly data from the NWS API.
    function getHourly {
        param (
            [string]$apiUri
        )

        $hourlyData = runAPICall -apiUri $apiUri

        foreach ($period in ($hourlyData.properties.periods | Select-Object -First 12)) {
            $hourlyPeriod = New-Object -TypeName pscustomobject

            $percentChance = getRainChance -iconurl $period.icon

            Add-Member -InputObject $hourlyPeriod -MemberType NoteProperty -Name "Hour" -Value $period.startTime
            Add-Member -InputObject $hourlyPeriod -MemberType NoteProperty -Name "Temperature (F)" -Value $period.temperature
            Add-Member -InputObject $hourlyPeriod -MemberType NoteProperty -Name "Short Forecast" -Value $period.shortForecast
            Add-Member -InputObject $hourlyPeriod -MemberType NoteProperty -Name "Chance of Rain" -Value $percentChance

            $hourlyPeriod

        }
    }

    <#
    
    Most of the script is split into multiple functions within this cmdlet. 
    It allows a modularized approach to running each command.
    
    #>
    $osmData = osmLocation -zip $ZipCode #Get location data from the specified location.

    $nwsPoint = nwsPointData -Latitude $osmData.lat -Longitude $osmData.lon #Get the NWS point data from the Lat/Lon retrieved in the $osmData variable.

    <#
    
    Even though we're grabbing one portion of the data from the user provided switch, we're grabbing all of the API urls returned in the point data.
    This doesn't extend the time it takes for the script to run.
    #>
    $nwsAPIs = New-Object -TypeName pscustomobject
    Add-Member -InputObject $nwsAPIs -MemberType NoteProperty -Name "Stations" -Value $nwsPoint.properties.observationStations
    Add-Member -InputObject $nwsAPIs -MemberType NoteProperty -Name "Forecast" -Value $nwsPoint.properties.forecast
    Add-Member -InputObject $nwsAPIs -MemberType NoteProperty -Name "Hourly" -Value $nwsPoint.properties.forecastHourly
    Add-Member -InputObject $nwsAPIs -MemberType NoteProperty -Name "Local Office" -Value $nwsPoint.properties.forecastOffice

    <#
    
    Running through the switches provided by the user.
    Only one switch can be ran at any given time.
    If more than one switch is provided, then it runs the first provided switch.
    #>
    switch ($PSBoundParameters.GetEnumerator() | Where-Object -Property "Value" -eq $true | Select-Object -ExpandProperty "Key") {
        default {
            getCurrentConditions -apiUri $nwsAPIs.Stations
            break
        }
        "Current" {
            getCurrentConditions -apiUri $nwsAPIs.Stations
            break
        }
        "Forecast" {
            getForecast -apiUri $nwsAPIs.Forecast
            break
        }
        "Hourly" {
            getHourly -apiUri $nwsAPIs.Hourly
            break
        }

    }

}