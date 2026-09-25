#!/usr/bin/env python3
"""Export the local SQLite database as one MySQL/MariaDB import file."""

from __future__ import annotations

import json
import shutil
import sqlite3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SQLITE = ROOT / "database" / "database.sqlite"
OUT = Path(__file__).resolve().parent / "mysql" / "virtual-company-os.sql"
DOWNLOAD = ROOT.parent / "virtual-company-os-mysql.sql"

SKIP_DATA = {
    "personal_access_tokens",
    "sessions",
    "cache",
    "cache_locks",
    "jobs",
    "job_batches",
    "failed_jobs",
    "login_sessions",
    "password_reset_tokens",
}

JSON_COLUMNS = {
    "companies": {"settings"},
    "activity_logs": {"old_values", "new_values"},
    "personal_access_tokens": {"abilities"},
    "settings": {"value"},
}

MONEY = {"amount", "salary_amount", "budget_amount"}

SEED_ORDER = [
    "migrations",
    "users",
    "permissions",
    "companies",
    "departments",
    "company_user",
    "teams",
    "team_user",
    "roles",
    "role_permissions",
    "user_roles",
    "user_permissions",
    "work_schedules",
    "features",
    "settings",
    "invitations",
    "projects",
    "project_members",
    "kanban_columns",
    "tasks",
    "task_comments",
    "hr_profiles",
    "leave_requests",
    "mission_requests",
    "channels",
    "channel_members",
    "messages",
    "announcements",
    "events",
    "crm_accounts",
    "crm_contacts",
    "crm_deals",
    "campaigns",
    "invoices",
    "expenses",
    "tickets",
    "ticket_messages",
    "approvals",
    "documents",
    "customers",
    "products",
    "customer_orders",
    "customer_order_items",
    "customer_threads",
    "customer_thread_messages",
    "customer_tickets",
    "customer_ticket_messages",
    "attendance_days",
    "attendance_events",
    "work_presences",
    "daily_reports",
    "activity_logs",
]


def q(name: str) -> str:
    return "`" + name.replace("`", "``") + "`"


def clean_default(raw: str) -> str:
    value = raw.strip()
    while value.startswith("(") and value.endswith(")"):
        value = value[1:-1].strip()
    if len(value) >= 2 and value[0] == value[-1] and value[0] in {"'", '"'}:
        value = value[1:-1].replace("''", "'")
    return value


def sql_string(value: str) -> str:
    escaped = (
        value.replace("\\", "\\\\")
        .replace("'", "\\'")
        .replace("\0", "\\0")
        .replace("\n", "\\n")
        .replace("\r", "\\r")
    )
    return "'" + escaped + "'"


def column_type(table: str, column: dict) -> str:
    name = column["name"]
    raw = (column["type"] or "").lower()
    if name in JSON_COLUMNS.get(table, set()):
        return "JSON"
    if "tinyint(1)" in raw or name in {"is_owner", "is_active", "is_system", "is_platform_admin", "is_working_day", "is_done", "excused", "enabled"}:
        return "TINYINT(1)"
    if name in MONEY or raw == "numeric":
        return "DECIMAL(14,0)"
    if raw == "date":
        return "DATE"
    if raw == "time":
        return "TIME"
    if "datetime" in raw or "timestamp" in raw:
        return "DATETIME"
    if "int" in raw:
        return "BIGINT UNSIGNED"
    if "text" in raw or "clob" in raw:
        return "LONGTEXT"
    return "VARCHAR(191)"


def default_sql(column: dict, mysql_type: str) -> str | None:
    if column["dflt_value"] is None:
        return None
    value = clean_default(str(column["dflt_value"]))
    if value.upper() == "CURRENT_TIMESTAMP":
        return "CURRENT_TIMESTAMP"
    if value.upper() == "NULL":
        return "NULL"
    if mysql_type == "TINYINT(1)":
        return "1" if value in {"1", "true", "TRUE"} else "0"
    if mysql_type.startswith("BIGINT") or mysql_type.startswith("DECIMAL"):
        return str(int(float(value)))
    if mysql_type == "TIME":
        if len(value) == 5:
            value += ":00"
        return sql_string(value)
    if mysql_type == "JSON":
        return sql_string(value)
    return sql_string(value)


def literal(value, mysql_type: str, json_column: bool) -> str:
    if value is None:
        return "NULL"
    if mysql_type == "TINYINT(1)":
        return "1" if str(value) in {"1", "true", "True"} else "0"
    if mysql_type.startswith("BIGINT"):
        return str(int(value))
    if mysql_type.startswith("DECIMAL"):
        return str(int(float(value)))
    text = str(value)
    if mysql_type == "TIME" and len(text) == 5:
        text += ":00"
    if json_column and text != "":
        json.loads(text)
    return sql_string(text)


