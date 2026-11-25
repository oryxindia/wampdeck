<?php
declare(strict_types=1);

mysqli_report(MYSQLI_REPORT_OFF);

// ---------------------------------------------------------------- state
$root = dirname(__DIR__, 2);
$stateFile = $root . '/etc/stack.json';
$state = [];
if (is_file($stateFile)) {
    $decoded = json_decode((string) file_get_contents($stateFile), true);
    if (is_array($decoded)) {
        $state = $decoded;
    }
}

$webServer   = (string) ($state['webServer'] ?? 'nginx');
$phpVersion  = (string) ($state['phpVersion'] ?? PHP_VERSION);
$sslEnabled  = !empty($state['ssl']);
$httpPort    = (int) ($state['httpPort'] ?? 80);
$httpsPort   = (int) ($state['httpsPort'] ?? 443);
$mysqlPort   = (int) ($state['mysqlPort'] ?? 3306);
$mailpit     = !empty($state['mailpit']);
$redis       = !empty($state['redis']);
$memcached   = !empty($state['memcached']);

$isHttps = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off')
    || (int) ($_SERVER['SERVER_PORT'] ?? 0) === 443;

function deck_url(string $scheme, string $host, int $port): string
{
    $default = ($scheme === 'http' && $port === 80) || ($scheme === 'https' && $port === 443);
    return $scheme . '://' . $host . ($default ? '' : ':' . $port);
}

// ---------------------------------------------------------------- database
$dbOk = false;
$dbVersion = '';
$db = @mysqli_connect('127.0.0.1', 'root', '', '', $mysqlPort);
if ($db) {
    $dbOk = true;
    $dbVersion = mysqli_get_server_info($db);
    mysqli_close($db);
}

// ---------------------------------------------------------------- projects
$projects = [];
$www = dirname(__DIR__);
foreach (scandir($www) ?: [] as $entry) {
    if ($entry === '' || $entry[0] === '.' || $entry === 'panel') {
        continue;
    }
    $folder = $www . DIRECTORY_SEPARATOR . $entry;
    if (!is_dir($folder)) {
        continue;
    }
    $projects[] = [
        'name'   => $entry,
        'folder' => $folder,
        'public' => is_file($folder . DIRECTORY_SEPARATOR . 'public' . DIRECTORY_SEPARATOR . 'index.php'),
    ];
}
usort($projects, static fn(array $a, array $b): int => strcmp($a['name'], $b['name']));

