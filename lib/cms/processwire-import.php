<?php
/**
 * Imports the ProcessWire core schema and site profile with the same merge
 * rules as ProcessWire's own installer.
 *
 * Importing the two dumps one after the other with the mysql client wipes
 * rows that only exist in the core dump (for example the guest user role),
 * because the site profile dump recreates the shared field tables. The
 * official installer merges both files instead.
 *
 * Arguments:
 *   1 target directory
 *   2 database name
 *   3 database port
 */

namespace ProcessWire;

if (PHP_SAPI !== 'cli') {
    fwrite(STDERR, "This importer must run from the command line.\n");
    exit(1);
}

$target = isset($argv[1]) ? rtrim($argv[1], "\\/") : '';
$dbName = isset($argv[2]) ? $argv[2] : '';
$dbPort = isset($argv[3]) ? $argv[3] : '3306';

if ($target === '' || !is_dir($target) || $dbName === '') {
    fwrite(STDERR, "Target directory and database name are required.\n");
    exit(1);
}

$coreSql = $target . '/wire/core/install.sql';
$siteSql = $target . '/site/install/install.sql';
if (!is_file($coreSql) || !is_file($siteSql)) {
    fwrite(STDERR, "ProcessWire install SQL was not found.\n");
    exit(1);
}

$backupDir = $target . '/site/assets/backups';
if (!is_dir($backupDir)) {
    mkdir($backupDir, 0755, true);
}

require $target . '/wire/core/WireDatabaseBackup.php';

$dsn = "mysql:host=127.0.0.1;port=$dbPort;dbname=$dbName;charset=utf8mb4";
$pdo = new \PDO($dsn, 'root', '', array(
    \PDO::ATTR_ERRMODE => \PDO::ERRMODE_EXCEPTION,
    \PDO::ATTR_DEFAULT_FETCH_MODE => \PDO::FETCH_ASSOC,
));

$backup = new WireDatabaseBackup($backupDir);
$backup->setDatabase($pdo);

$options = array(
    'allowDrop' => true,
    'haltOnError' => true,
);

if (!$backup->restoreMerge($coreSql, $siteSql, $options)) {
    $errors = $backup->errors();
    fwrite(STDERR, "ProcessWire database import failed.\n" . implode("\n", $errors) . "\n");
    exit(1);
}

echo "ProcessWire database imported.\n";
