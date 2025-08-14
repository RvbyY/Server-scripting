.\smbv1checker.ps1

function ListSQLServices
{
    $Services = Get-Service | Where-Object DisplayName -Like "SQL*"
    "=== SQL Server Services ===" | Out-File -FilePath ".\info.txt" -Append -Encoding utf8

    "$($Services)" | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
}

function SQLmain
{
    ListSQLServices
}

SQLmain
