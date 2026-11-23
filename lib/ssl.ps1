# Local SSL: private CA + wildcard certificate for *.test / *.localhost.
# The CA is trusted in the CurrentUser Root store, so no administrator prompt
# is needed for the trust itself. Firefox keeps its own store (see README).

function Invoke-OpenSsl {
    param(
        [string[]]$Arguments,
        [string]$ErrorMessage = 'OpenSSL command failed'
    )
    if (-not (Test-Path $OpenSslExe)) {
        throw "OpenSSL was not found at $OpenSslExe"
    }
    $previous = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $output = & $OpenSslExe @Arguments 2>&1
    $code = $LASTEXITCODE
    $ErrorActionPreference = $previous
    if ($code -ne 0) {
        throw "$ErrorMessage`n$($output -join [Environment]::NewLine)"
    }
    return $output
}

function Test-CertificateFile {
    param([string]$Path)
    if (-not (Test-Path $Path)) { return $false }
    try {
        $null = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($Path)
        return $true
    } catch {
        return $false
    }
}

function Get-CertificateInfo {
    param([string]$Path)
    if (-not (Test-CertificateFile -Path $Path)) { return $null }
    $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($Path)
    $san = ''
    foreach ($ext in $cert.Extensions) {
        if ($ext.Oid.Value -eq '2.5.29.17') { $san = $ext.Format($false) }
    }
    return [pscustomobject]@{
        Subject    = $cert.Subject
        Issuer     = $cert.Issuer
        Thumbprint = $cert.Thumbprint
        NotBefore  = $cert.NotBefore
        NotAfter   = $cert.NotAfter
        DaysLeft   = [int]($cert.NotAfter - (Get-Date)).TotalDays
        San        = $san
    }
}

function Test-SslCertificate {
    # True when the leaf exists, has the right SANs, and stays valid for 30+ days.
    if (-not (Test-CertificateFile $SslCert)) { return $false }
    if (-not (Test-Path $SslKey)) { return $false }
    $info = Get-CertificateInfo $SslCert
    if (-not $info) { return $false }
    if ($info.DaysLeft -lt 30) { return $false }

    $required = @('*.test', '*.localhost', 'localhost', '127.0.0.1')
    foreach ($name in $required) {
        if ($info.San -notlike "*$name*") { return $false }
    }
    return $true
}

function Test-CaTrusted {
    if (-not (Test-CertificateFile $SslCaCert)) { return $false }
    $ca = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($SslCaCert)
    $store = New-Object System.Security.Cryptography.X509Certificates.X509Store('Root', 'CurrentUser')
    try {
        $store.Open('ReadOnly')
        foreach ($cert in $store.Certificates) {
            if ($cert.Thumbprint -eq $ca.Thumbprint) { return $true }
        }
        return $false
    } catch {
        return $false
    } finally {
        $store.Close()
    }
}

function Install-CaTrust {
    if (-not (Test-CertificateFile $SslCaCert)) {
        throw 'CA certificate is missing. Run ssl.ps1 first.'
    }
    if (Test-CaTrusted) { return $true }

    # Windows shows a one-time security confirmation when a root certificate
    # is added, even for the current user. Run certutil in a visible window so
    # the dialog is not hidden, and never block forever.
    $certutil = Join-Path $env:SystemRoot 'System32\certutil.exe'
    if (-not (Test-Path $certutil)) { return $false }

    $process = Start-Process -FilePath $certutil `
        -ArgumentList @('-user', '-addstore', '-f', 'Root', "`"$SslCaCert`"") `
        -WindowStyle Normal -PassThru
    try {
        Wait-Process -Id $process.Id -Timeout 30 -ErrorAction Stop
    } catch {
        Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
        return $false
    }
    return (Test-CaTrusted)
}

function Uninstall-CaTrust {
    $store = New-Object System.Security.Cryptography.X509Certificates.X509Store('Root', 'CurrentUser')
    $removed = 0
    try {
        $store.Open('ReadWrite')
        $found = @($store.Certificates | Where-Object { $_.Subject -like '*WampDeck Local CA*' })
        foreach ($cert in $found) {
            $store.Remove($cert)
            $removed++
        }
    } catch {
        throw "Could not remove the WampDeck CA: $($_.Exception.Message)"
    } finally {
        $store.Close()
    }
    return $removed
}

