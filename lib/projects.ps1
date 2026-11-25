# Project creation helpers: blank, WordPress, Laravel and the CMS catalog.

function New-Salt {
    param([int]$Length = 64)
    $chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()-_[]{}<>~`+=,.;:/?|'
    $random = New-Object System.Security.Cryptography.RNGCryptoServiceProvider
    $bytes = New-Object byte[] $Length
    $random.GetBytes($bytes)
    $result = New-Object System.Text.StringBuilder
    foreach ($byte in $bytes) {
        $result.Append($chars[$byte % $chars.Length]) | Out-Null
    }
    return $result.ToString()
}

function New-ProjectDatabase {
    param([string]$Name)
    if (-not (Test-TcpPort -Port $MysqlPort)) {
        # One-click install: start MySQL automatically instead of aborting.
        # Only MySQL is needed to create a database; this is quick and safe.
        Start-MysqlService | Out-Null
    }
    if (-not (Test-TcpPort -Port $MysqlPort)) {
        throw 'MySQL is not running. Check logs\mysql-error.log, then start the stack.'
    }
    $dbName = $Name -replace '-', '_'
    $tick = [char]96
    $sql = "CREATE DATABASE IF NOT EXISTS $tick$dbName$tick CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    $output = & $MysqlCli "--defaults-file=$MyIni" -u root -e $sql 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Could not create database '$dbName'.`n$($output -join [Environment]::NewLine)"
    }
    return $dbName
}

function Save-RemoteFile {
    param(
        [string]$Url,
        [string]$Destination,
        [int]$MaxAttempts = 80
    )

    Ensure-Dir (Split-Path -Parent $Destination)
    $part = "$Destination.part"
    Remove-Item $part -Force -ErrorAction SilentlyContinue
    Write-Step "downloading $(Split-Path -Leaf $Destination)"

    # Native stderr becomes a terminating error when the caller runs with
    # ErrorActionPreference=Stop, which is exactly how the CLI starts. Keep
    # curl's stderr as plain text so a dropped transfer can be retried.
    $previous = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        # Some networks drop large TLS transfers part way through. Keep the
        # partial file and resume it instead of starting over: curl -C -
        # sends Range: bytes=<size>- and the next attempt continues.
        $expected = 0
        $head = & curl.exe -sIL --fail --max-time 60 $Url 2>$null
        foreach ($line in @($head)) {
            if ($line -match '^(?i)content-length:\s*(\d+)\s*$') { $expected = [int64]$Matches[1] }
        }

        $attempt = 0
        $stalled = 0
        $lastSize = -1
        $noResume = $false
        $complete = $false
        $errors = @()
        while ($attempt -lt $MaxAttempts) {
            $attempt++
            $curlArgs = @('-sS', '-L', '--fail', '--connect-timeout', '30', '--max-time', '1800',
                '--retry', '2', '--retry-delay', '1', '--retry-all-errors')
            if (-not $noResume) { $curlArgs += @('--continue-at', '-') }
            $curlArgs += @('-o', $part, $Url)
            $errors = @(& curl.exe @curlArgs 2>&1)
            $code = $LASTEXITCODE
            $size = if (Test-Path -LiteralPath $part) { (Get-Item -LiteralPath $part).Length } else { 0 }

            if ($expected -gt 0 -and $size -eq $expected) { $complete = $true; break }
            if ($expected -le 0 -and $code -eq 0 -and $size -gt 0) { $complete = $true; break }

            if ($expected -gt 0) {
                Write-Step ("downloaded {0:N1} of {1:N1} MB" -f ($size / 1MB), ($expected / 1MB))
            }

            if ($size -gt $lastSize) {
                $stalled = 0
            } else {
                $stalled++
            }
            $lastSize = $size

            if ($code -eq 33 -and -not $noResume) {
                # Server does not support byte ranges. Start over without
                # asking for a resume on the remaining attempts.
                $noResume = $true
                Remove-Item $part -Force -ErrorAction SilentlyContinue
                $lastSize = -1
                $stalled = 0
                continue
            }

            if ($stalled -ge 5) {
                $detail = @($errors | Select-Object -Last 3) -join ' '
                throw "Could not download $Url (no progress after $attempt attempts). $detail"
            }
            if ($attempt -ge 3) { Start-Sleep -Seconds $attempt }
        }

        if (-not $complete) {
            $detail = @($errors | Select-Object -Last 3) -join ' '
            throw "Could not download $Url (incomplete after $attempt attempts). $detail"
        }
        Move-Item -Force $part $Destination
    } finally {
        $ErrorActionPreference = $previous
    }
}

