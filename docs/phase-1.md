# گزارش فاز ۱

## ساخته شد

هستهٔ چندمستأجری Virtual Company OS: احراز هویت، شرکت، واحد، تیم، افراد، نقش و مجوز، ساعت کاری، دعوت، نشست، لاگ فعالیت، داشبورد پایه، ویزارد راه‌اندازی، رابط فارسی RTL، Docker و تست.

## مهاجرت‌ها

- توسعهٔ `users` با uuid، وضعیت، زبان، timezone و ستون‌های 2FA
- `companies`, `company_user`, `departments`, `teams`, `team_user`
- `permissions`, `roles`, `role_permissions`, `user_roles`, `user_permissions`
- `work_schedules`, `activity_logs`, `invitations`, `login_sessions`, `settings`, `features`
- `company_id` روی `personal_access_tokens`

## API

فهرست در [api.md](api.md).

## مجوزها

کاتالوگ در `PermissionCatalog`. نقش‌های سیستمی هنگام ساخت شرکت ساخته می‌شوند. همگام‌سازی بعدی: `php artisan permissions:sync`.

## تست‌ها

`tests/Feature/FoundationApiTest.php` و `tests/Unit/FoundationTest.php`.

پوشش: ساخت شرکت، ورود، خروج و ابطال توکن، ایزولهٔ دو شرکت، ممنوعیت کارمند برای ساخت واحد تا مجوز مستقیم، حفاظت از نقش سیستمی و نقش مالک، ساعت کاری، رد عضو شرکت دیگر در تیم، دعوت یک‌بارمصرف، عدم افشای ایمیل در بازیابی رمز، ادمین پلتفرم، کاربر معلق، جستجوی محدود به شرکت.

## باقی مانده

- 2FA عملیاتی نیست
- توکن مرورگر در localStorage است
- آپلود فایل ساخته نشده
- پروژه و وظیفه عمداً در این فاز نیستند
- Docker در این محیط اجرا نشده؛ فایل‌ها نوشته شده‌اند
- RLS و مانیتورینگ خارجی برای فاز ۱۴ مانده‌اند
- ویرایش واحد، اگر `manager_uuid` یا `sort_order` نفرستد، مقدار قبلی را نگه می‌دارد. پاک کردن مدیر فقط با `manager_uuid: null` است.

## فاز بعد

فاز ۲: حضور و غیاب، وضعیت کار، چک‌این و گزارش روزانه، روی همین tenant و permission.
