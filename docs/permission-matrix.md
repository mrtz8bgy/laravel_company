# ماتریس دسترسی

مجوزهای `platform.*` به نقش شرکتی داده نمی‌شوند. ادمین پلتفرم با ستون `is_platform_admin` شناخته می‌شود.

| مجوز | مالک / مدیرعامل | مدیر واحد | سرپرست / کارمند | منابع انسانی | فروش / بازاریابی / مالی | مشتری |
| --- | --- | --- | --- | --- | --- | --- |
| dashboard.view | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| company.view | ✓ | ✓ | ✓ | ✓ | ✓ | |
| company.update | ✓ | | | | | |
| company.settings.manage | ✓ | | | | | |
| users.view | ✓ | ✓ | ✓ | ✓ | ✓ | |
| users.create / invite | ✓ | | | ✓ | | |
| users.update | ✓ | ✓ | | ✓ | | |
| users.delete | ✓ | | | | | |
| departments.view | ✓ | ✓ | ✓ | ✓ | ✓ | |
| departments.* | ✓ | | | | | |
| teams.view | ✓ | ✓ | ✓ | ✓ | ✓ | |
| teams.* | ✓ | ✓ | | | | |
| roles.* / permissions.view | ✓ | | | | | |
| activity_logs.view | ✓ | ✓ | | ✓ | | |
| profile.view / update | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| features.view / manage | ✓ | | | | | |
| attendance.clock / reports.submit | ✓ | ✓ | ✓ | ✓ | ✓ | |
| attendance.view | ✓ | ✓ | سرپرست | ✓ | | |
| attendance.correct | ✓ | | | ✓ | | |
| attendance.reports.view | ✓ | ✓ | | ✓ | | |
| projects.view / tasks.view / tasks.create / tasks.update | ✓ | ✓ | ✓ | ✓ | ✓ | |
| projects.create / projects.update / tasks.assign | ✓ | ✓ | سرپرست | | | |
| projects.delete / tasks.delete | ✓ | | | | | |
| hr.profile.view / update / hr.salary.view | ✓ | | | ✓ | | |
| leave.review / mission.review | ✓ | ✓ | | ✓ | | |
| leave.request / mission.request | ✓ | ✓ | ✓ | ✓ | ✓ | |

نقش‌ها سیستمی‌اند ولی به‌جز حذف و به‌جز خالی کردن نقش مالک، مجوزشان قابل ویرایش است. نقش سفارشی هم ساخته می‌شود.

مجوز مستقیم روی کاربر با نقش جمع می‌شود. اعطاکننده نمی‌تواند مجوزی بالاتر از خودش بدهد.

| messages.view / messages.send | ✓ | ✓ | ✓ | ✓ | ✓ | |
| announcements.publish | ✓ | ✓ | | | | |
| calendar.view | ✓ | ✓ | ✓ | ✓ | ✓ | |
| calendar.manage | ✓ | ✓ | سرپرست | | | |
| crm.view / crm.manage | ✓ | | | | فروش | |
| marketing.* / advertising.* | ✓ | | | | بازاریابی | |
| finance.view / finance.manage | ✓ | | | | مالی | |
| tickets.create | ✓ | ✓ | ✓ | ✓ | ✓ | |
| tickets.manage | ✓ | ✓ | | | | |
| workflows.request | ✓ | ✓ | ✓ | ✓ | ✓ | |
| workflows.review | ✓ | ✓ | | | | |
| documents.view | ✓ | ✓ | ✓ | ✓ | ✓ | |
| documents.manage | ✓ | ✓ | | ✓ | | |
| analytics.view | ✓ | ✓ | | | مالی | |
| customers.view | ✓ | ✓ | | ✓ | فروش | |
| customers.review | ✓ | ✓ | | ✓ | | |
| products.view / products.manage | ✓ | ✓ | | | مشاهده برای فروش | |
| customer_orders.view / manage | ✓ | ✓ | | | فروش | |
| customer_messages.view / reply | ✓ | ✓ | واحد مربوط | | فروش | |

پیام و تیکت مشتری به پشتیبانی را اعضای واحد `operations` می‌بینند، حتی اگر مجوز فروش نداشته باشند. میز مدیریت فقط برای نقش ممتاز است. مشتری فقط صفحهٔ `/portal` و پروفایل خودش را دارد و در فهرست کارمندان نمی‌آید.

مالک و مدیرعامل همهٔ مجوزهای شرکت را دارند، از جمله فروش، بازاریابی و مالی. مبلغ فاکتور، معامله و حقوق فقط با مجوز همان ماژول در پاسخ API می‌آید.
