# API v1

پایه: `/api/v1`

احراز هویت: `Authorization: Bearer {token}`

## عمومی

| Method | Path | توضیح |
| --- | --- | --- |
| GET | `/health` | سلامت سرویس و دیتابیس |
| POST | `/auth/login` | ورود. در صورت چند شرکت، `requires_company` |
| POST | `/auth/forgot-password` | همیشه پاسخ موفق، بدون افشای ایمیل |
| POST | `/auth/reset-password` | تنظیم رمز با توکن ایمیل |
| POST | `/auth/accept-invite` | پذیرش دعوت |
| POST | `/onboarding/company` | ساخت شرکت و مالک |

ورود محدود به ۵ تلاش در دقیقه برای هر ایمیل و IP است. ساخت شرکت ۳ بار در دقیقه برای هر IP.

## با توکن

| Method | Path |
| --- | --- |
| GET | `/auth/me` |
| POST | `/auth/logout` |
| POST | `/auth/logout-all` |
| GET | `/auth/sessions` |
| DELETE | `/auth/sessions/{uuid}` |
| POST | `/auth/switch-company` |
| GET/PATCH | `/profile` |

## داخل شرکت

middleware: `auth:sanctum` + `tenant` + permission همان مسیر.

- `GET /dashboard`
- `GET /search?q=`
- `GET /activity-logs`
- `GET/PATCH /company` — فیلد `calendar` (`jalali`|`gregorian`) سیستم نمایش تاریخ شرکت است و در `settings` ذخیره می‌شود
- `GET/PUT /work-schedules`
- `GET /features` و `PATCH /features/{key}`
- `GET/PUT /settings` و `PUT /settings/{key}`
- CRUD `/departments` و `/teams`
- `POST/DELETE /teams/{team}/members`
- CRUD `/users`
- `GET/POST/DELETE /invitations`
- CRUD `/roles` و `GET /permissions`
- `POST /onboarding/departments|teams|invites|complete`

## حضور — فاز ۲

نیازمند feature `attendance` و توکن شرکت.

| Method | Path | مجوز |
| --- | --- | --- |
| GET | `/attendance/today` | attendance.clock |
| GET | `/attendance/me?from&to` | attendance.clock |
| POST | `/attendance/check-in` | attendance.clock |
| POST | `/attendance/check-out` | attendance.clock |
| POST | `/attendance/break/start` | attendance.clock |
| POST | `/attendance/break/end` | attendance.clock |
| PUT | `/attendance/status` | attendance.clock |
| GET | `/attendance/board?date` | attendance.view |
| PATCH | `/attendance/days/{uuid}` | attendance.correct |
| POST | `/attendance/reports` | attendance.reports.submit |
| GET | `/attendance/reports?date` | attendance.reports.view |
| GET | `/attendance/people/{uuid}?from&to` | attendance.view |

ورود دوباره در همان روز، یا خروج بدون ورود، خطای ۴۲۲ است. اصلاح ساعت باید در همان تاریخ کاری و منطقهٔ زمانی شرکت باشد. تابلوی حضور برای منابع انسانی کل شرکت است و برای مدیر واحد یا سرپرست فقط افراد زیرمجموعه.

اگر feature پروژه روشن باشد و کاربر `tasks.view` داشته باشد، `tasks` در پاسخ `/attendance/today` پر می‌شود. در غیر این صورت `tasks_available` برابر false است.

### گزارش کار یک فرد

`GET /attendance/people/{uuid}?from&to` گزارش یک نفر را برای مدیر برمی‌گرداند: خلاصه (روزها، کارکرد، انتظار، تراز، تأخیر، تعداد گزارش)، ردیف‌های حضور و گزارش‌های صبح/پایان‌روز.

- بازه پیش‌فرض ۳۰ روز تا امروزِ شرکت و سقف آن ۹۲ روز است؛ `from` و `to` تاریخ میلادی `YYYY-MM-DD` می‌گیرند.
- دامنهٔ دید همان `AttendanceAccess` است: منابع انسانی و دارندهٔ `attendance.correct` کل شرکت، مدیر واحد و سرپرست تیم فقط افراد زیرمجموعه. همکار ساده ۴۰۳ می‌گیرد و uuid شرکت دیگر ۴۰۴.
- پاسخ شامل `timezone` و `calendar` شرکت است تا کلاینت تاریخ را با همان تنظیم نمایش دهد. وظیفه‌ها در این پاسخ نیستند (مرز ماژول).

### اصلاح ساعت یک روز

