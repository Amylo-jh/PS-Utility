$computers = Invoke-Command -ComputerName ad1 -ScriptBlock { (get-adcomputer -filter 'name -ne "CH1"').name}

$results = Invoke-Command -ComputerName $computers -ScriptBlock {
    get-wmiobject -class win32_operatingsystem | select freephysicalmemory, sizestoredinpagingfiles, TotalSwapSpaceSize, totalvirtualmemorysize, totalvisiblememorysize |
        Select-Object `
            @{n = 'TotalMemory (GB)'; e = {[Math]::Round($_.totalvisiblememorysize / 1024 / 1024 * 100) / 100}}, `
            @{n = 'FreeMemory (GB)'; e = {[Math]::Round($_.freephysicalmemory / 1024 / 1024 * 100) / 100}}, `
            @{n = 'FreePercent (%)'; e = {[Math]::Round(($_.freephysicalmemory / $_.totalvisiblememorysize) * 100 * 100) / 100}}, `
            @{n = 'Warning'; e = {""} }
}

for($i = 0; $i -lt $results.Length; $i++)
{
    if($results[$i].PSComputerName -eq "Example")
    {
        $results[$i].Warning = "Warning!!"
    }
    else if($results[$i].PSComputerName -eq "Example2")
    {
        $results[$i].Warning = "Warning!!"
    }
}

$results | select PSComputerName, "TotalMemory (GB)", "FreeMemory (GB)", "FreePercent (%)", "Warning" | sort "FreePercent (%)" | ft -AutoSize