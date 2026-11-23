# WampDeck

**WampDeck** is a free, portable local development stack for Windows — PHP, Apache/nginx, MySQL, Composer, Node and more, with a native tray panel and a Laragon-style terminal.

- Website: https://wampdeck.com
- Publisher: **Oryx India** — https://oryxindia.in
- Platform: Windows 10/11, x64
- Price: **Free** for download and use

## Download

Get the official release from the website. The installer is a single self-contained file; it copies the stack to C:\WampDeck and writes all configuration for the real install path.

> This repository contains **source code only**. Bundled runtimes (PHP, MySQL, nginx, Apache, Node, Python, Git) ship in the release installer, not here. A direct clone is meant for source review, not for running the app.

## What is inside

| Path | Contents |
|---|---|
| `panel.ps1` | The WinForms tray panel and GUI |
| `lib/` | Stack control, CMS installers, config generation, doctor, CLI modules |
| `scripts/` | Setup, start/stop, hosts, SSL and helper scripts |
| `installer/` | Inno Setup script and the elevated shutdown helper |
| `launcher/` | C# launcher source (AppUserModelID, single-instance, elevation drop) |
| `assets/` | Icons and images |
| `www/` | Demo and panel web content |
| `docs/` | Acceptance and QA documentation |

## Features

- Nine one-click CMS installers (Drupal, WordPress, TYPO3, Joomla, ProcessWire, Concrete CMS, Grav, Winter CMS, Twill) with credentials shown once and passwords redacted from logs.
- Per-project PHP version pinning, database snapshots, export/import bundles.
- `wampdeck` command line: `status`, `start`, `stop`, `doctor`, `cms`, `php`, `snapshot`, `deploy` and more.
- Worker supervisor that restarts dead `php-cgi` processes.
- 27 UI languages including Hindi.

## Build from source

Open a PowerShell prompt and run:

    & "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" installer\WampDeck.iss

The bundled binaries under `bin\` must be present for a successful build; they are included only in the official release package.

## Licence

**Source-available, proprietary. All rights reserved. Copyright (c) 2026 Oryx India.**

The source is visible for inspection. You may not copy, modify, fork, redistribute or build a competing product from it without written permission. The compiled application is free to use. See LICENSE for the full terms.

## Support

support@wampdeck.com · support@oryxindia.in
