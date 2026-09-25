<?php

declare(strict_types=1);

$root = dirname(__DIR__);
$source = $root.'/resources/exceptions-renderer';
$dist = $root.'/vendor/laravel/framework/src/Illuminate/Foundation/resources/exceptions/renderer/dist';

if (! is_dir($source)) {
    fwrite(STDOUT, "Exception renderer assets are not bundled.\n");
    exit(0);
}

if (! is_dir($dist) && ! mkdir($dist, 0775, true) && ! is_dir($dist)) {
    fwrite(STDERR, "Cannot create {$dist}\n");
    exit(1);
}

foreach (['styles.css', 'scripts.js'] as $file) {
    $target = $dist.'/'.$file;
    if (! is_file($target)) {
        copy($source.'/'.$file, $target);
    }
}

fwrite(STDOUT, "Exception renderer assets are in place.\n");
