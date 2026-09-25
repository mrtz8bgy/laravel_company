<?php

namespace Tests\Unit;

use App\Core\Support\MysqlLocalSetup;
use PHPUnit\Framework\TestCase;

class MysqlLocalSetupTest extends TestCase
{
    public function test_sql_filename_is_not_used_as_database_name(): void
    {
        $this->assertSame('virtual_company', MysqlLocalSetup::databaseName('virtual-company-os-mysql.sql'));
        $this->assertSame('virtual_company', MysqlLocalSetup::databaseName(''));
        $this->assertSame('company_db', MysqlLocalSetup::databaseName('company_db'));
    }

    public function test_import_file_splits_into_executable_statements(): void
    {
        $sql = (string) file_get_contents(dirname(__DIR__, 2).'/database/sql/mysql/virtual-company-os.sql');
        $statements = MysqlLocalSetup::statements($sql);

        $this->assertNotEmpty($statements);
        $this->assertStringStartsWith('SET NAMES', $statements[0]);
        $joined = implode("\n", $statements);
        $this->assertStringContainsString('CREATE TABLE `users`', $joined);
        $this->assertStringContainsString('CREATE TABLE `sessions`', $joined);
    }
}
