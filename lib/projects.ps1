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
    <link rel="icon" href="data:image/png;base64,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" type="image/png">
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
