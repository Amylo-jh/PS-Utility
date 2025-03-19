$computers_all = invoke-command -ComputerName ad1 -ScriptBlock { (get-adcomputer -filter 'name -ne "CH1"').name }

Invoke-Command -ComputerName $computers_all -ScriptBlock {
    (Get-Date) - (Get-CimInstance win32_operatingSystem).LastBootUpTime
} | select -property PSComputername, days, hours, minutes | sort PSComputername