def main() -> None:
    db = sqlite3.connect(SQLITE)
    db.row_factory = sqlite3.Row
    tables = [
        row[0]
        for row in db.execute(
            "SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%' ORDER BY name"
        )
    ]
    info = {
        table: [dict(row) for row in db.execute(f"PRAGMA table_info({q_sqlite(table)})")]
        for table in tables
    }

    lines: list[str] = []
    lines.extend(header(db))
    lines.append("SET NAMES utf8mb4;")
    lines.append("SET time_zone = '+00:00';")
    lines.append("SET sql_mode = 'NO_ENGINE_SUBSTITUTION';")
    lines.append("SET FOREIGN_KEY_CHECKS = 0;")
    lines.append("SET UNIQUE_CHECKS = 0;")
    lines.append("")

    for table in tables:
        lines.append(f"DROP TABLE IF EXISTS {q(table)};")
    lines.append("")

    for table in tables:
        lines.extend(create_table(table, info[table]))
        lines.append("")

    ordered = [table for table in SEED_ORDER if table in tables]
    ordered.extend(table for table in tables if table not in ordered)
    for table in ordered:
        if table in SKIP_DATA:
            continue
        columns = info[table]
        names = [column["name"] for column in columns]
        rows = db.execute(f"SELECT * FROM {q_sqlite(table)}").fetchall()
        if not rows:
            continue
        lines.append(f"-- {table} ({len(rows)})")
        types = {column["name"]: column_type(table, column) for column in columns}
        for chunk in chunks(rows, 40):
            lines.append(f"INSERT INTO {q(table)} ({', '.join(q(name) for name in names)}) VALUES")
            values = []
            for row in chunk:
                cells = [
                    literal(row[name], types[name], name in JSON_COLUMNS.get(table, set()))
                    for name in names
                ]
                values.append("    (" + ", ".join(cells) + ")")
            lines.append(",\n".join(values) + ";")
            lines.append("")
        if any(column["name"] == "id" and column["pk"] for column in columns):
            max_id = db.execute(f"SELECT COALESCE(MAX(id), 0) + 1 FROM {q_sqlite(table)}").fetchone()[0]
            lines.append(f"ALTER TABLE {q(table)} AUTO_INCREMENT = {int(max_id)};")
            lines.append("")

    lines.extend(indexes(db))
    lines.extend(foreign_keys(db, tables))
    lines.append("SET FOREIGN_KEY_CHECKS = 1;")
    lines.append("SET UNIQUE_CHECKS = 1;")
    lines.append("")
    lines.append("-- Login check. Password for every row is 123456")
    lines.append("SELECT `email`, `name`, `is_platform_admin` FROM `users` ORDER BY `id`;")
    lines.append("")

    text = "\n".join(lines)
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(text, encoding="utf-8")
    shutil.copyfile(OUT, DOWNLOAD)
    print(f"Wrote {OUT}")
    print(f"Wrote {DOWNLOAD}")
    print(f"bytes {OUT.stat().st_size}")


def q_sqlite(name: str) -> str:
    return '"' + name.replace('"', '""') + '"'


def header(db: sqlite3.Connection) -> list[str]:
    company = db.execute("SELECT name, slug FROM companies LIMIT 1").fetchone()
    accounts = db.execute(
        """
        SELECT u.email, u.name, cu.job_title,
               GROUP_CONCAT(r.name, ' + ') AS roles
        FROM users u
        LEFT JOIN company_user cu ON cu.user_id = u.id
        LEFT JOIN user_roles ur ON ur.user_id = u.id
        LEFT JOIN roles r ON r.id = ur.role_id
        GROUP BY u.id
        ORDER BY u.id
        """
    ).fetchall()
    lines = [
        "-- =============================================================================",
        "-- سامانه شرکت مجازی / Virtual Company OS",
        "-- این فایل برای MySQL و MariaDB است، از جمله phpMyAdmin و mysqli.",
        "-- فایل‌های PostgreSQL را در این دیتابیس ایمپورت نکنید.",
        "-- یک دیتابیس خالی بسازید، همان را انتخاب کنید، سپس این فایل را Import کنید.",
        "-- جدول‌های همین برنامه را پاک و دوباره می‌سازد. روی دیتابیس برنامهٔ دیگر نزنید.",
        "-- MySQL 5.7+ or MariaDB 10.2+. Not for PostgreSQL.",
        "--",
        f"-- Company: {company['name']}  |  slug: {company['slug']}",
        "-- Password for every account: 123456",
        "-- Change that password before any shared or production use.",
        "--",
        "-- Accounts:",
    ]
    for row in accounts:
        role = row["roles"] or "platform admin, no company membership"
        title = row["job_title"] or "-"
        lines.append(f"-- {row['email']}  |  {row['name']}  |  {title}  |  {role}")
    lines.extend(
        [
            "--",
            "-- After import, point Laravel at this database and generate APP_KEY:",
            "-- DB_CONNECTION=mysql",
            "-- DB_HOST=127.0.0.1",
            "-- DB_PORT=3306",
            "-- DB_DATABASE=your_database_name",
            "-- DB_USERNAME=your_database_user",
            "-- DB_PASSWORD=your_database_password",
            "-- php artisan key:generate",
            "-- Do not also run migrate --seed on this same database.",
            "-- This file contains a fake national id, salary, invoice, and deal amount.",
            "-- =============================================================================",
            "",
        ]
    )
    return lines


