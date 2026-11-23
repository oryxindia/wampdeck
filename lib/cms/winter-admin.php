<?php
/**
 * Updates the Winter CMS backend superuser seeded by winter:up.
 *
 * Arguments:
 *   1 target directory
 *   2 admin login (usually "admin")
 *   3 admin email
 *   4 admin password
 */

if (PHP_SAPI !== 'cli') {
    fwrite(STDERR, "This installer must run from the command line.\n");
    exit(1);
}

$target   = isset($argv[1]) ? rtrim($argv[1], "\\/") : '';
$login    = isset($argv[2]) ? $argv[2] : 'admin';
$email    = isset($argv[3]) ? $argv[3] : 'admin@example.com';
$password = isset($argv[4]) ? $argv[4] : '';

if ($target === '' || !is_dir($target)) {
    fwrite(STDERR, "Target directory was not found: $target\n");
    exit(1);
}
if ($password === '') {
    fwrite(STDERR, "An admin password is required.\n");
    exit(1);
}

chdir($target);
require $target . '/vendor/autoload.php';

$app = require $target . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$user = \Backend\Models\User::where('login', $login)->orWhere('email', $login)->first();
if (!$user) {
    // winter:up seeds the first backend account with the login "admin".
    $user = \Backend\Models\User::where('is_superuser', true)->orderBy('id')->first();
}
if (!$user) {
    $user = \Backend\Models\User::orderBy('id')->first();
}
if (!$user) {
    fwrite(STDERR, "No Winter backend user was found.\n");
    exit(1);
}

if (!$user->role_id) {
    $role = \Backend\Models\UserRole::where('code', 'developer')->first();
    if (!$role) {
        $role = \Backend\Models\UserRole::orderBy('id')->first();
    }
    if ($role) {
        $user->role_id = $role->id;
    }
}

$user->login = $login;
$user->email = $email;
$user->password = $password;
$user->password_confirmation = $password;
$user->is_activated = true;
$user->is_superuser = true;
$user->save();

echo "Winter admin ready: " . $user->login . "\n";
