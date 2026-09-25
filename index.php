<?php

declare(strict_types=1);

$base = str_replace('\\', '/', dirname($_SERVER['SCRIPT_NAME'] ?? ''));
$base = rtrim($base, '/');
if ($base === '/' || $base === '.') {
    $base = '';
}

header('Location: '.$base.'/backend/public/', true, 302);
header('Cache-Control: no-store');
exit;
