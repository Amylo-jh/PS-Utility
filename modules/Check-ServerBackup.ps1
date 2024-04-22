$computers = Invoke-Command -ComputerName ad1 -ScriptBlock { (get-adcomputer -filter 'name -ne "CH1"').name }

Invoke-Command -ComputerName $computers -ScriptBlock {
    $weeklyexist = Test-Path "J:\logs\weeklybackup.log"
    $dailyexist = Test-Path "J:\logs\dailybackup.log"

    if($weeklyexist)
    {
        $weeklyresult = gc "J:\logs\weeklybackup.log" -tail 3 | sls success
        if($weeklyresult -eq $null)
        {
            Write-Host $env:COMPUTERNAME
        }
    }

    if($dailyexist)
    {
        $dailyresult = gc "J:\logs\dailybackup.log" -tail 3 | sls success
        if($dailyresult -eq $null)
        {
            Write-Host "$env:computername has failed in Dailybackup! `n" -BackgroundColor Red
        }
    }
}