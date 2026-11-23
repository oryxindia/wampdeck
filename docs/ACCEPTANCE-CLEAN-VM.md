# Clean-VM acceptance test

Release gate for the closed beta. Run this on a Windows machine that has never
had WampDeck, Laragon, XAMPP or IIS installed, then repeat the upgrade and
uninstall scenarios on the same VM.

The automated part is `scripts\acceptance-test.ps1`. It is read-only: it never
starts, stops, installs or uninstalls anything.

## Pass criteria

A build may go to beta testers only when all of these are true:

- Installer SHA-256 matches `SHA256SUMS.txt`.
- `scripts\acceptance-test.cmd` exits 0 with **0 failed, 0 warnings**.
- `wampdeck doctor` reports **23 passed, 0 warnings, 0 failed**.
- `http://localhost`, the demo project and every created project return HTTP 200.
- A project created before an upgrade still exists afterwards, with the same
  file fingerprint and its database row intact.
- Uninstall removes the program but keeps `www\` and `data\`.
- No personal project (`blog`, `edupro`, or a customer project) is modified.

## Test matrix

| ID | Scenario | Account | Install mode | Required |
|----|----------|---------|--------------|----------|
| A | Clean install | Administrator | All users, `C:\WampDeck` | Yes |
| B | Reinstall / upgrade in place | Administrator | All users | Yes |
| C | Uninstall and reinstall | Administrator | All users | Yes |
| D | No-admin install | Standard user | `/CURRENTUSER` | Yes |
| E | Port 80 already in use | Administrator | All users | Yes |
| F | Real projects on a developer copy | Administrator | All users | Before public beta |

Use Windows 11 24H2 x64 for A-C and E. Use a second standard local account for
D. Scenario F runs on a snapshot of the developer machine, never on the only
copy of the projects.

## Pre-flight

1. Take a VM snapshot named `clean-windows`.
2. Copy `WampDeck-Setup.exe`, `SHA256SUMS.txt` and `INSTALL-beta.md` into the VM.
3. Open PowerShell in that folder and verify the download:

```powershell
certutil -hashfile WampDeck-Setup.exe SHA256
Get-Content SHA256SUMS.txt
```

The two hashes must match. Stop if they do not.

4. Confirm the ports are free:

```powershell
Get-NetTCPConnection -State Listen -LocalPort 80,443,3306 -ErrorAction SilentlyContinue
```

No output means the ports are free.

5. Confirm the VM has no `C:\WampDeck`, `C:\laragon`, `C:\xampp` and no IIS
   site. A leftover folder invalidates the clean-install result.

## Scenario A - clean install

1. Double-click `WampDeck-Setup.exe`.
2. SmartScreen: **More info -> Run anyway**. This build is unsigned.
3. Accept UAC. Keep `C:\WampDeck`. Tick the desktop shortcut.
4. Wait for "Preparing WampDeck (configs and MySQL)...". First install takes
   one to three minutes.
5. Leave **Launch WampDeck** ticked and finish.
6. Wait for the tray icon, then open the panel and press **Start stack**.
7. Run the automated gate:

```powershell
cd C:\WampDeck
.\scripts\acceptance-test.cmd
```

Expected: every line `[PASS]`, summary `PASS 17  WARN 0  FAIL 0` on a clean VM
(one more `PASS` per extra project; 19 with the demo, blog and edupro
projects), and `RESULT: PASS`. The report is written to
`C:\WampDeck\logs\acceptance-<timestamp>.json`.

The HTTP checks wait up to 30 s per URL and retry a refused connection or a
5xx answer once after 2 s, because a just-started stack can refuse the first
request while `php-cgi` binds its port. A second failure is real; the detail
field names the timeout or the connection error.

8. Open <http://localhost> and <http://demo.test>. Both must load.
9. Create a project and switch its PHP version:

```powershell
cd C:\WampDeck
.\wampdeck.cmd new accepttest --preset blank
.\wampdeck.cmd php accepttest 8.2
```

Open <http://accepttest.test>. It must return HTTP 200 while the stack default
stays on PHP 8.3. Then clear the pin:

```powershell
.\wampdeck.cmd php accepttest --clear
```

10. Create the upgrade markers:

```powershell
Set-Content C:\WampDeck\www\accepttest\marker.txt 'before-upgrade'
& C:\WampDeck\bin\mysql\bin\mysql.exe "--defaults-file=C:\WampDeck\etc\my.ini" -u root -e "CREATE DATABASE IF NOT EXISTS acceptance_marker; CREATE TABLE IF NOT EXISTS acceptance_marker.t (v VARCHAR(32)); INSERT INTO acceptance_marker.t VALUES ('before');"
```

11. Reboot Windows. The stack is not set to auto-start by default. After login
    start it from the tray or with `.\wampdeck.cmd start`, then run the
    acceptance test again. This catches services that only work in the first
    logon session.

12. Capture the project fingerprint for scenario B. Stop the stack first so no
    file changes during the capture:

```powershell
cd C:\WampDeck
.\wampdeck.cmd stop
New-Item -ItemType Directory -Force C:\acceptance | Out-Null
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\acceptance-test.ps1 -Projects accepttest -CaptureBaseline C:\acceptance\before.json
```

Expected: `captured accepttest ... files ... bytes` and exit code 0.

## Scenario B - reinstall / upgrade in place

1. Copy the same installer to the VM (this tests in-place upgrade; use the next
   build when one exists).
2. Close the tray app. Run the installer again. It must reuse `C:\WampDeck`
   without asking for a new folder.
3. Wait for setup, start the stack, then run:

```powershell
cd C:\WampDeck
.\wampdeck.cmd list
.\wampdeck.cmd doctor
.\scripts\acceptance-test.cmd -Projects accepttest -Baseline C:\acceptance\before.json
```

Expected:

- `accepttest` is still listed and still opens with HTTP 200.
- `preserve-accepttest` is `[PASS]` with the same file count and bytes.
- The database marker still returns `before`:

```powershell
& C:\WampDeck\bin\mysql\bin\mysql.exe "--defaults-file=C:\WampDeck\etc\my.ini" -u root -N -B -e "SELECT v FROM acceptance_marker.t;"
```

- `marker.txt` still contains `before-upgrade`.

Any changed file in `www\accepttest`, or a missing database, blocks the release.

## Scenario C - uninstall and reinstall

1. Close WampDeck, including the tray icon.
2. Windows Settings -> Apps -> Installed apps -> **WampDeck** -> Uninstall.
3. Verify the program is gone but the data is not:

```powershell
Test-Path C:\WampDeck\WampDeck.exe        # False
Test-Path C:\WampDeck\www\accepttest      # True
Test-Path C:\WampDeck\data\mysql          # True
Test-Path C:\WampDeck\logs                # False
Test-Path C:\WampDeck\tmp                 # False
```

4. Install again, start the stack, and run `.\wampdeck.cmd list` plus the
   acceptance test. The project and database must come back without a manual
   import. The database marker query must still return `before`.
5. Full cleanup: uninstall, then delete `C:\WampDeck` manually.

## Scenario D - per-user install without admin

1. Sign in as a standard local user.
2. Open PowerShell in the installer folder and run:

```powershell
.\WampDeck-Setup.exe /CURRENTUSER
```

3. In the wizard change the folder to `%LOCALAPPDATA%\Programs\WampDeck`.
   A standard user cannot create `C:\WampDeck`.
4. Finish setup and start the stack. Expected limitations:

- Ports 80/443 may be free, but editing `C:\Windows\System32\drivers\etc\hosts`
  needs an administrator. `*.test` names may not resolve.
- The doctor reports a warning for the hosts file (and for SSL trust if SSL is
  enabled). This is expected for a per-user install.

5. Run the acceptance test with warnings allowed and HTTP checks for `.test`
   disabled:

```powershell
cd $env:LOCALAPPDATA\Programs\WampDeck
.\scripts\acceptance-test.cmd -AllowWarnings -SkipHttp
```

Expected: no `[FAIL]`. Confirm <http://localhost> manually. If port 80 is
blocked, use the panel Settings to switch to 8080 and test
<http://localhost:8080>.

A `[FAIL]` in this scenario is a release blocker; a hosts warning is not.

## Scenario E - port 80 already in use

1. On a clean snapshot start IIS or another listener on port 80:

```powershell
net start w3svc
```

2. Run the installer. Setup must stop with a clear message instead of leaving
   a half-configured stack. The installer's final dialog points at
   `scripts\setup.ps1`.
3. Stop the conflicting service:

```powershell
net stop w3svc
```

4. Recover without reinstalling:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\WampDeck\scripts\setup.ps1
```

