<?php
/**
 * Silent ProcessWire installer used by WampDeck.
 *
 * WampDeck has already copied site-blank to site/, written the database
 * settings and imported wire/core/install.sql plus site/install/install.sql.
 * This script boots ProcessWire and sets the superuser credentials.
 *
 * Arguments:
 *   1 target directory
 *   2 site URL
 *   3 admin user
 *   4 admin email
 *   5 admin password
 */

namespace ProcessWire;

if (PHP_SAPI !== 'cli') {
    fwrite(STDERR, "This installer must run from the command line.\n");
    exit(1);
}

$wampTarget   = isset($argv[1]) ? rtrim($argv[1], "\\/") : '';
$wampUrl      = isset($argv[2]) ? rtrim($argv[2], '/') : 'http://localhost';
$wampUser     = isset($argv[3]) ? $argv[3] : 'admin';
$wampEmail    = isset($argv[4]) ? $argv[4] : 'admin@example.com';
$wampPassword = isset($argv[5]) ? $argv[5] : '';

if ($wampTarget === '' || !is_dir($wampTarget)) {
    fwrite(STDERR, "Target directory was not found: $wampTarget\n");
    exit(1);
}
if ($wampPassword === '') {
    fwrite(STDERR, "An admin password is required.\n");
    exit(1);
}

$host = parse_url($wampUrl, PHP_URL_HOST);
if (!$host) {
    $host = 'localhost';
}

$_SERVER['HTTP_HOST']   = $host;
$_SERVER['SERVER_NAME'] = $host;
$_SERVER['SERVER_PORT'] = '80';
$_SERVER['REQUEST_URI'] = '/';
$_SERVER['SCRIPT_NAME'] = '/index.php';
$_SERVER['PHP_SELF']    = '/index.php';

chdir($wampTarget);

ob_start();
require $wampTarget . '/index.php';
ob_end_clean();

if (!isset($wire) || !($wire instanceof ProcessWire)) {
    fwrite(STDERR, "ProcessWire bootstrap failed.\n");
    exit(1);
}

$users = $wire->users;
$userPage = $users->get($wire->config->superUserPageID);
if (!$userPage || !$userPage->id) {
    $userPage = $users->add($wampUser);
}
if (!$userPage || !$userPage->id) {
    fwrite(STDERR, "Could not find or create the ProcessWire superuser.\n");
    exit(1);
}

$userPage->of(false);
$userPage->name  = $wampUser;
$userPage->email = $wampEmail;
$userPage->pass  = $wampPassword;
$userPage->save();

$role = $wire->roles->get('superuser');
if ($role && $role->id && !$userPage->roles->has($role)) {
    $userPage->roles->add($role);
    $userPage->save();
}

echo "ProcessWire superuser ready: " . $userPage->name . "\n";
