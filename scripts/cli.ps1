# Entry point for wampdeck.cmd.
#
# wampdeck.cmd puts the raw command line in WAMPDECK_CLI_ARGS. If PowerShell
# received the arguments itself it would try to bind "--out" and friends as
# script parameters ("ambiguous parameter" errors), so we parse them here.
#
# Exit codes: 0 ok, 1 error, 2 doctor found a failure.
#
# The dispatcher returns its exit code as the last pipeline object. Command
# output (for example `status --json`) must be re-emitted before exiting;
# wrapping the call in `exit (...)` would swallow it.

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot '..\lib\bootstrap.ps1')

$arguments = @()
if ($env:WAMPDECK_CLI_ARGS) {
    $arguments = @(Split-CommandLine -Text $env:WAMPDECK_CLI_ARGS)
}

$result = @(Invoke-WampDeckCli -Arguments $arguments)
$code = 0
if ($result.Count -gt 0) {
    $last = $result[$result.Count - 1]
    if ($last -is [int]) {
        $code = [int]$last
        if ($result.Count -gt 1) {
            $result[0..($result.Count - 2)] | ForEach-Object { Write-Output $_ }
        }
    } else {
        $result | ForEach-Object { Write-Output $_ }
    }
}

exit $code