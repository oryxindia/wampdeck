# Free first-run wizard: three steps to a usable local stack.
# CLI only - the panel UI is not changed.

function Get-OnboardingMarker {
    return Join-Path $EtcDir 'onboarding.json'
}

function Read-WizardInput {
    param([string]$Prompt, [string]$Default = '')
    try {
        $answer = Read-Host $Prompt
        if ($answer) { return $answer }
    } catch { }
    return $Default
}

function Invoke-FirstRunWizard {
    param([switch]$Force)

    $marker = Get-OnboardingMarker
    if ((Test-Path $marker) -and -not $Force) {
        $data = Get-Content $marker -Raw | ConvertFrom-Json
        Write-Host ''
        Write-Host '  Setup already completed.' -ForegroundColor Green
        Write-Host ('    PHP      : ' + $data.php)
        Write-Host ('    project  : ' + $data.project)
        Write-Host ''
        Write-Host '  Run it again with: wampdeck wizard --force'
        return 0
    }

    Write-Host ''
    Write-Host '  WampDeck first-run setup' -ForegroundColor Cyan
    Write-Host '  Three quick steps. Press Enter to accept the defaults.'
    Write-Host ''

    # Step 1 - PHP version
    Write-Host '  1/3  PHP version' -ForegroundColor White
    Write-Host ('       available: ' + ($PhpVersions -join ', '))
    $php = Read-WizardInput -Prompt ('       use PHP [' + $State.phpVersion + ']: ') -Default $State.phpVersion
    if ($PhpVersions -notcontains $php) {
        $php = $State.phpVersion
        Write-Host ('       unknown version, using ' + $php) -ForegroundColor Yellow
    }
    $State.phpVersion = $php
    Save-StackState
    Write-Host ('       PHP ' + $php + ' selected.') -ForegroundColor Green

    # Step 2 - first project
    Write-Host '  2/3  First project' -ForegroundColor White
    $name = Read-WizardInput -Prompt '       project folder [demo]: ' -Default 'demo'
    if ($name -notmatch '^[A-Za-z0-9_-]+$') {
        Write-Host '       invalid name, using demo.' -ForegroundColor Yellow
        $name = 'demo'
    }
    $projectDir = Join-Path $WwwDir $name
    if (-not (Test-Path $projectDir)) {
        New-WampDeckProject -Name $name -Type 'blank' | Out-Null
        Write-Host ('       project ' + $name + ' created.') -ForegroundColor Green
    } else {
        Write-Host ('       project ' + $name + ' already exists.') -ForegroundColor DarkGray
    }

    # Step 3 - hosts sync
    Write-Host '  3/3  Hostnames' -ForegroundColor White
    Write-Host '       .localhost names already work; .test names need one hosts entry.'
    $hostsOk = $false
    try { $hostsOk = [bool](Invoke-HostsSyncElevated) } catch { $hostsOk = $false }
    if ($hostsOk) {
        Write-Host '       hosts file synced.' -ForegroundColor Green
    } else {
        Write-Host '       hosts sync skipped (UAC not approved). Use: wampdeck hosts sync' -ForegroundColor Yellow
    }

    Write-AllConfigs

    $markerData = [ordered]@{
        schema  = 1
        php     = $php
        project = $name
        hosts   = $hostsOk
        done    = [DateTime]::UtcNow.ToString('o')
    }
    [IO.File]::WriteAllText($marker, ($markerData | ConvertTo-Json -Depth 4), [Text.Encoding]::UTF8)

    Write-Host ''
    Write-Host '  Setup complete.' -ForegroundColor Green
    Write-Host '  Next: wampdeck start  ->  http://localhost'
    Write-Host ''
    return 0
}