function New-WampDeckCa {
    Ensure-Dir $SslDir

    $args = @(
        'req', '-x509', '-newkey', 'rsa:2048', '-sha256', '-days', '3650', '-nodes',
        '-keyout', $SslCaKey,
        '-out', $SslCaCert,
        '-subj', '/C=US/ST=Local/L=Local/O=WampDeck/CN=WampDeck Local CA',
        '-addext', 'basicConstraints=critical,CA:TRUE',
        '-addext', 'keyUsage=critical,keyCertSign,cRLSign'
    )
    Invoke-OpenSsl -Arguments $args -ErrorMessage 'Could not create the WampDeck CA' | Out-Null

    # OpenSSL writes the key in PEM; Windows ACLs already protect the folder.
    return (Test-CertificateFile $SslCaCert)
}

function New-WampDeckCert {
    Ensure-Dir $SslDir

    $csr = Join-Path $SslDir 'server.csr'
    $ext = Join-Path $SslDir 'server.ext'
    $srl = Join-Path $SslDir 'ca.srl'

    $extContent = @'
basicConstraints = CA:FALSE
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = *.test
DNS.2 = *.localhost
DNS.3 = test
DNS.4 = localhost
IP.1 = 127.0.0.1
IP.2 = ::1
'@
    Set-Content -Path $ext -Value $extContent -Encoding ASCII

    $reqArgs = @(
        'req', '-new', '-newkey', 'rsa:2048', '-sha256', '-nodes',
        '-keyout', $SslKey,
        '-out', $csr,
        '-subj', '/C=US/ST=Local/L=Local/O=WampDeck/CN=*.test'
    )
    Invoke-OpenSsl -Arguments $reqArgs -ErrorMessage 'Could not create the server key' | Out-Null

    $signArgs = @(
        'x509', '-req', '-in', $csr,
        '-CA', $SslCaCert, '-CAkey', $SslCaKey,
        '-CAcreateserial', '-CAserial', $srl,
        '-out', $SslCert, '-days', '825', '-sha256',
        '-extfile', $ext
    )
    Invoke-OpenSsl -Arguments $signArgs -ErrorMessage 'Could not sign the server certificate' | Out-Null

    Remove-Item $csr -Force -ErrorAction SilentlyContinue
    Remove-Item $ext -Force -ErrorAction SilentlyContinue

    return (Test-SslCertificate)
}

function Initialize-Ssl {
    param([switch]$Force, [switch]$SkipTrust)

    Ensure-Dir $SslDir

    if ($Force) {
        foreach ($file in @($SslCert, $SslKey, $SslCaCert, $SslCaKey,
                (Join-Path $SslDir 'ca.srl'), (Join-Path $SslDir 'server.csr'),
                (Join-Path $SslDir 'server.ext'))) {
            Remove-Item $file -Force -ErrorAction SilentlyContinue
        }
    }

    $createdCa = $false
    if (-not (Test-CertificateFile $SslCaCert) -or -not (Test-Path $SslCaKey)) {
        New-WampDeckCa | Out-Null
        $createdCa = $true
    }

    if (-not (Test-SslCertificate) -or -not (Test-Path $SslKey)) {
        New-WampDeckCert | Out-Null
    }

    $trusted = Test-CaTrusted
    if (-not $trusted -and -not $SkipTrust) {
        $trusted = Install-CaTrust
    }

    return [pscustomobject]@{
        CreatedCa = $createdCa
        Trusted   = $trusted
        Cert      = (Get-CertificateInfo $SslCert)
    }
}

function Get-SslStatus {
    $cert = Get-CertificateInfo $SslCert
    $ca = Get-CertificateInfo $SslCaCert
    return [pscustomobject]@{
        HasCa      = [bool]$ca
        Trusted    = (Test-CaTrusted)
        HasCert    = [bool]$cert
        Valid      = (Test-SslCertificate)
        Cert       = $cert
        Ca         = $ca
    }
}

function Reset-Ssl {
    Uninstall-CaTrust | Out-Null
    return (Initialize-Ssl -Force)
}
