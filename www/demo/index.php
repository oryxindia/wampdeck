<?php
$dbOk = false;
$dbVersion = '';
if (function_exists('mysqli_connect')) {
    $db = @mysqli_connect('127.0.0.1', 'root', '', '', 3306);
    if ($db) {
        $dbOk = true;
        $dbVersion = mysqli_get_server_info($db);
        mysqli_close($db);
    }
}
?>
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>demo - WampDeck</title>
<style>
  :root { color-scheme: dark; }
  * { box-sizing: border-box; }
  body {
    margin: 0; min-height: 100vh; display: grid; place-items: center;
    font-family: "Segoe UI", system-ui, sans-serif;
    background: radial-gradient(circle at 20% 10%, #1b2a4a, #0a0f18 55%);
    color: #e6edf7;
  }
  .card {
    width: min(640px, 92vw); padding: 40px; border-radius: 20px;
    background: rgba(17, 24, 39, .82); border: 1px solid rgba(148, 163, 184, .18);
    box-shadow: 0 30px 80px rgba(0, 0, 0, .45);
  }
  .tag { font: 600 12px/1 ui-monospace, monospace; letter-spacing: .18em; text-transform: uppercase; color: #6ee7b7; }
  h1 { margin: 14px 0 8px; font-size: 38px; letter-spacing: -.02em; }
  p { color: #9fb0c8; line-height: 1.6; margin: 0 0 26px; }
  .grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px; margin-bottom: 26px; }
  .cell { padding: 14px; border-radius: 12px; background: rgba(148, 163, 184, .08); }
  .cell span { display: block; font-size: 11px; letter-spacing: .1em; text-transform: uppercase; color: #7c8da6; margin-bottom: 6px; }
  .cell b { font-size: 15px; font-weight: 600; }
  .ok { color: #6ee7b7; } .bad { color: #fca5a5; }
  a { color: #93c5fd; text-decoration: none; }
  a:hover { text-decoration: underline; }
  code { font-family: ui-monospace, monospace; color: #c4b5fd; }
</style>
</head>
<body>
  <main class="card">
    <div class="tag">WampDeck project</div>
    <h1>demo</h1>
    <p>This folder is served at <code>http://demo.localhost</code>. Drop your PHP files here or replace this page.</p>
    <div class="grid">
      <div class="cell"><span>PHP</span><b><?= htmlspecialchars(PHP_VERSION) ?></b></div>
      <div class="cell"><span>Database</span><b class="<?= $dbOk ? 'ok' : 'bad' ?>"><?= $dbOk ? 'connected' : 'offline' ?></b></div>
      <div class="cell"><span>MySQL</span><b><?= $dbOk ? htmlspecialchars($dbVersion) : '-' ?></b></div>
    </div>
    <p><a href="http://localhost/">&larr; Back to the panel</a></p>
  </main>
</body>
</html>