5. Start the stack and run the acceptance test. `doctor` must be 23/23.
6. Alternative path: keep the other service, change the HTTP port to 8080 in
   the panel, start, and check <http://localhost:8080>. `doctor` and the
   acceptance script must follow the configured port.

## Scenario F - real projects

Run this on a **snapshot** of the developer machine that contains `blog` and
`edupro`, never on the only copy.

1. Stop the stack.
2. Capture both projects:

```powershell
cd C:\WampDeck
.\wampdeck.cmd stop
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\acceptance-test.ps1 -Projects blog,edupro -CaptureBaseline C:\acceptance\real-before.json -Deep
```

3. Install the candidate build over the existing install. Deep mode reads every file; expect several minutes for a 35k-file project.
4. Start the stack and compare:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\acceptance-test.ps1 -Projects blog,edupro -Baseline C:\acceptance\real-before.json -Deep
```

Expected: every HTTP check passes, both `preserve-*` checks pass, and file
counts are unchanged. WordPress may be slow on the first request; the doctor
allows 12 seconds per project.

## Evidence to attach

| Scenario | VM / snapshot | Windows build | Account | Result | Report | Notes |
|----------|---------------|---------------|---------|--------|--------|-------|
| A | | | Administrator | | | |
| B | | | Administrator | | | |
| C | | | Administrator | | | |
| D | | | Standard | | | |
| E | | | Administrator | | | |
| F | | | Administrator | | | |

Attach the `acceptance-*.json` reports, installer SHA-256, screenshots of
SmartScreen and the panel, and the MySQL marker query output. Sign off with the
build hash and date.

## Known limitations to expect

- The build is unsigned; SmartScreen always warns until the certificate is
  purchased and the installer is signed.
- `wampdeck restart` can hang when its output is piped or run from a
  non-interactive parent. Use the panel or an interactive terminal. This does
  not affect start/stop or the running stack.
- WordPress cold start can exceed six seconds; the doctor budget is 12 seconds.
- Per-user installs cannot sync `*.test` hostnames without administrator help.
- Downgrades are not supported. Restore the VM snapshot for a downgrade test.

## Cleanup

Keep the `clean-windows` snapshot and the scenario reports with the release.
Delete `C:\acceptance`, the test project and `acceptance_marker` only after the
sign-off is recorded.