`PATCH /attendance/days/{uuid}` با `check_in_at` و `check_out_at` نیازمند مجوز `attendance.correct` است. زمان باید همان تاریخ کاری و با آفست منطقهٔ زمانی شرکت فرستاده شود، در غیر این صورت ۴۲۲ برمی‌گردد.

## پروژه و کانبان — فاز ۳

نیازمند feature `projects`.

| Method | Path | مجوز |
| --- | --- | --- |
| GET | `/projects` | projects.view |
| POST | `/projects` | projects.create |
| GET | `/projects/{uuid}` | projects.view |
| PATCH | `/projects/{uuid}` | projects.update |
| DELETE | `/projects/{uuid}` | projects.delete |
| GET | `/projects/{uuid}/board` | projects.view |
| POST | `/projects/{uuid}/members` | projects.update |
| DELETE | `/projects/{uuid}/members/{user}` | projects.update |
| GET | `/tasks/mine` | tasks.view |
| GET | `/tasks/people/{uuid}?open=1` | tasks.view |
| POST | `/tasks` | tasks.create |
| PATCH | `/tasks/{uuid}` | tasks.update |
| POST | `/tasks/{uuid}/move` | tasks.update |
| POST | `/tasks/{uuid}/comments` | tasks.update |
| DELETE | `/tasks/{uuid}` | tasks.delete |

`GET /tasks/people/{uuid}` وظیفه‌های ارسال‌شده به یک نفر را از میان پروژه‌هایی که بیننده می‌بیند برمی‌گرداند و خلاصهٔ `total|open|done|overdue` دارد.

ارسال وظیفه همان `POST /tasks` است با `assignee_uuid`. انتساب به شخص دیگر نیازمند `tasks.assign` یا نقش مدیر پروژه است؛ انتساب به خود همیشه مجاز است. این قاعده هم در ساخت و هم در ویرایش اعمال می‌شود.

پروژهٔ `private` فقط برای اعضا و مالک/مدیرعامل دیده می‌شود. حدس uuid برای غیرعضو ۴۰۴ است، نه ۴۰۳. کارمند فقط وظیفهٔ خودش یا وظیفه‌ای که گزارش کرده را ویرایش می‌کند. تغییر مسئول نیاز به `tasks.assign` یا نقش مدیر پروژه دارد. حذف پروژه در عمل بایگانی است.

## منابع انسانی — فاز ۴

نیازمند feature `hr`.

| Method | Path | مجوز |
| --- | --- | --- |
| GET | `/hr/me` | leave.request |
| GET | `/hr/people/{user}` | hr.profile.view |
| PATCH | `/hr/people/{user}` | hr.profile.update |
| GET/POST | `/hr/leave` | leave.request |
| POST | `/hr/leave/{uuid}/review` | leave.review |
| GET/POST | `/hr/missions` | mission.request |
| POST | `/hr/missions/{uuid}/review` | mission.review |

`/hr/me` هرگز کد ملی و حقوق برنمی‌گرداند. این دو فیلد فقط با `hr.salary.view` در پروندهٔ فرد دیگر می‌آیند. نقش مالی این مجوز را ندارد. بررسی‌کننده نمی‌تواند درخواست خودش را تأیید کند. تأیید مرخصی که امروز را پوشش دهد، اگر حضور روشن باشد، همان روز را `excused` می‌کند. اگر حضور خاموش باشد هیچ ردیف حضوری ساخته نمی‌شود.

## پیام، تقویم، فروش، مالی و بقیه — فاز ۵ تا ۱۳

هر گروه پشت feature همان ماژول است. مبلغ فاکتور و معامله فقط با مجوز همان ماژول برمی‌گردد. سنجهٔ `/analytics/overview` فقط کارت‌هایی را می‌دهد که مجوزشان را دارید.

| Method | Path | مجوز |
| --- | --- | --- |
| GET/POST | `/channels` | messages.view / announcements.publish |
| GET/POST | `/channels/{uuid}/messages` | messages.view / messages.send |
| GET/POST | `/announcements` | messages.view / announcements.publish |
| GET/POST | `/events` | calendar.view / calendar.manage |
| GET/POST | `/crm/accounts` `/crm/contacts` `/crm/deals` | crm.view / crm.manage |
| GET/POST | `/campaigns` | marketing.view / marketing.manage |
| GET | `/advertising/campaigns` | advertising.view |
| GET/POST | `/finance/invoices` `/finance/expenses` | finance.view / finance.manage |
| GET/POST | `/tickets` | tickets.create |
| PATCH | `/tickets/{uuid}` | tickets.manage |
| GET/POST | `/approvals` | workflows.request |
| POST | `/approvals/{uuid}/review` | workflows.review |
| GET/POST | `/documents` | documents.view / documents.manage |
| GET | `/analytics/overview` | analytics.view |

