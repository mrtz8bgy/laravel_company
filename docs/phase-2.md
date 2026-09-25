# گزارش فاز ۲

## ساخته شد

دفتر مجازی روی همان هستهٔ چندمستأجری: ورود و خروج، استراحت، دورکاری، جلسه، مأموریت، مرخصی، وضعیت کاری، چک‌این صبح، گزارش روزانه، تابلوی حضور، و محاسبهٔ تأخیر و کارکرد از ساعت کاری شرکت.

جای وظیفهٔ امروز در میز کار و صفحهٔ حضور خالی است تا فاز پروژه آن را پر کند.

## مهاجرت

`2026_09_25_120000_create_attendance_tables`

- `attendance_days`
- `attendance_events`
- `work_presences`
- `daily_reports`

همین مهاجرت مجوزهای جدید را به نقش‌های سیستمی موجود اضافه می‌کند و feature حضور را برای شرکت‌های قبلی روشن می‌کند.

## API

فهرست در [api.md](api.md). همهٔ مسیرها زیر `/api/v1` و پشت `feature:attendance` هستند.

## مجوزها

- `attendance.clock`
- `attendance.view`
- `attendance.correct`
- `attendance.reports.submit`
- `attendance.reports.view`

کارمند فقط ثبت خودش را دارد. مدیر واحد و سرپرست تابلوی محدودهٔ خود را می‌بینند. منابع انسانی و مالک می‌توانند اصلاح کنند. مشتری این مجوزها را ندارد.

## تست‌ها

`tests/Feature/AttendanceApiTest.php` و `tests/Unit/AttendanceCalculatorTest.php`.

پوشش: تأخیر بعد از فرجه، استراحت، خروج، ممنوعیت کارمند برای تابلو و اصلاح، ایزولهٔ شرکت دیگر، اصلاح توسط منابع انسانی، خاموش بودن feature، مرخصی بدون تأخیر.

آخرین اجرای کل مجموعه: ۲۴ تست، ۱۳۷ assertion.

## SQL و حساب‌ها

بارگذاری مستقیم PostgreSQL:

- `backend/database/sql/postgresql/01_schema.sql`
- `backend/database/sql/postgresql/02_seed.sql`
- `backend/database/sql/postgresql/03_demo_attendance.sql`

حساب‌ها و رمز در [install.md](install.md). رمز همه: `123456`.

## باقی‌مانده

- شیفت شب پشتیبانی نمی‌شود
- مرخصی اینجا یک وضعیت حضور است، نه گردش تأیید منابع انسانی فاز ۴
- 2FA و آپلود فایل هنوز نیستند
- Docker در این محیط اجرا نشد

## فاز بعد

فاز ۳: پروژه، وظیفه و کانبان. تا آن موقع `tasks_available` برابر false می‌ماند.
