$computers_all = Invoke-Command -ComputerName ad1 -ScriptBlock { (get-adcomputer -filter 'name -ne "CH1"').name }

$result = Invoke-Command -ComputerName $computers_all -ScriptBlock {
    $object = [PSCustomObject]@{`
        Computername = $env:COMPUTERNAME; `
        Time = get-date -Format o ;`
    }

    $object
}

$result |  Sort-Object -Property Time | Format-Table ComputerName, Time -AutoSize