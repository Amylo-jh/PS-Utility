# 스크립트 로깅 시작
function Start-Logging
{
    param([string]$Audit_type)

    if((Test-Path ./log) -ne $true)
    {
        mkdir ./log
    }

    $today = Get-Date -format yyyyMMdd_hhmm
    $filename = $env:NODENAME + "_" + $today + "_" + $Audit_type + "_Audit_Result"
    Start-Transcript -Path ./log/"$filename.txt"
}

# 스크립트 로깅 종료
function Stop-Logging
{
    Stop-Transcript
}

#스크립트 동작 조건 확인
function Check-Environment
{
    if($env:COMPTERNAME -ne 'ad1')
    {
        Write-Host "This script should be run on AD1."
        Pause
        Stop-Logging
        exit
    }
}

# 역할별 권한, 계정 정의
function Define-Accounts
{
    # Write Reference at here
    $Global:Sys_Admin = "Domain Admins", "Domain Users"
    $Global:DB_Admin = "Domain Admins", "Domain Database Admins", "Domain Users"
    $Global:Sec_Admin = "Domain Admins", "Domain Auditors", "Domain Users"
    $Global:Net_Admin = "Domain Admins", "Domain Network Admins", "Domain Users"

    $Global:WS_Sys = "Domain Workstation Admin", "Domain Users"
    $Global:WS_Sec = "Domain Workstation Admin", "Domain Auditors", "Domain Users"

    $Global:Excluded_Account = "sysadmin", "buadmin", "krbtgt"
    $Global:Extra_Users = Get-Content -path .\extra_lists.txt
    $Global:Extra_Role = "Extra_Roles"
}

# 사용자의 역할이 올바른지 확인, 누락된 권한 또한 확인.
function Check-Role
{
    param([string[]]$curr_groups, [string[]]$user_role, [string]$user_name)
    
    $Extra_Flag = $false
    if($Extra_Users -match $user_name)
    {
        $Extra_Flag = $true
        if($curr_groups.Contains($Extra_Role))
        {
            Write-Host "VALID   : $Extra_Role" -BackgroundColor DarkCyan
        }
        else
        {
            Write-Host "MISSING : $Extra_Role" -BackgroundColor Magenta
        }
    }

    foreach($curr_group in $curr_groups)
    {
        if( ($Extra_Flag -eq $true) -and ($curr_group -eq $Extra_Role) )
        {
            continue
        }

        if($user_role.Contains($curr_group))
        {
            Write-Host "VALID   : $curr_group" -BackgroundColor DarkCyan 
        }
    }

    foreach($should_role in $user_role)
    {
        if($curr_groups.Contains($should_role))
        {
            continue
        }
        else
        {
            if($should_role -eq "")
            {
                continue
            }
            Write-Host "MISSING : $should_role" -BackgroundColor Magenta
        }
    }
}

# 사용자 목록을 가져와 하나씩 권한 체크 시작
function Init-Check
{
    $ADUsers = Get-ADUser -filter * -SearchBase "CN=Users,DC=EXAMPLE,DC=EXAMPLE"
    foreach($aduser in $ADUsers)
    {
        Write-Host "=============================================================="
        $username = $aduser.SamAccountName
        if($aduser.Enabled)
        {
            Write-Host "Enabled  : $username"
        }
        else
        {
            Write-Host "Disabled : $username"
        }

        $user_type = $username.ToUpper().split('_')[1]
        $user_role = ""
        $curr_groups = (Get-AdPrincipalGroupMembership -Identity $aduser).name

        if($user_type -eq "SA")
        {
            $user_role = $Sys_Admin
        }
        else if($user_type -eq "DBA")
        {
            $user_role = $DB_Admin
        }
        else if($user_type -eq "SEC")
        {
            $user_role = $Sec_Admin
        }
        else if($user_type -eq "NA")
        {
            $user_role = $Net_Admin
        }
        else if($user_type -eq "WS")
        {
            $user_type = $username.ToUpper().split('_')[2]
            if($user_type -eq "SA")
            {
                $user_role = $WS_Sys
            }
            else if($user_type -eq "SEC")
            {
                $user_role = $WS_Sec
            }
            else
            {
                Write-Host "Cannot find $username's role."
            }
        }
        else
        {
            Write-Host "Cannot find $username's role."
        }
    }

    Write-Host " "
    Check-Role -curr_groups $curr_groups -user_role $user_role -user_name $username
    Write-Host " "
}

function Audit-InactiveAccount
{
    Get-ADUser -filter * -property * -searchbase "OU=EXAMPLE,DC=EXAMPLE,DC=EXAMPLE" |
        Sort-Object -Property LastLogonDate -Descending |
        where {$_.Created -le ((Get-Date).AddDays(-35))} | 
        where {$_.LastLogonDate -le ((Get-Date).AddDays(-35))} |
        Format-Table -Property SamAccountName, SurName, GivenName, Enabled, LastLogonDate, PasswordLastset, Created -AutoSize

    Get-Aduser -filter * -property * -searchbase "CN=EXAMPLE,DC=EXAMPLE,DC=EXAMPLE" |
        Sort-Object -Property LastLogonDate -Descending |
        where {$_.Created -le ((Get-Date).AddDays(-35))} | 
        where {$_.LastLogonDate -le ((Get-Date).AddDays(-35))} |
        Format-Table -Property SamAccountName, SurName, GivenName, Enabled, LastLogonDate, PasswordLastset, Created -AutoSize
}

# Main EntryPoint
Check-Environment

Start-Logging -Audit_type "Permission"
Define-Accounts
Init-Check
Stop-Logging

Start-Logging -Audit_type "Account"
Audit-InactiveAccount
Stop-Logging