.\Hypervisor.ps1

<#
.DESCRIPTION
Display SQl services
#>
function ListSQLServices
{
    $Services = Get-Service | Where-Object DisplayName -Like "SQL*"

    "=== SQL Server Services ===" | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
    "$($Services)" | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
}

<#
.DESCRIPTION
List Admin Users
#>
function ListAdminUsers
{
    $serverInstance = Get-Service | Where-Object { $_.Name -like 'MSSQL*' } | Select-Object DisplayName, Status
    $query = "SELECT name FROM sys.server_principals WHERE is_fixed_role = 1 AND name = 'sysadmin'"
    $adminUsers = Invoke-Sqlcmd -ServerInstance $serverInstance -Query $query

    "=== Admin Users ===" | Out-File -Filepath ".\info.txt" -Append -Encoding utf8
    "$($adminUsers)" | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
}

<#
.DESCRIPTION
Display and list disabled admin Users#>
function DisabledUsers
{
    $serverInstance = Get-Service | Where-Object { $_.Name -like 'MSSQL*' } | Select-Object DisplayName, Status
    $query = "SELECT name, is_disabled FROM sys.server_principals WHERE is_fixed_role = 1 AND name = 'sysadmin' AND is_disabled = 1"
    $disabledUsers = Invoke-Sqlcmd -ServerInstance $serverInstance -Query $query

    "=== Disabled Admin Users ===" | Out-File -Filepath ".\info.txt" -Append -Encoding utf8
    "$($disabledUsers)" | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
}

<#
.DESCRIPTION
See last Users login
#>
function LastUsersLog
{
    $serverInstance = Get-Service | Where-Object { $_.Name -like 'MSSQL*' } | Select-Object DisplayName, Status
    $query = "SELECT p.name, p.type_desc, s.last_login
        FROM sys.server_principals p
        LEFT JOIN sys.syslogins s ON p.sid = s.sid
        WHERE p.is_fixed_role = 1 AND p.name = 'sysadmin'"
    $adminUserLog = Invoke-Sqlcmd -ServerInstance $serverInstance -Query $query

    "=== Admin Last Login ===" | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
    "$($adminUserLog)" | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
}

<#
.DESCRIPTION
Display last password change
#>
function LastPwdChange
{
    $serverInstance = Get-Service | Where-Object { $_.Name -like 'MSSQL*' } | Select-Object DisplayName, Status
    $query = "SELECT p.name, p.type_desc, s.password_changed
        FROM sys.server_principals p
        LEFT JOIN sys.sql_logins s ON p.sid = s.sid
        WHERE p.is_fixed_role = 1 AND p.name = 'sysadmin'"
    $adminLastPwd = Invoke-Sqlcmd -ServerInstance $serverInstance -Query $query

    "=== Admin Last Password change ===" | Out-File -Filepath ".\info.txt" -Append -Encoding utf8
    "$($adminLastPwd)" | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
}

<#
.DESCRIPTION
List Server Service
#>
function ListServerService
{
    $services = Get-Service | Where-Object { $_.DisplayName -like 'SQL Server*' } | Select-Object DisplayName, Status, Name

    "=== SQL Installed Service ===" | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
    "$($services)" | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
}

<#
.DESCRIPTION
List Disabled Spooler
#>
function IsSpoolerEnable
{
    $spoolers = Get-Service -Name Spooler | Select-Object DisplayName, Status

    "=== Disabled Spoolers ===" | Out-File -Filepath ".\info.txt" -Append -Encoding utf8
    foreach ($spooler in $spoolers) {
        if ($spooler.StartType -eq 'Disabled') {
            "$($spooler.Name): $($spooler.Status)" | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
        }
    }
}

<#
.DESCRIPTION
Local User SQL
#>
function LocalUserSql
{
    $serverInstance = Get-Service | Where-Object { $_.Name -like 'MSSQL*' } | Select-Object DisplayName, Status
    $query = "SELECT name, type_desc FROM sys.database_principals WHERE type IN ('S', 'U') AND sid 0x0"
    $localUsers = Invoke-Sqlcmd -ServerInstance $serverInstance -Database 'master' -Query $query

    "=== Local Users SQL ===" | Out-File -Filepath ".\info.txt" -Append -Encoding utf8
    "$($localusers)" | Out-File -FilePath ".\info.txt" -Append -Enconding utf8
}

<#
.DESCRIPTION
Check if WebDAV is disabled
#>
function checkWebDAV
{
    $data = Get-WindowsFeature -Name WebDAV* | Select-Object DisplayName, InstallState

    "=== WebDAV ===" | Out-File -Filepath ".\info.txt" -Append -Encoding utf8
    if ($data.InstallState -eq "installed") {
        Remove-WindowsFeature -Name WebDAV-Redirector, WebDAV-Publishing
        checkWebDAV
    } else {
        "Disabled" | Out-File -Filepath ".\info.txt" -Append -Encoding utf8
    }
}

<#
.DESCRIPTION
Check Password Complexity of each admin user
#>
function CheckPwdComplexity
{
    $admins = Get-LocalUser | Where-Object { $_.Name -eq "Administrator"}

    "=== Admins Paswword Complexity ===" | Out-File -Filepath ".\info.txt" -Append -Encoding utf8
    foreach ($admin in $admins) {
        "$($admin.Name): $($admin.PasswordComplexity)" | Out-File -Filepath ".\info.txt" -Append -Encoding utf8
    }
}

<#
.DESCRIPTION
MSSql windows server main function#>
function SQLmain
{
    ListSQLServices
    IsSpoolerEnable
    LastPwdChange
    LastUsersLog
    DisabledUsers
    ListAdminUsers
    ListSQLServices
    checkWebDAV
    LocalUserSql
    IsSpoolerEnable
    ListServerService
    CheckPwdComplexity
}

SQLmain
