Write-Output "Servers not in a patch group:"

$servers = get-adcomputer -filter 'OperatingSystem -like "*server*"' -prop operatingsystem, managedby, description, memberof |
    ForEach-Object {

    if (-not($_.memberof -match "Patch-Non_Prod_Group01" -or `
                $_.memberof -match "Patch-Non_Prod_Group02" -or `
                $_.memberof -match "Patch-Prod_Group01" -or `
                $_.memberof -match "Patch-Prod_Group02" -or `
                $_.memberof -match "Patch-Prod_Group03" -or `
                $_.memberof -match "Patch-Prod_Crit_Group01" -or `
                $_.memberof -match "Patch-Prod_Crit_Group02"))


    {
        Write-Output $_.name
    }
}

$servers | sort name