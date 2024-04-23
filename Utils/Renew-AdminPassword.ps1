if($env:computername -ne "MS")
{
    Write-Host "This script should run on MS."
    Pause
    exit
}

$password = ""
while($true)
{
    $password = Read-Host "Enter new password for sysadmin / buadmin : "
    $password2 = Read-host "Re-Enter to confirm password : "

    if($password -eq $password2)
    {
        Write-Host "Password validated."
        break
    }
    else
    {
        Write-Host "Entered Password does not match."
    }
}

$session = New-PSSession -ComputerName ad1
Export-PSSession -Session $session -Module ActiveDirectory -OutputModule ActiveDirectory -Force
Import-Module ActiveDirectory
$computers = Get-Adcomputer -filter 'name -ne "CH1"'
foreach($computer in $computers)
{
    if(Test-WSMan -ComputerName $computer.name)
    {
        Write-Host -ForegroundColor Green "$computer.name is alive. Renewing Passwords..."
        invoke-command -ComputerName $computer.name -scriptblock {
            param($password)
            net user sysadmin $password
            net user buadmin $password
        } -argumentlist $password
    }
    else
    {
        Write-Host -ForegroundColor Yellow "$computer.name is dead. Skipped."
    }
}

Remove-Module ActiveDirectory
Write-Host -ForegroundColor Yellow "Finished"