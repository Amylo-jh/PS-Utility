$computers = Invoke-Command -ComputerName ad1 -ScriptBlock { (get-adcomputer -filter 'name -ne "CH1"').name}

$taskresult = Invoke-Command -ComputerName $computers -ScriptBlock {
    $tasks = Get-ScheduledTask -TaskPath \Domain\ | Where-Object State -NE Disabled

    foreach($task in $tasks)
    {

        Get-ScheduledTaskInfo -Taskname $task.TaskName -TaskPath $task.TaskPath | Where-Object -Property NumberOfMissedRuns -NE 0
        Get-ScheduledTaskInfo -Taskname $task.TaskName -TaskPath $task.TaskPath | Where-Object -Property LastTaskResult -NE '0'
    }
}

if($taskresult -ne $null)
{
    Write-Host "#############################" -ForegroundColor Yellow
    Write-Host " Failed tasks under \Domain\ " -ForegroundColor Yellow
    Write-Host "#############################" -ForegroundColor Yellow

    $taskresult | Format-Table @{name = "ComputerName"; e = {$_.PSComputerName}}, 'Taskname', LastTaskResult, NumberOfMissedRuns -AutoSize
}
else
{
    Write-Host "There are no failed Scheduled Tasks." -ForegroundColor Green
}