def create_table(table: str, columns: list[dict]) -> list[str]:
    pk = [column["name"] for column in columns if column["pk"]]
    id_column = next((column for column in columns if column["name"] == "id"), None)
    single_id = pk == ["id"] and id_column is not None and "int" in (id_column["type"] or "").lower()
    body = []
    for column in columns:
        mysql_type = column_type(table, column)
        line = f"    {q(column['name'])} {mysql_type}"
        if single_id and column["name"] == "id":
            line += " NOT NULL AUTO_INCREMENT"
        elif column["notnull"] and not (single_id and column["name"] == "id"):
            line += " NOT NULL"
        default = None if (single_id and column["name"] == "id") else default_sql(column, mysql_type)
        if default is not None and mysql_type != "LONGTEXT":
            line += f" DEFAULT {default}"
        body.append(line)
    if pk:
        body.append("    PRIMARY KEY (" + ", ".join(q(name) for name in pk) + ")")
    rendered = ",\n".join(body)
    return [
        f"CREATE TABLE {q(table)} (",
        rendered,
        ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;",
    ]


def foreign_keys(db: sqlite3.Connection, tables: list[str]) -> list[str]:
    lines = ["-- foreign keys"]
    seen = set()
    for table in tables:
        groups: dict[int, list[sqlite3.Row]] = {}
        for row in db.execute(f"PRAGMA foreign_key_list({q_sqlite(table)})"):
            groups.setdefault(int(row["id"]), []).append(row)
        for group in groups.values():
            group.sort(key=lambda item: int(item["seq"]))
            cols = [item["from"] for item in group]
            refs = [item["to"] for item in group]
            target = group[0]["table"]
            action = str(group[0]["on_delete"] or "NO ACTION").upper().replace("_", " ")
            if action not in {"CASCADE", "SET NULL", "RESTRICT", "NO ACTION"}:
                action = "NO ACTION"
            name = f"{table}_{'_'.join(cols)}_fk"
            if len(name) > 64:
                name = name[:64]
            if name in seen:
                name = name[:58] + "_" + str(len(seen))
            seen.add(name)
            lines.append(
                f"ALTER TABLE {q(table)} ADD CONSTRAINT {q(name)} "
                f"FOREIGN KEY ({', '.join(q(col) for col in cols)}) "
                f"REFERENCES {q(target)} ({', '.join(q(col) for col in refs)}) "
                f"ON DELETE {action};"
            )
    lines.append("")
    return lines


def indexes(db: sqlite3.Connection) -> list[str]:
    lines = ["-- indexes"]
    for row in db.execute("SELECT sql FROM sqlite_master WHERE type = 'index' AND sql IS NOT NULL"):
        sql = row[0]
        unique = "UNIQUE " if sql.upper().startswith("CREATE UNIQUE") else ""
        name = sql.split('"')[1]
        table = sql.split('"')[3]
        cols_raw = sql[sql.rfind("(") + 1:sql.rfind(")")]
        cols = [part.strip().strip('"') for part in cols_raw.split(",")]
        if len(name) > 64:
            name = name[:64]
        lines.append(
            f"CREATE {unique}INDEX {q(name)} ON {q(table)} ({', '.join(q(col) for col in cols)});"
        )
    lines.append("")
    return lines


def chunks(rows: list, size: int):
    for start in range(0, len(rows), size):
        yield rows[start:start + size]


if __name__ == "__main__":
    main()
