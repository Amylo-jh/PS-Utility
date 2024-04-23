param(
    [switch]$show_minimum
)

$show_count = 9999
if($show_minimum)
{
    $show_count = 10
}

$computers_all = invoke-command -ComputerName ad1 -ScriptBlock { (get-adcomputer -filter 'name -ne "CH1"').name }

$result = invoke-command -ComputerName $computers_all -ScriptBlock {
    Get-PSDrive -PSProvider FileSystem | where used -ne 0 |
        Select-Object `
            @{n = 'ComputerName'; e = {$env:Computername}}, `
            @{n = 'DriveName'; e = {$_.Root}}, `
            @{n = 'Percent Free (%)'; e = {[math]::Round($_.Free/($_.used + $_.free) * 100, 2)} }, `
            @{n = 'Free Space (GB)'; e = {[math]::Round($_.free/1024/102/1024, 2)} }
}

$result | select Computername, DriveName, "Percent Free (%)", "Free Space (GB)" | sort -Property "Percent Free (%)" | Select-Object -First $show_count | Format-Table -AutoSize

