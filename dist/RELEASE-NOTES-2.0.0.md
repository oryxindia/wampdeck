# WampDeck 2.0.0

Build #22 - 23 November 2026.

Portable PHP + Apache/Nginx + MySQL stack for Windows, with a Laragon-style terminal and a native tray panel.

This is the **first stable public release**. It is free to use and unsigned.

## Phase 1 highlights

- **PHP per project.** Pin any project to an installed PHP build and leave the rest on the stack default.
  - `wampdeck php blog 8.2`, or **PHP version** in the project right-click menu.
  - The Projects tab shows the version each project actually runs and marks pinned projects with `*`.
  - Nginx gets one upstream per build; Apache serves pinned projects through `mod_fcgid` with a per-vhost `FcgidWrapper`.
  - The stack default can change without touching pinned projects.
- **`.wampdeck.json` v1.** One small file per project: `php`, database, custom hosts, environment and post-create steps. Hand edits are preserved; unknown keys are kept.
- **`wampdeck` command line.** Short commands with compact output instead of log noise:
  - `status`, `list`, `start`, `stop`, `restart`, `open`
  - `new <name> --preset blank|wordpress|laravel`
  - `new <name> --cms <id>` and `cms list` / `cms install <id> [--name <folder>]`
  - `php <project> <version>` / `php <project> --clear`
  - `doctor [--json] [--project <name>]`, `logs <service> --tail N`
  - `snapshot`, `snapshots`, `restore`
  - `export <project> --out <zip>`, `import <zip|folder>`
  - `deploy <project> [--json]` - read-only VPS pre-flight check
  - `hosts sync`, `version`, `help`
