# Opt-in fixes for doctor findings.
#
# Deliberately conservative: only regenerates configuration and syncs hosts.
# Never touches www\, data\, snapshots, manifests or user projects. Never
# starts/stops the stack on its own. The user opts in with `wampdeck doctor --fix`.

function Invoke-DoctorFix {
    param([object[]]$Checks)

    $results = New-Object System.Collections.Generic.List[object]
    $configWritten = $false

    foreach ($check in @($Checks)) {
        if ($check.Status -eq 'pass' -or $check.Status -eq 'skip') { continue }

        $applied = $false
        $detail = ''

        switch -Wildcard ($check.Id) {
            'hosts' {
                # Same elevated helper the panel and hosts.cmd use. No UAC
                # prompt when the caller is already elevated (setup/install).
                try {
                    $applied = [bool](Invoke-HostsSyncElevated)
                    $detail = if ($applied) { 'managed hosts block synced' } else { 'hosts sync was not completed (UAC cancelled?)' }
                } catch {
                    $detail = $_.Exception.Message
                }
            }
            'web-config' {
                try {
                    Write-AllConfigs
                    $configWritten = $true
                    $applied = $true
                    $detail = 'web server configs regenerated'
                } catch {
                    $detail = $_.Exception.Message
                }
            }
            'php-ini-*' {
                try {
                    if (-not $configWritten) {
                        Write-AllConfigs
                        $configWritten = $true
                    }
                    $applied = $true
                    $detail = 'php.ini regenerated from the current state'
                } catch {
                    $detail = $_.Exception.Message
                }
            }
            'php-opcache-*' {
                # A cached probe result can outlive the build that produced it.
                # Clear it and let configgen probe the current binaries again.
                try {
                    $cache = Join-Path $EtcDir 'php-runtime.json'
                    if (Test-Path $cache) { Remove-Item $cache -Force -ErrorAction Stop }
                    # configgen keeps an in-memory probe map. Clear it too, or
                    # Write-PhpIni will reuse the old result and never write
                    # the cache file back.
                    $script:OpcacheSupport = @{}
                    Write-AllConfigs
                    $configWritten = $true
                    $applied = $true
                    $detail = 'stale opcache probe cache cleared and re-probed'
                } catch {
                    $detail = $_.Exception.Message
                }
            }
            default {
                $detail = 'no automatic fix is available; see the fix hint'
            }
        }

        $results.Add([pscustomobject]@{
            Id      = $check.Id
            Applied = $applied
            Detail  = $detail
        })
    }

    return $results.ToArray()
}