$hasAdminer = is_file(__DIR__ . '/tools/adminer.php');
$hasInfo = is_file(__DIR__ . '/info.php');
$extensionCount = count(get_loaded_extensions());
$webLabel = $webServer === 'apache' ? 'Apache' : 'nginx';
$scheme = $isHttps ? 'https' : 'http';
?>
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>WampDeck</title>
<link rel="icon" href="data:image/svg+xml,%3Csvg xmlns=%27http://www.w3.org/2000/svg%27 viewBox=%270 0 64 64%27%3E%3Crect width=%2764%27 height=%2764%27 rx=%2714%27 fill=%27%232ee6a8%27/%3E%3Ctext x=%2732%27 y=%2742%27 font-family=%27Segoe UI,Arial%27 font-size=%2728%27 font-weight=%27bold%27 text-anchor=%27middle%27 fill=%27%230b1320%27%3EWD%3C/text%3E%3C/svg%3E">
<style>
  :root {
    color-scheme: dark;
    --bg: #080c14;
    --card: rgba(17, 24, 39, .78);
    --line: rgba(148, 163, 184, .16);
    --text: #e8eef8;
    --muted: #93a4bd;
    --accent: #6ee7b7;
    --accent2: #93c5fd;
  }
  * { box-sizing: border-box; }
  html, body { margin: 0; }
  body {
    min-height: 100vh;
    font-family: "Segoe UI", system-ui, -apple-system, sans-serif;
    color: var(--text);
    background:
      radial-gradient(900px 500px at 12% -10%, rgba(59, 130, 246, .22), transparent 60%),
      radial-gradient(700px 420px at 92% 8%, rgba(16, 185, 129, .16), transparent 55%),
      var(--bg);
  }
  .wrap { width: min(1120px, 92vw); margin: 0 auto; padding: 56px 0 48px; }
  header { display: flex; align-items: flex-end; justify-content: space-between; gap: 24px; flex-wrap: wrap; margin-bottom: 34px; }
  .brand { display: flex; align-items: center; gap: 14px; }
  .logo {
    width: 46px; height: 46px; border-radius: 14px; display: grid; place-items: center;
    background: linear-gradient(135deg, #34d399, #3b82f6);
    color: #04121a; font-weight: 800; font-size: 18px; letter-spacing: -.06em;
    box-shadow: 0 12px 30px rgba(52, 211, 153, .25);
  }
  h1 { margin: 0; font-size: 26px; letter-spacing: -.02em; }
  .sub { margin: 3px 0 0; color: var(--muted); font-size: 13px; }
  .badge {
    display: inline-flex; align-items: center; gap: 8px;
    padding: 8px 14px; border-radius: 999px; font: 600 12px/1 ui-monospace, monospace;
    letter-spacing: .08em; text-transform: uppercase;
    border: 1px solid var(--line); background: rgba(15, 23, 42, .6);
  }
  .dot { width: 8px; height: 8px; border-radius: 50%; background: var(--accent); box-shadow: 0 0 12px var(--accent); }
  .dot.off { background: #f87171; box-shadow: 0 0 12px #f87171; }

  .cards { display: grid; grid-template-columns: repeat(4, 1fr); gap: 14px; margin-bottom: 34px; }
  .card {
    padding: 20px; border-radius: 16px; border: 1px solid var(--line);
    background: var(--card); backdrop-filter: blur(10px);
  }
  .card span { display: block; color: var(--muted); font-size: 11px; letter-spacing: .12em; text-transform: uppercase; margin-bottom: 10px; }
  .card b { font-size: 17px; font-weight: 650; letter-spacing: -.01em; }
  .card small { display: block; margin-top: 6px; color: var(--muted); font-size: 12px; overflow-wrap: anywhere; }
  .ok { color: var(--accent); } .off { color: #fca5a5; }

  h2 { font-size: 13px; letter-spacing: .14em; text-transform: uppercase; color: var(--muted); margin: 0 0 14px; }
  .projects { display: grid; grid-template-columns: repeat(auto-fill, minmax(270px, 1fr)); gap: 12px; margin-bottom: 34px; }
  .project {
    display: flex; align-items: center; gap: 14px; padding: 16px 18px;
    border: 1px solid var(--line); border-radius: 14px;
    background: rgba(15, 23, 42, .55);
  }
  .project:hover { border-color: rgba(110, 231, 183, .35); }
  .avatar {
    width: 38px; height: 38px; border-radius: 11px; display: grid; place-items: center; flex: none;
    background: rgba(147, 197, 253, .14); color: var(--accent2); font-weight: 700; text-transform: uppercase;
  }
  .project b { display: block; font-size: 15px; }
  .links { display: flex; flex-wrap: wrap; gap: 10px; margin-top: 5px; }
  .links a { color: var(--muted); font-size: 12px; text-decoration: none; }
  .links a:hover { color: var(--accent); }
  .tag { font-size: 10px; letter-spacing: .08em; text-transform: uppercase; color: #c4b5fd; }
  .empty {
    padding: 22px; border: 1px dashed var(--line); border-radius: 14px; color: var(--muted);
    font-size: 14px; line-height: 1.6;
  }
  code { font-family: ui-monospace, "Cascadia Code", monospace; color: #c4b5fd; background: rgba(196, 181, 253, .1); padding: 2px 6px; border-radius: 6px; }

  .quick { display: flex; flex-wrap: wrap; gap: 10px; }
  .quick a {
    padding: 10px 16px; border-radius: 10px; text-decoration: none; font-size: 13px; font-weight: 600;
    color: #dbeafe; border: 1px solid var(--line); background: rgba(15, 23, 42, .55);
  }
  .quick a:hover { border-color: rgba(147, 197, 253, .5); background: rgba(30, 41, 59, .7); }
  .quick a.off { color: #64748b; pointer-events: none; opacity: .6; }

  .services { display: flex; flex-wrap: wrap; gap: 10px; margin-bottom: 34px; }
  .service {
    display: inline-flex; align-items: center; gap: 8px; padding: 8px 12px; border-radius: 999px;
    border: 1px solid var(--line); background: rgba(15, 23, 42, .55); font-size: 12px; color: var(--muted);
  }
  .service .pulse { width: 7px; height: 7px; border-radius: 50%; background: #475569; }
  .service.on { color: var(--text); }
  .service.on .pulse { background: var(--accent); box-shadow: 0 0 10px var(--accent); }

  footer { margin-top: 40px; color: #64748b; font-size: 12px; display: flex; justify-content: space-between; flex-wrap: wrap; gap: 8px; }
  @media (max-width: 760px) { .cards { grid-template-columns: repeat(2, 1fr); } .wrap { padding-top: 36px; } }
</style>
</head>
<body>
<div class="wrap">
  <header>
    <div class="brand">
      <div class="logo">WD</div>
      <div>
        <h1>WampDeck</h1>
        <p class="sub">PHP <?= htmlspecialchars($phpVersion) ?> &middot; <?= htmlspecialchars($webLabel) ?> &middot; MySQL &middot; Windows</p>
      </div>
    </div>
    <div class="badge"><span class="dot <?= $dbOk ? '' : 'off' ?>"></span><?= $dbOk ? 'stack online' : 'database offline' ?></div>
  </header>

  <section class="cards">
    <div class="card"><span>PHP</span><b><?= htmlspecialchars($phpVersion) ?></b><small><?= htmlspecialchars(PHP_SAPI) ?>, <?= $extensionCount ?> extensions</small></div>
    <div class="card"><span>Web server</span><b><?= htmlspecialchars($webLabel) ?></b><small>port <?= $isHttps ? (int) $httpsPort : (int) $httpPort ?><?= $isHttps ? ', HTTPS' : ', HTTP' ?></small></div>
    <div class="card"><span>Database</span><b class="<?= $dbOk ? 'ok' : 'off' ?>"><?= $dbOk ? 'connected' : 'offline' ?></b><small><?= $dbOk ? 'MySQL ' . htmlspecialchars($dbVersion) : 'start the stack' ?> &middot; port <?= $mysqlPort ?></small></div>
    <div class="card"><span>Projects</span><b><?= count($projects) ?> project<?= count($projects) === 1 ? '' : 's' ?></b><small><?= htmlspecialchars(str_replace('/', '\\', $www)) ?></small></div>
  </section>

  <section>
    <h2>Services</h2>
    <div class="services">
      <span class="service on"><span class="pulse"></span><?= htmlspecialchars($webLabel) ?> :<?= $isHttps ? (int) $httpsPort : (int) $httpPort ?></span>
      <span class="service <?= $dbOk ? 'on' : '' ?>"><span class="pulse"></span>MySQL :<?= $mysqlPort ?></span>
      <span class="service <?= $mailpit ? 'on' : '' ?>"><span class="pulse"></span>Mailpit <?= $mailpit ? ':1025 / :8025' : '(off)' ?></span>
      <span class="service <?= $redis ? 'on' : '' ?>"><span class="pulse"></span>Redis <?= $redis ? ':6379' : '(off)' ?></span>
      <span class="service <?= $memcached ? 'on' : '' ?>"><span class="pulse"></span>Memcached <?= $memcached ? ':11211' : '(off)' ?></span>
      <span class="service <?= $sslEnabled ? 'on' : '' ?>"><span class="pulse"></span>SSL <?= $sslEnabled ? 'on' : 'off' ?></span>
    </div>
  </section>

  <section>
    <h2>Projects</h2>
    <div class="projects">
      <?php if ($projects === []): ?>
        <div class="empty">No projects yet. Create one from the tray panel,<br>or run <code>.\new.cmd myapp</code>, or drop a folder into <code>www\</code>.</div>
      <?php else: ?>
        <?php foreach ($projects as $project): ?>
          <?php
            $name = $project['name'];
            $local = deck_url($scheme, $name . '.localhost', $isHttps ? $httpsPort : $httpPort);
            $host = $name . '.test';
            $test = deck_url($scheme, $host, $isHttps ? $httpsPort : $httpPort);
            $https = deck_url('https', $host, $httpsPort);
          ?>
          <div class="project">
            <span class="avatar"><?= htmlspecialchars(strtoupper(substr($name, 0, 1))) ?></span>
            <span>
              <b><?= htmlspecialchars($name) ?></b>
              <span class="links">
                <a href="<?= htmlspecialchars($local) ?>"><?= htmlspecialchars($name) ?>.localhost</a>
                <a href="<?= htmlspecialchars($test) ?>"><?= htmlspecialchars($name) ?>.test</a>
                <?php if ($sslEnabled && !$isHttps): ?><a href="<?= htmlspecialchars($https) ?>">https</a><?php endif; ?>
                <?php if ($project['public']): ?><span class="tag">public/</span><?php endif; ?>
              </span>
            </span>
          </div>
        <?php endforeach; ?>
      <?php endif; ?>
    </div>
  </section>

  <section>
    <h2>Tools</h2>
    <div class="quick">
      <?php if ($hasAdminer): ?><a href="tools/adminer.php">Adminer (database)</a><?php endif; ?>
      <?php if ($hasInfo): ?><a href="info.php">PHP info</a><?php endif; ?>
      <?php if ($mailpit): ?><a href="http://127.0.0.1:8025">Mailpit inbox</a><?php endif; ?>
      <a href="<?= htmlspecialchars(deck_url($scheme, 'localhost', $isHttps ? $httpsPort : $httpPort)) ?>">Reload panel</a>
      <a href="<?= htmlspecialchars($scheme === 'https' ? deck_url('http', 'localhost', $httpPort) : deck_url('https', 'localhost', $httpsPort)) ?>" class="<?= $sslEnabled ? '' : 'off' ?>">Switch to <?= $scheme === 'https' ? 'HTTP' : 'HTTPS' ?></a>
    </div>
  </section>

  <footer>
    <span>WampDeck &middot; portable PHP stack &middot; right-click the tray icon for HeidiSQL, ngrok and more</span>
    <span><?= htmlspecialchars(date('D, d M Y H:i')) ?></span>
  </footer>
</div>
</body>
</html>