function New-BlankProject {
    param([string]$Name, [string]$Target)

    $phpVersion = $State.phpVersion
    $index = @"
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>$Name - WampDeck</title>
    <link rel="icon" href="data:image/svg+xml,%3Csvg xmlns=%27http://www.w3.org/2000/svg%27 viewBox=%270 0 64 64%27%3E%3Crect width=%2764%27 height=%2764%27 rx=%2714%27 fill=%27%232ee6a8%27/%3E%3Ctext x=%2732%27 y=%2742%27 font-family=%27Segoe UI,Arial%27 font-size=%2728%27 font-weight=%27bold%27 text-anchor=%27middle%27 fill=%27%230b1320%27%3EW%3C/text%3E%3C/svg%3E">
<style>
  :root { color-scheme: dark; }
  * { box-sizing: border-box; }
  body { margin: 0; min-height: 100vh; display: grid; place-items: center;
         font: 16px/1.6 "Segoe UI", system-ui, sans-serif; color: #e8eef7;
         background: radial-gradient(1200px 600px at 20% 0%, #16324f 0%, #0b1220 55%, #070b12 100%); }
  main { width: min(680px, 92vw); padding: 42px; border-radius: 20px;
         background: rgba(13, 22, 36, .82); border: 1px solid #22344d;
         box-shadow: 0 30px 80px rgba(0,0,0,.45); }
  .tag { display: inline-block; padding: 4px 10px; border-radius: 999px;
         background: #123b2a; color: #57e39b; font-size: 12px; letter-spacing: .12em;
         text-transform: uppercase; }
  h1 { margin: 18px 0 6px; font-size: 38px; letter-spacing: -.02em; }
  p { color: #9db0c7; margin: 0 0 26px; }
  dl { display: grid; grid-template-columns: 130px 1fr; gap: 10px 16px; margin: 0 0 28px; }
  dt { color: #6f86a3; }
  dd { margin: 0; font-family: Consolas, monospace; color: #cfe1f6; }
  a { color: #57b6ff; }
  .hint { margin-top: 26px; padding-top: 18px; border-top: 1px solid #1d2c40;
          color: #7d92ad; font-size: 13px; }
</style>
</head>
<body>
<main>
  <span class="tag">WampDeck</span>
  <h1>$Name</h1>
  <p>Your new project is ready. Drop your files in this folder and reload.</p>
  <dl>
    <dt>Folder</dt><dd>$Target</dd>
    <dt>PHP</dt><dd>$phpVersion</dd>
    <dt>Database</dt><dd>${Name}_db (create it from the panel)</dd>
    <dt>Local URL</dt><dd><a href="http://$Name.localhost">http://$Name.localhost</a></dd>
  </dl>
  <div class="hint">Edit <b>index.php</b> to get started. Laravel and WordPress
  can be created from the WampDeck panel with one click.</div>
</main>
</body>
</html>
"@
    Set-Content -Path (Join-Path $Target 'index.php') -Value $index -Encoding UTF8
    return 'blank'
}

function New-WampDeckProject {
    param(
        [string]$Name,
        [ValidateSet('blank', 'wordpress', 'laravel')]
        [string]$Type = 'blank',
        [string]$Cms,
        [string]$AdminUser,
        [string]$AdminEmail,
        [string]$AdminPassword,
        [switch]$Force,
        [switch]$NoHosts
    )

    if ($Name -notmatch '^[a-z0-9][a-z0-9-]{0,30}$') {
        throw 'Project name must be lowercase letters, digits or hyphens (max 31 chars).'
    }
    if ($Name -eq 'panel') { throw "'panel' is reserved." }

    $target = Join-Path $WwwDir $Name
    if (Test-Path $target) {
        $items = @(Get-ChildItem $target -Force)
        if ($items.Count -gt 0 -and -not $Force) {
            throw "Folder www\\$Name already exists and is not empty. Use -Force to add files anyway."
        }
    }
    Ensure-Dir $target

    $cmsResult = $null
    if ($Cms) {
        # A CMS owns the whole folder, so it must start from an empty directory.
        if (@(Get-ChildItem $target -Force).Count -gt 0) {
            throw "CMS install needs an empty folder, but www\$Name is not empty."
        }
        try {
            $cmsResult = Install-WampDeckCms -Cms $Cms -Name $Name -Target $target `
                -AdminUser $AdminUser -AdminEmail $AdminEmail -AdminPassword $AdminPassword
        } catch {
            # A failed install leaves a half-populated folder behind that
            # blocks the next attempt. The install log lives in logs\, so it
            # is safe to remove the folder itself.
            if (Test-Path -LiteralPath $target) {
                Remove-Item -LiteralPath $target -Recurse -Force -ErrorAction SilentlyContinue
            }
            throw
        }
    } else {
        switch ($Type) {
            'blank' { New-BlankProject -Name $Name -Target $target | Out-Null }
            'wordpress' { New-WordPressProject -Name $Name -Target $target -Force:$Force | Out-Null }
            'laravel' { New-LaravelProject -Name $Name -Target $target | Out-Null }
        }
    }

    # Every project gets a manifest, so its PHP version, document root and
    # database name are explicit and export/import can rebuild them later.
    $databaseName = $Name -replace '-', '_'
    if (-not $Cms -and $Type -eq 'blank' -and (Test-TcpPort -Port $MysqlPort)) {
        try { New-ProjectDatabase -Name $Name | Out-Null } catch { }
    }
    $docRoot = ''
    if ($cmsResult -and $cmsResult.DocRoot) {
        $docRoot = [string]$cmsResult.DocRoot
    } elseif (Test-Path (Join-Path $target 'public\index.php')) {
        $docRoot = 'public'
    } elseif (Test-Path (Join-Path $target 'web\index.php')) {
        $docRoot = 'web'
    }
    if (-not (Test-Path (Get-ManifestPath $target))) {
        New-WampDeckManifest -ProjectDir $target -Name $Name -Php 'any' -Web 'any' `
            -DocRoot $docRoot -Database $databaseName | Out-Null
    }

    Write-AllConfigs

    try {
        if ((Get-StackStatus).WebRunning) { Reload-WebServer | Out-Null }
    } catch { }

    $hostsSynced = $false
    if (-not $NoHosts) {
        $hostsSynced = Invoke-HostsSyncElevated
    }

    try { Invoke-ManifestPostCreate -ProjectDir $target | Out-Null } catch { }

    $project = Get-ProjectByName $Name
    if ($project) {
        return [pscustomobject]@{
            Name       = $Name
            Type       = if ($Cms) { $Cms } else { $Type }
            Folder     = $target
            Url        = $project.Url
            TestUrl    = $project.TestUrl
            HttpsUrl   = $project.HttpsUrl
            HostsSynced = $hostsSynced
            CmsResult  = $cmsResult
        }
    }
    return [pscustomobject]@{
        Name = $Name; Type = if ($Cms) { $Cms } else { $Type }; Folder = $target
        Url = (Get-ProjectUrl $Name); TestUrl = (Get-ProjectTestUrl $Name)
        HttpsUrl = (Get-ProjectHttpsUrl $Name); HostsSynced = $hostsSynced
        CmsResult = $cmsResult
    }
}
