# 스크립트 로깅 시작
function Start-Logging
{
    param([string]$Audit_type)

    if((Test-Path ./log) -ne $true)
    {
        mkdir ./log
    }

    $today = Get-Date -Format yyyyMMdd_hhmm
    $filename = $env:COMPUTERNAME + "_" + $today + "_" = $Audit_type + "_Audit_Result"
    Start-Transcript -Path ./log/"$filename.txt"
}

#스크립트 로깅 종료
function Stop-Logging
{
    Stop-Transcript
}

Function Check-Group
{
    param($groupname, $userid)
    if(Get-LocalGroupMember $groupname | `
        Where Name -lie (*+$userid)) {return 'Y'} `
            else {return '.'}
}

Start-Logging -Audit_type "Permission"

$legit_role = "Administrators", "Auditors", "Network Administrators", "Extra_Role", "DenyNetworkAccess"
$LocalUsers = Get-LocalUsers
$LocalGroups = Get-LocalGroup

$result = foreach ($LocalUser in $LocalUsers)
{
    $username = $LocalUser.Name
    
    $LocalUser | Select-Object `
        Enabled, `
        Name, `
        @{n = 'Role';               e = { ($_.Name).toUpper().split('_')[1] }}, `
        @{n = 'Administrators';     e = { Check-Group -groupname 'Administrators' -userid $_.name }}, `
        @{n = 'Auditors';           e = { Check-Group -groupname 'Auditors' -userid $_.name }}, `
        @{n = 'Network Admins';     e = { Check-Group -groupname 'Network Administrators' -userid $_.name }}, `
        @{n = 'DenyNetworkAccess';  e = { Check-Group -groupname 'DenyNetworkAccess' -userid $_.name }}, `
        @{n = 'Extra_Role';         e = { Check-Group -groupname 'Extra_Role' -userid $_.name }}, `
        @{n = 'Invalid Role';       e = { foreach($localgroup in $LocalGroups)
                                            {
                                                if($legit_role -notcontains $Localgroup.name)
                                                {
                                                    if(Get-LocalGroupMember $localgroup | where Name -Match $username)
                                                    {
                                                        $Localgroup
                                                    }
                                                }
                                            }
                                        }
        }               
}

$result | sort -Property name | sort -Property Role | Format-Table *

Stop-Logging

Start-Logging -Audit_type "Account"

$today = Get-Date
$daysold = 35
$maxday = $today.AddDays(-$daysold)
$targetdate = Get-Date $maxday -format yyyyMMdd
Write-Host "$daysold Days before is $targetdate"

Get-LocalUser | Sort-Object -Property LastLogon |
    Format-Table Name, Enabled, LastLogon, PasswordLastset

Stop-Logging