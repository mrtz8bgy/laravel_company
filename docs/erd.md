# ERD فاز ۱

شناسهٔ عمومی همه‌جا `uuid` است. کلید داخلی عددی فقط برای رابطه استفاده می‌شود و در API برنمی‌گردد.

```text
companies
  └── company_user ── users
  └── departments ── teams ── team_user ── users
  └── roles ── role_permissions ── permissions
  └── user_roles / user_permissions
  └── work_schedules
  └── invitations
  └── features
  └── settings
  └── activity_logs
  └── login_sessions
personal_access_tokens.company_id → companies
attendance_days → attendance_events
work_presences
daily_reports
projects → project_members / kanban_columns → tasks → task_comments
hr_profiles
leave_requests
mission_requests
```

## جداول

- `companies`: نام، slug، وضعیت، timezone، locale، plan، user_limit، settings، onboarded_at. منطقهٔ زمانی پیش‌فرض `Asia/Tehran`. سیستم نمایش تاریخ در `settings.calendar` است: `jalali` (پیش‌فرض) یا `gregorian`. ستون تازه‌ای برای تقویم اضافه نشده است.
- `users`: هویت سراسری. ایمیل یکتا. `is_platform_admin`. ستون‌های 2FA رزرو.
- `company_user`: عضویت، سمت، کد پرسنلی، واحد، مالک بودن، وضعیت
- `departments`: واحد، مدیر، والد، کد، ترتیب
- `teams` / `team_user`: تیم داخل واحد، نقش عضو `member|leader`
- `permissions`: کاتالوگ سراسری
- `roles`: نقش هر شرکت، `is_system`
- `role_permissions`, `user_roles`, `user_permissions`
- `work_schedules`: یک ردیف برای هر weekday ۰ تا ۶
- `activity_logs`: action، entity، old/new، ip، user agent. رمز و توکن redact می‌شوند.
- `invitations`: توکن به‌صورت sha256
- `login_sessions`: دستگاه، ip، زمان ورود و خروج، اتصال به توکن
- `settings`, `features`
- `personal_access_tokens` به‌علاوه `company_id`
- `projects`: نام، slug، کد، وضعیت، visibility برابر `company|private`، واحد، مالک، تاریخ
- `project_members`: نقش `manager|member|viewer`
- `kanban_columns`: ترتیب و `is_done`
- `tasks`: ستون، اولویت، مسئول، گزارش‌دهنده، مهلت، `completed_at`
- `task_comments`
- `hr_profiles`: نوع همکاری، تاریخ استخدام، کد ملی، تماس اضطراری، حقوق. کد ملی و حقوق فقط با مجوز
- `leave_requests` / `mission_requests`: بازه، وضعیت `pending|approved|rejected`، بررسی‌کننده

## ایندکس‌ها

هر FK ایندکس است. یکتا بودن slug و code در محدودهٔ شرکت است. ایمیل کاربر سراسری یکتا است تا یک هویت بتواند در آینده عضو چند شرکت باشد.

## حضور — فاز ۲

- `attendance_days`: یک ردیف برای هر شخص و تاریخ کاری شرکت. ورود، خروج، تأخیر، کارکرد، استراحت، مرخصی‌بودن.
- `attendance_events`: خط زمانی ورود، خروج، استراحت، تغییر وضعیت و اصلاح.
- `work_presences`: وضعیت جاری: دفتر، دورکاری، استراحت، جلسه، مأموریت، مرخصی، خارج.
- `daily_reports`: چک‌این صبح و گزارش روزانه. یک ردیف برای هر نوع در هر روز.

شیفت شب در این مدل نیست. هر ثبت به تاریخ محلی شرکت تعلق دارد.

گزارش کار هر شخص جدول تازه نمی‌سازد. همان `attendance_days`، `attendance_events` و `daily_reports` را می‌خواند. وظیفه‌های همان شخص از `tasks` و فقط در ماژول پروژه برمی‌گردند. ذخیره همیشه میلادی و UTC است؛ شمسی فقط نمایش است.

دادهٔ نمونهٔ شرکت ایده‌بان، علاوه بر حضور امروز، حدود سه هفته روز کاریِ بسته‌شده، گزارش صبح و روزانه، و وظیفه‌ای که مدیرعامل برای هر نفر فرستاده دارد. سیدر `DemoWorkHistorySeeder` این ردیف‌ها را می‌سازد و اگر روز گذشته‌ای از قبل باشد دوباره نمی‌نویسد.

## کار، منابع انسانی و بقیهٔ سامانه

- پروژه، عضو، ستون کانبان، وظیفه و نظر.
- پرونده، مرخصی و مأموریت. حقوق و کد ملی فقط با مجوز منابع انسانی برمی‌گردد.
- کانال، عضو کانال، پیام و اطلاعیه.
- رویداد تقویم. رویداد خصوصی برای غیرمالک دیده نمی‌شود.
- حساب، مخاطب و معامله. مبلغ معامله فقط با مجوز فروش.
- کمپین، با کانال بازاریابی یا تبلیغ.
- فاکتور و هزینه. مبلغ فقط با مجوز مالی و در لاگ فعالیت نوشته نمی‌شود.
- تیکت و پاسخ. تیکت دیگران برای نقش بدون مدیریت ۴۰۴ است.
- درخواست تأیید. تأیید درخواست خود رد می‌شود.
- سند متنی. سند خصوصی برای غیرمالک ۴۰۴ است.

آپلود فایل، صورتحساب SaaS و 2FA هنوز جدول عملیاتی ندارند.

## پنل مشتریان

- `customers`: حساب مشتری، وضعیت `pending|active|rejected`، سازمان، تلفن، یادداشت تأیید. به `users` وصل است و نقش `client` می‌گیرد. تا تأیید، عضویت شرکت `pending` است و مسیرهای کارمندی بسته می‌ماند.
- `products`: کاتالوگ، قیمت به ریال، موجودی اختیاری.
- `customer_orders` / `customer_order_items`: سفارش مشتری. مبلغ فقط برای خود مشتری و نقش دارای `customer_orders.view`.
- `customer_threads` / `customer_thread_messages`: پیام به میز `sales|support|management`. هر میز فقط واحد مربوط یا نقش ممتاز را می‌بیند.
- `customer_tickets` / `customer_ticket_messages`: تیکت شماره‌دار همان میزها. وضعیت `open|in_progress|answered|closed`. مشتری در انتظار و تیکت بسته نمی‌توانند پاسخ بدهند.
