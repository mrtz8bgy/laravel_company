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
- `GET/PATCH /company`
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

ورود دوباره در همان روز، یا خروج بدون ورود، خطای ۴۲۲ است. اصلاح ساعت باید در همان تاریخ کاری و منطقهٔ زمانی شرکت باشد. تابلوی حضور برای منابع انسانی کل شرکت است و برای مدیر واحد یا سرپرست فقط افراد زیرمجموعه.

اگر feature پروژه روشن باشد و کاربر `tasks.view` داشته باشد، `tasks` در پاسخ `/attendance/today` پر می‌شود. در غیر این صورت `tasks_available` برابر false است.

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
| POST | `/tasks` | tasks.create |
| PATCH | `/tasks/{uuid}` | tasks.update |
| POST | `/tasks/{uuid}/move` | tasks.update |
| POST | `/tasks/{uuid}/comments` | tasks.update |
| DELETE | `/tasks/{uuid}` | tasks.delete |

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
