<?php

declare(strict_types=1);

namespace App\Core\Support;

use Illuminate\Support\Facades\DB;
use PDO;
use RuntimeException;
use Throwable;

/**
 * A .sql filename is an import file, not a MySQL database name.
 * On a local XAMPP install, create virtual_company and load the bundled dump.
 */
final class MysqlLocalSetup
{
    public const DATABASE = 'virtual_company';

    public static function ensure(): void
    {
        if (! app()->environment('local') || config('database.default') !== 'mysql') {
            return;
        }

        $configured = (string) config('database.connections.mysql.database');
        $target = self::databaseName($configured);
        if ($configured !== $target) {
            self::persistDatabaseName($target);
        }

        if (self::hasUsersTable($target)) {
            return;
        }

        self::createAndImport($target);
        self::persistDatabaseName($target);
        DB::purge('mysql');
    }

    public static function databaseName(string $configured): string
    {
        $name = trim($configured, " \t\"'");
        if ($name === '' || preg_match('/\.sql$/i', $name) === 1) {
            return self::DATABASE;
        }

        return $name;
    }

    /**
     * @return list<string>
     */
    public static function statements(string $sql): array
    {
        $statements = [];
        $buffer = '';
        $inString = false;
        $escape = false;
        $length = strlen($sql);

        for ($i = 0; $i < $length; $i++) {
            $char = $sql[$i];
            if ($inString) {
                $buffer .= $char;
                if ($escape) {
                    $escape = false;
                    continue;
                }
                if ($char === '\\') {
                    $escape = true;
                    continue;
                }
                if ($char === "'") {
                    $inString = false;
                }
                continue;
            }
            if ($char === "'") {
                $inString = true;
                $buffer .= $char;
                continue;
            }
            if ($char === ';') {
                $statement = self::withoutLeadingComments($buffer);
                if ($statement !== '') {
                    $statements[] = $statement;
                }
                $buffer = '';
                continue;
            }
            $buffer .= $char;
        }

        $tail = self::withoutLeadingComments($buffer);
        if ($tail !== '') {
            $statements[] = $tail;
        }

        return $statements;
    }

    private static function withoutLeadingComments(string $statement): string
    {
        $lines = preg_split("/\r\n|\n|\r/", $statement) ?: [];
        while ($lines !== [] && (trim((string) $lines[0]) === '' || str_starts_with(trim((string) $lines[0]), '--'))) {
            array_shift($lines);
        }

        return trim(implode("\n", $lines));
    }

    private static function hasUsersTable(string $database): bool
    {
        try {
            $pdo = self::pdo($database);

            return (bool) $pdo->query("SHOW TABLES LIKE 'users'")->fetch();
        } catch (Throwable) {
            return false;
        }
    }

    private static function createAndImport(string $database): void
    {
        if (! preg_match('/^[A-Za-z0-9_]+$/', $database)) {
            throw new RuntimeException('نام دیتابیس MySQL باید فقط حرف، عدد و زیرخط باشد. فایل .sql را به‌عنوان نام دیتابیس نگذارید.');
        }

        $server = self::pdo(null);
        $server->exec(
            'CREATE DATABASE IF NOT EXISTS `'.$database.'` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci'
        );

        $path = base_path('database/sql/mysql/virtual-company-os.sql');
        if (! is_file($path)) {
            throw new RuntimeException('فایل ایمپورت MySQL پیدا نشد: database/sql/mysql/virtual-company-os.sql');
        }

        $pdo = self::pdo($database);
        foreach (self::statements((string) file_get_contents($path)) as $statement) {
            $pdo->exec($statement);
        }
    }

    private static function pdo(?string $database): PDO
    {
        $host = (string) config('database.connections.mysql.host', '127.0.0.1');
        $port = (string) config('database.connections.mysql.port', '3306');
        $username = (string) config('database.connections.mysql.username', 'root');
        $password = (string) config('database.connections.mysql.password', '');
        $dsn = 'mysql:host='.$host.';port='.$port.';charset=utf8mb4';
        if ($database !== null) {
            $dsn .= ';dbname='.$database;
        }

        return new PDO($dsn, $username, $password, [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        ]);
    }

    private static function persistDatabaseName(string $database): void
    {
        config(['database.connections.mysql.database' => $database]);
        $file = base_path('.env');
        if (! is_file($file)) {
            return;
        }
        $contents = (string) file_get_contents($file);
        if (preg_match('/^DB_DATABASE=.*$/m', $contents) === 1) {
            $contents = (string) preg_replace('/^DB_DATABASE=.*$/m', 'DB_DATABASE='.$database, $contents, 1);
        } else {
            $contents .= "\nDB_DATABASE={$database}\n";
        }
        file_put_contents($file, $contents);
        $cached = base_path('bootstrap/cache/config.php');
        if (is_file($cached)) {
            unlink($cached);
        }
    }
}
