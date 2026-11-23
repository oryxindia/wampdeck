<?php
/**
 * Silent WordPress installer used by WampDeck.
 *
 * Arguments:
 *   1 target directory
 *   2 site title
 *   3 admin user
 *   4 admin email
 *   5 admin password
 *   6 site URL
 */

if (PHP_SAPI !== 'cli') {
    fwrite(STDERR, "This installer must run from the command line.\n");
    exit(1);
}

$target   = isset($argv[1]) ? rtrim($argv[1], "\\/") : '';
$title    = isset($argv[2]) ? $argv[2] : 'WordPress';
$user     = isset($argv[3]) ? $argv[3] : 'admin';
$email    = isset($argv[4]) ? $argv[4] : 'admin@example.com';
$password = isset($argv[5]) ? $argv[5] : '';
$url      = isset($argv[6]) ? rtrim($argv[6], '/') : 'http://localhost';

if ($target === '' || !is_dir($target)) {
    fwrite(STDERR, "Target directory was not found: $target\n");
    exit(1);
}
if ($password === '') {
    fwrite(STDERR, "An admin password is required.\n");
    exit(1);
}

$host = parse_url($url, PHP_URL_HOST);
if (!$host) {
    $host = 'localhost';
}

$_SERVER['HTTP_HOST']   = $host;
$_SERVER['SERVER_NAME'] = $host;
$_SERVER['SERVER_PORT'] = '80';
$_SERVER['REQUEST_URI'] = '/';
$_SERVER['SCRIPT_NAME'] = '/index.php';
$_SERVER['PHP_SELF']    = '/index.php';

if (!defined('WP_HOME'))    define('WP_HOME', $url);
if (!defined('WP_SITEURL')) define('WP_SITEURL', $url);
if (!defined('WP_INSTALLING')) define('WP_INSTALLING', true);

chdir($target);

require $target . '/wp-load.php';
require_once ABSPATH . 'wp-admin/includes/upgrade.php';

if (is_blog_installed()) {
    fwrite(STDERR, "WordPress is already installed in $target.\n");
    exit(2);
}

$result = wp_install($title, $user, $email, true, '', $password);
if (is_wp_error($result)) {
    fwrite(STDERR, "wp_install() failed: " . $result->get_error_message() . "\n");
    exit(1);
}

update_option('siteurl', $url);
update_option('home', $url);
update_option('blogname', $title);

echo "WordPress installed. admin user_id=" . (int) $result['user_id'] . "\n";