- **`doctor`.** 23 checks over ports, generated configs, PHP pools, MySQL, manifests, document roots, databases, HTTP responses, hosts, SSL and the supervisor. A failure prints the command that fixes it. `--json` exits 1 when a check fails.
- **Database snapshots.** `mysqldump` files in `www\<project>\snapshots\`. Restore first writes `<timestamp>-before-restore.sql`, so a wrong restore is one more restore away.
- **Handoff bundle.** `export` zips the project files, a database dump and `wampdeck-bundle.json`. The manifest records the requested PHP spec (`8.2`) plus the exact build that produced the dump (`8.2.12`), so the receiving machine can use another patch release. `import` writes a fresh manifest, never copies the source `.wampdeck.json`, and keeps custom hostnames only when the project name is unchanged.
- **Nine CMS installers.** Drupal, WordPress, TYPO3, Joomla, ProcessWire, Concrete CMS, Grav, Winter CMS and Twill install into a new project from **Project - Install CMS...** or the CLI. Each recipe creates the database, writes the config, runs the installer without prompts and shows the site URL, admin URL, user and generated password once. Passwords are redacted from `logs\cms-<id>.log`.
  - The catalog order is fixed and `cms list` shows a `verified` or `experimental` status.
  - Large packages use resumable downloads and retry from the Composer cache after a failed dist download.
  - Panel project and CMS jobs use `.localhost` and never raise a UAC prompt; run **Tools - Sync hosts** for `.test` domains.
- **Worker supervisor.** Watches every `php-cgi` worker and restarts a dead one in a few seconds. A worker that is still binding its port is recognised, so a restart never leaves two `php-cgi` processes on one port. PHP's default `PHP_FCGI_MAX_REQUESTS=500` silently kills workers; WampDeck sets it to 10000.
- **opcache probe + fallback.** Some Windows PHP builds abort in CGI with "Opcode handlers are unusable due to ASLR". Each build is probed once: shared memory first, then opcache's file cache. Builds that hit the abort run with `opcache.file_cache` + `opcache.file_cache_fallback=1` (8.2.12 does), so they keep compiled-script caching instead of running with opcache off. A worker that still dies at startup is retried without opcache.
- **Hindi and contrast.** Settings - Language includes Hindi; the window title, menus, header, buttons, status texts and dialogs follow it. The menu bar and ComboBox drop-downs were rebuilt for dark mode so hover text never turns white-on-white.

## 2.0.0 stable changes

- First stable public release, free for personal and commercial local development.
- Carries every beta fix: normal-integrity panel, hosts sync at install,
  invalidated opcache probe cache, matched CMS icons, faster status polling,
  taskbar icon, website links and the worker supervisor.
- Source published at https://github.com/oryxindia/wampdeck under a
  proprietary, source-available licence. All rights remain with Oryx India.

## 2.0.0 stable changes

- First stable public release, free for personal and commercial local development.
- Carries every beta fix: normal-integrity panel, hosts sync at install,
  invalidated opcache probe cache, matched CMS icons, faster status polling,
  taskbar icon, website links and the worker supervisor.
- Source published at https://github.com/oryxindia/wampdeck under a
  proprietary, source-available licence. All rights remain with Oryx India.

## Beta.15 changes

- **Panel always runs at normal integrity.** `runasoriginaluser` proved unreliable on Windows 11: Setup is elevated, and the panel still came up elevated, so Nginx/MySQL inherited admin rights that a later normal launch could not stop. Two layers fix it now ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Â the installer launches WampDeck through Explorer (medium-integrity shell), and the launcher detects an elevated token and relaunches itself through Explorer with a loop guard. Verified: an explicit "Run as administrator" still produces a panel with `elevated=False`.
- **`.test` domains work on first install.** Setup now passes `-Hosts` to `setup.ps1`, so the managed hosts block is synced while Setup is still elevated ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Â no extra UAC prompt and no missing `wordpress.test` after a fresh install.
- **Stale opcache result can no longer persist.** The probe cache version was bumped to 3, so an old "opcache crashes" record from a previous build is discarded and the current build is re-probed. Both PHP 8.3.30 and 8.2.12 are confirmed stable with shared-memory opcache (8/8 workers, HTTP 200, no fatal errors).

## Beta.14 changes

- **Installer launches WampDeck as the normal user.** Setup runs elevated, and it used to start the panel elevated too ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Â so Nginx/MySQL inherited admin rights and a later normal launch could not stop them (the "port in use" / stuck process cases). The post-install launch now drops back to the original user. WampDeck needs no admin rights: it writes only inside its own folder (granted) and Windows allows ports 80/443/3306 without elevation.
- **Joomla and ProcessWire icon padding matched.** Both marks now sit in the same 52x52 content box as the other seven, so they no longer look larger than their neighbours.

## Beta.13 changes

- **Updated CMS icons.** New Joomla and ProcessWire marks in the header quick-launch strip.
- **Panel hang fixed.** Status polling made ~9x faster (cached process lookup and stack status), so the UI no longer freezes every few seconds.
- **Taskbar grouping fixed.** The launcher sets a WampDeck AppUserModelID, so the taskbar shows the WampDeck icon instead of "Windows PowerShell 5.1".
- **Tool fixes.** Composer now runs with WampDeck's own PHP (no more "php not recognized"); the installer shutdown helper force-stops a stuck mysqld; Nginx stop falls back to the port owner when the process path is hidden.
- (beta.12) Website links in Help menu, status bar and About dialog; header buttons aligned; Online/Offline badge in nav bar.
- (beta.11) CMS hover tooltips short and inside the window.
- (beta.9) A successful CMS install deletes its downloaded package zip.
- (beta.8) **CMS install auto-starts MySQL.** Clicking any CMS icon no longer
  stops with "The CMS install needs MySQL. Start the stack first". If MySQL is
  down, the install starts it automatically and continues, in panel and CLI.
- (beta.7) **Install file-lock fix.** CMS icons load from memory and the
  shutdown helper stops `panel.ps1`, so upgrades no longer fail with
  "DeleteFile failed; code 32".
- (beta.7) **Panel speed.** Cached `netstat` port lookup: status refresh ~0.5 s
  instead of ~4.3 s, so all buttons/menus/dialogs respond immediately.
- (beta.6) **CMS icons render correctly** via `PictureBox` + `Zoom`; header
  polished (equal-width buttons, Online/Offline badge in nav bar, taskbar icon,
  "1 service" / "6 projects" plurals).
- (beta.5) **Panel startup fix.** The `Measure-Object -Sum` cast and Graphics
  constructor bugs are fixed, so the GUI opens after install.
- (beta.4) **Deploy pre-check.** `wampdeck deploy <project>` and
  **Project ÃƒÂ¢Ã¢â‚¬Â Ã¢â‚¬â„¢ Deploy pre-check...** run a read-only VPS pre-flight check.
- (beta.3) **GUI header CMS quick-launch strip.** Nine CMS marks, one click to
  open the prefilled install dialog; installer stops the stack before copying.

## Existing features

- **Terminal, everywhere.** A real Cmder console opens in the folder you expect, with PHP, Composer, Git, Node, Python and MySQL already on `PATH`.
  - `>_ Terminal` button in the panel header
  - Stack, Tools, Project and tray menus
  - Tools tab, and each project's right-click menu (opens in that project's folder)
  - `terminal.cmd` in the install root for CLI use
- **Installer.** `WampDeck-Setup.exe` copies the stack to `C:\WampDeck`, writes the configs for the real path and initializes MySQL in one silent step.
  - `/CURRENTUSER` installs without an admin prompt.
  - Grants `Users` modify rights on the install folder, so the stack runs without admin afterwards.
  - Never ships databases, logs, backups, private SSL keys or generated configs.
- **Launcher.** One panel per install folder. A second launch restores the running window instead of starting a duplicate.
- **Multi-language UI.** Pick a language from Settings - Language (27 languages incl. Hindi). English is the fallback.

## Beta QA

- `scripts\acceptance-test.cmd` runs a read-only install check: layout, CLI JSON, stack, PHP workers, supervisor, MySQL, HTTP and project preservation across an upgrade.
- `docs\ACCEPTANCE-CLEAN-VM.md` is the release gate: clean install, reinstall, uninstall, per-user install, port-80 conflict and real-project preservation.
- `wampdeck status --json`, `list --json` and `doctor --json` now print their JSON. The launcher wrapper previously swallowed machine-readable output.

## Install

1. Run `WampDeck-Setup.exe`.
2. Approve the UAC prompt (default path `C:\WampDeck`).
3. Start WampDeck from the Start menu or the desktop shortcut.

For a per-user install with no admin prompt:

```bat
WampDeck-Setup.exe /CURRENTUSER /DIR="%LOCALAPPDATA%\WampDeck"
```

## Upgrade

Run the new installer over the existing folder. Program files are replaced; these are kept:

- `data\` - MySQL databases
- `www\` - your projects
- `logs\`, `backup\`
- `etc\ssl\` - your local CA and server certificates

## Uninstall

Settings - Apps - WampDeck, or `unins000.exe` in the install folder. The uninstaller removes program files plus `logs\` and `tmp\`; `www\`, `data\`, `etc\` and `backup\` stay on disk.

## Before you rely on `.test` domains or HTTPS

Two one-time, manually approved steps:

```bat
hosts.cmd -Sync    :: adds the WampDeck block to the Windows hosts file (UAC)
ssl.cmd -Trust     :: adds the local CA to the CurrentUser Root store (Windows dialog)
```

## Known limitations (beta)

- **This build is unsigned.** SmartScreen shows "Windows protected your PC" on first run: choose **More info - Run anyway**. The public build will be signed with an OV/EV certificate, and the UAC prompt will show **Oryx India**. Beta testers who need the publisher name can be pointed at a signed build and the Oryx India test certificate, but that is not the default download.
- The panel's project context menu uses the Windows default light background (black-on-white, readable) while the menu bar and ComboBox drop-downs are dark. Cosmetic only.
- WordPress in this environment can take several seconds per request when it checks wordpress.org; `doctor` allows 12 s per project HTTP check, so a slow site reports a failure only when it really does not answer.
- Bundled binaries were taken from an existing local Laragon install; `scripts\setup.ps1` validates them and never downloads anything.
- Windows 10/11 x64 only.

## Verify your download

```powershell
Get-FileHash .\WampDeck-Setup.exe -Algorithm SHA256
```

Compare the value with `SHA256SUMS.txt`.