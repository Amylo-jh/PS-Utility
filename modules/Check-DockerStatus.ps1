# 스크립트 동작 조건 확인
function Check-Environment
{
    if($env:COMPUTERNAME -ne 'MS')
    {
        Write-Host "This script should be run on MS"
    }
}

# 사용자 계정의 비밀번호를 입력받아 유효한지 검증
function Validate-Credential
{
    while($true)
    {
        $cred = Get-Credential -UserName $env:COMPUTERNAME -Message "Enter Password to validate Password"
        $EncryptedPwd = $cred.GetNetworkCredential().Password
        $CurrentDomain = "LDAP://" + ([ADSI]"").distinguishedName
        $planePwd = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Cred.Password))
        $domain = New-Object System.DirectoryServices.DirectoryEntry($CurrentDomain, $env:USERNAME, $EncryptedPwd)

        if($domain.Name -eq $null)
        {
            Write-Host "authentication failed" -BackgroundColor DarkRed
        }
        else
        {
            Write-Host "authentication success" -BackgroundColor DarkGreen
            break
        }
    }

    return $planePwd
}

# Main EntryPoint

Check-Environment
$curr_location = Get-Location
Set-Location "SOMEWHERE_SSH_LOCATES"

$plainPassword = Validate-Credential
# DO SSH using planepassword| sudo -S docker container ls
Set-Location $curr_location
pause