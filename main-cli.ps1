#requires -version 5.1
$ErrorActionPreference = "Stop"

Write-Host $PSScriptRoot

. ($PSScriptRoot + "\main.ps1" )

if (-not( Test-IsAdministrator )) {
    Start-AsAdministrator $PSCommandPath
} else {
    # Add check for outdated rule paths
    if (-not( Get-SWdfRule )) {
        New-SWdfRule
    }
    if (Switch-SWdfRule) {
        $verbage = "actively being smothered."
    } Else {
        $verbage = "currently allowed to breathe :)"
    }
    Write-Information ("Steam is {0}" -f $verbage )
    Exit-OnKeyPress
}