سند خصوصی و رویداد خصوصی برای غیرمالک ۴۰۴ است. تأیید درخواست خود ۴۲۲ است. آپلود فایل هنوز نیست؛ اسناد متنی‌اند.

## پلتفرم

فقط `is_platform_admin`:

- `GET /platform/companies`
- `PATCH /platform/companies/{uuid}` با `status=active|suspended`

ادمین پلتفرم برای دادهٔ داخل شرکت باید `X-Company-Id` بفرستد یا هنگام ورود شرکت را انتخاب کند.

## تاریخ، زمان و تقویم شمسی

- همهٔ تاریخ‌ها در پایگاه داده میلادی و UTC ذخیره می‌شوند. این قانون تغییر نمی‌کند.
- منطقهٔ زمانی هر شرکت در ستون `companies.timezone` است و پیش‌فرض آن `Asia/Tehran` است. حضور، مهلت وظیفه و گزارش‌ها با همین منطقه محاسبه و نمایش داده می‌شوند.
- سیستم نمایش تاریخ هر شرکت در `settings.calendar` است: `jalali` (پیش‌فرض) یا `gregorian`. مقدار آن در پاسخ `/company` و `/auth/me` به کلاینت داده می‌شود.
- تبدیل در کلاینت انجام می‌شود (`frontend/src/lib/jalali.ts` و `frontend/src/lib/date.ts`). تبدیل شمسی با تقویم رسمی ایران و چرخهٔ ۳۳ساله است و با `Intl` روی ۱۲ سال تطبیق داده شده است.
- ورودی تاریخ در فرم‌ها شمسی است (`1405/07/03`، با ارقام فارسی یا لاتین) و هنگام ارسال به میلادی تبدیل می‌شود.
- اصلاح ساعت حضور باید با آفست شرکت ارسال شود، در غیر این صورت سرور آن را رد می‌کند.

## پنل مشتریان

ثبت‌نام عمومی است و به شرکت با `company_slug` وصل می‌شود. تا تأیید مدیر، عضویت `pending` است و سفارش و پیام ۴۲۲ می‌شود. ایمیل مشتری بعد از ساخت عوض نمی‌شود.

| روش | مسیر | دسترسی |
| --- | --- | --- |
| GET | `/portal/companies/{slug}` | عمومی؛ فقط نام شرکت |
| POST | `/portal/register` | عمومی؛ رمز قوی لازم است |
| GET/PATCH | `/portal/me` | خود مشتری، حتی در انتظار تأیید |
| GET | `/portal/products` | مشتری تأییدشده برای سفارش؛ فهرست فقط کالاهای فعال |
| GET/POST | `/portal/orders` | فقط سفارش خود مشتری |
| GET/POST | `/portal/threads` | پیام به `sales`، `support` یا `management` |
| POST | `/portal/threads/{uuid}/replies` | ادامهٔ گفتگوی خود |
| GET/POST | `/portal/tickets` | تیکت به فروش، پشتیبانی یا مدیریت؛ مشتری در انتظار نمی‌تواند بسازد |
| GET | `/portal/tickets/{uuid}` | فقط تیکت خود |
| POST | `/portal/tickets/{uuid}/replies` | پاسخ مشتری؛ تیکت بسته رد می‌شود |
| GET | `/portal/desk` | میزهای مجاز کارمند |
| GET | `/portal/desk/customers` | `customers.view` |
| POST | `/portal/desk/customers/{uuid}/review` | `customers.review` با `approve` یا `reject` |
| GET/POST/PATCH | `/portal/desk/products` | `products.view` / `products.manage` |
| GET/PATCH | `/portal/desk/orders` | `customer_orders.view` / `customer_orders.manage` |
| GET | `/portal/desk/threads?desk=` | فقط میز واحد خود؛ فروش، پشتیبانی (`operations`) یا مدیریت |
| GET | `/portal/desk/tickets?desk=` | همان مرز میز |
| POST | `/portal/desk/tickets/{uuid}/replies` | پاسخ کارمند؛ `status` اختیاری |
| PATCH | `/portal/desk/tickets/{uuid}` | تغییر وضعیت تیکت |

مشتری شرکت دیگر و سفارش دیگران ۴۰۴ است. کارمند بدون میز مربوط ۴۰۳ می‌گیرد. مبلغ سفارش برای نقش بدون `customer_orders.view` در میز کارمند برنمی‌گردد.
