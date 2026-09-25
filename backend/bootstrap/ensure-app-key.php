<?php

/**
 * Laravel refuses to boot when APP_KEY is empty. On a fresh XAMPP copy the
 * key is often missing, so create one and keep it in .env before the app starts.
 */

$existing = getenv('APP_KEY');
if (! is_string($existing) || $existing === '') {
    $existing = $_ENV['APP_KEY'] ?? $_SERVER['APP_KEY'] ?? '';
}
if (is_string($existing) && $existing !== '') {
    return;
}

$root = dirname(__DIR__);
$envFile = $root.DIRECTORY_SEPARATOR.'.env';
$example = $root.DIRECTORY_SEPARATOR.'.env.example';

if (! is_file($envFile) && is_file($example)) {
    copy($example, $envFile);
}

$key = 'base64:'.base64_encode(random_bytes(32));
$contents = is_file($envFile) ? file_get_contents($envFile) : false;

if ($contents === false) {
    $contents = "APP_KEY={$key}\n";
} elseif (preg_match('/^APP_KEY=(.*)$/m', $contents, $match) === 1) {
    $current = trim($match[1], " \t\"'");
    if ($current !== '') {
        $key = $current;
    } else {
        $contents = preg_replace('/^APP_KEY=.*$/m', 'APP_KEY='.$key, $contents, 1);
    }
} else {
    $contents = "APP_KEY={$key}\n".$contents;
}

if (is_string($contents) && (! is_file($envFile) || file_get_contents($envFile) !== $contents)) {
    file_put_contents($envFile, $contents);
    $cachedConfig = $root.DIRECTORY_SEPARATOR.'bootstrap'.DIRECTORY_SEPARATOR.'cache'.DIRECTORY_SEPARATOR.'config.php';
    if (is_file($cachedConfig)) {
        unlink($cachedConfig);
    }
}

putenv('APP_KEY='.$key);
$_ENV['APP_KEY'] = $key;
$_SERVER['APP_KEY'] = $key;
