param(
    [switch]$silent_diskspace,
    [switch]$open_cleanmgr
)

$osInfo = (Get-WmiObject -class win32_OperatingSystem).producttype
if($osInfo -eq 1)
{
    ## this part is for Workstation
    rm -recurse -force -erroraction Silentlycontinue "C:\Users\*\AppData\Local\Microsoft\Windows\WER\ReportQueue\*"
    rm -recurse -force -erroraction Silentlycontinue "C:\Users\*\AppData\Local\Microsoft\Windows\WebCache\*"
    rm -recurse -force -erroraction Silentlycontinue "C:\Users\*\Appdata\Local\Microsoft\Terminal Server Client\Cache\*"
    rm -recurse -force -erroraction Silentlycontinue "C:\Users\*\AppData\Local\Microsoft\Excel\*"
    rm -recurse -force -erroraction Silentlycontinue "C:\Users\*\AppData\Local\Temp\*"
    
    rm -force -erroraction Silentlycontinue "C:\Program Files (x86)\Mcafee\Epolicy Orchestrator\Server\Temp\*.tmp"

    Clear-RecycleBin -force

    if($open_cleanmgr -eq $true)
    {
        cleanmgr
    }

    exit
}

## This part is for server
$computers_all = invoke-command -computername ad1 -scriptblock { (get-adcomputer -filter 'name -ne "CH1"').name }

Invoke-Command -ComputerName $computers_all -ScriptBlock {
    rm -recurse -force -erroraction Silentlycontinue "C:\Users\*\AppData\Local\Microsoft\Windows\WER\ReportQueue\*"
    rm -recurse -force -erroraction Silentlycontinue "C:\Users\*\AppData\Local\Microsoft\Edge\User Data\Default\Code Cache\js"
    rm -recurse -force -erroraction Silentlycontinue "C:\Users\*\AppData\Local\Microsoft\Windows\WebCache\*"
    rm -recurse -force -erroraction Silentlycontinue "C:\Users\*\AppData\Local\Microsoft\Terminal Server Client\Cache\*"
    rm -recurse -force -erroraction Silentlycontinue "C:\Users\*\AppData\Local\Microsoft\Excel\*"
    rm -recurse -force -erroraction Silentlycontinue "C:\Users\*\AppData\Local\Temp\*"
    
    rm -force -errorAction Silentlycontinue "C:\Program Files (x86)\Mcafee\Epolicy Orchestrator\Server\Temp\*.tmp"
    
    Clear-RecycleBin -force
}
if($open_cleanmgr -eq $true)
{
    cleanmgr
}

if($silent_diskspace -ne $true)
{
    .\Get-ServerDiskSpace.ps1 -show_minimum
}