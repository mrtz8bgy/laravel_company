# گزارش فاز ۳

## ساخته شد

پروژه، عضو، کانبان چهارستونه، وظیفه، توضیح، انتقال بین ستون‌ها، و پر شدن «وظیفهٔ امروز» در حضور و میز کار.

ستون‌های پیش‌فرض: صف انتظار، در حال انجام، بازبینی، انجام شد.

پروژهٔ نمونه: فروشگاه و دفتر مجازی.

## مهاجرت

`2026_09_25_130000_create_project_tables`

- `projects`
- `project_members`
- `kanban_columns`
- `tasks`
- `task_comments`

## API

فهرست در [api.md](api.md). همه پشت `feature:projects`.

## مجوزها

`projects.view|create|update|delete` و `tasks.view|create|update|assign|delete`.

پروژهٔ خصوصی برای غیرعضو و برای شرکت دیگر ۴۰۴ است. کارمند وظیفهٔ دیگران را جابه‌جا نمی‌کند و مسئول را عوض نمی‌کند.

## تست

`tests/Feature/WorkApiTest.php`

## مانده

پیام، تقویم، CRM و بقیهٔ فازهای ۵ تا ۱۳.
