# سامانه شرکت مجازی

**Virtual Company OS** یک سیستم‌عامل شرکتی ماژولار است: دفتر مجازی، ERP، مدیریت پروژه، منابع انسانی، فروش و اتوماسیون — از یک هستهٔ چندمستأجری.

این مخزن از صفر ساخته شده و به هیچ پروژه یا پیام‌رسان قبلی وابسته نیست.

فاز فعلی: **سامانه کامل نسخهٔ ۱**. حضور، پروژه، منابع انسانی، پیام، تقویم، فروش، بازاریابی، مالی، پشتیبانی، تأیید، اسناد و سنجه پیاده شده‌اند.

## حساب نمونه

پس از `php artisan migrate --seed`:

| نقش | ایمیل | رمز |
| --- | --- | --- |
| مدیرعامل / مالک | `ceo@ideban.test` | `123456` |
| توسعه‌دهنده | `developer@ideban.test` | `123456` |
| مهندس دوآپس | `devops@ideban.test` | `123456` |
| پشتیبانی | `support@ideban.test` | `123456` |
| مدیر فروش | `sales@ideban.test` | `123456` |
| بازاریابی | `marketing@ideban.test` | `123456` |
| مالی | `finance@ideban.test` | `123456` |
| منابع انسانی | `hr@ideban.test` | `123456` |
| ادمین پلتفرم | `platform@virtual-company.test` | `123456` |

شرکت نمونه: **شبکه پردازان ایده‌بان الماس**، منطقهٔ زمانی `Asia/Tehran`، نمایش تاریخ شمسی. گزارش کار افراد حدود سه هفته حضور نمونه دارد.

رمز نمونه فقط برای محیط توسعه است. در production عوض شود.

راهنمای کامل نصب، بارگذاری SQL و همین حساب‌ها: [docs/install.md](docs/install.md).

## نیازمندی‌ها

- PHP 8.2.12 یا بالاتر، از جمله XAMPP 8. PHP 7.4 کافی نیست.
- Composer 2
- Node.js 20+
- برای Docker: PostgreSQL 16، Redis 7، Nginx، Mailpit، MinIO

اجرای سریع محلی از SQLite استفاده می‌کند تا بدون Docker بالا بیاید. محیط Docker از PostgreSQL و Redis استفاده می‌کند.

## نصب محلی

### XAMPP

پروژه را در `htdocs/laravel_company` بگذارید. رابط ساخته‌شده از Apache سرو می‌شود و `npm run dev` لازم نیست.

`http://127.0.0.1/laravel_company/`

در `backend/.env` مقدار `APP_URL` و `FRONTEND_URL` را برابر `http://127.0.0.1/laravel_company/backend/public` بگذارید. جزئیات، از جمله ساخت دوبارهٔ فرانت بعد از تغییر Vue، در [docs/install.md](docs/install.md) است.

### سرور توسعه

```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate
touch database/database.sqlite
php artisan migrate --seed
php artisan serve --host=0.0.0.0 --port=8000

cd ../frontend
npm install
npm run dev
```

رابط توسعه: `http://localhost:5173`  
رابط ساخته‌شده، بدون Vite: `http://localhost:8000`  
API: `http://localhost:8000/api/v1`

Vite درخواست‌های `/api` را به Laravel پروکسی می‌کند. مرورگر نباید مستقیم `localhost` بک‌اند را از صفحهٔ توسعه صدا بزند.

## تست

```bash
cd backend
php artisan test
```

تست‌ها روی SQLite در حافظه اجرا می‌شوند. این انتخاب سرعت CI را بالا می‌برد و رفتار tenant را پوشش می‌دهد. قبل از انتشار، همان مهاجرت‌ها باید روی PostgreSQL هم یک‌بار اجرا شوند.

## Docker

```bash
cp docker/env/app.env backend/.env
# APP_KEY را تولید کنید و در backend/.env بگذارید
docker compose up --build
docker compose exec app php artisan migrate --seed
```

سرویس‌ها: `app`، `nginx`، `database`، `redis`، `queue`، `scheduler`، `mailpit`، `minio`.

جزئیات در [docs/docker.md](docs/docker.md).

## مستندات

- [معماری](docs/architecture.md)
- [نقشه ماژول](docs/module-map.md)
- [ERD](docs/erd.md)
- [پایگاه داده](docs/database.md)
- [ماتریس دسترسی](docs/permission-matrix.md)
- [API](docs/api.md)
- [ساختار پوشه](docs/folder-structure.md)
- [امنیت](docs/security.md)
- [نقشه راه](docs/roadmap.md)
- [گزارش فاز ۱](docs/phase-1.md)
- [گزارش فاز ۲](docs/phase-2.md)
- [گزارش فاز ۳](docs/phase-3.md)
- [گزارش فاز ۴](docs/phase-4.md)
- [گزارش فاز ۵ تا ۱۳](docs/phase-5-13.md)

## اصول

1. امنیت در بک‌اند اعمال می‌شود، نه با مخفی کردن دکمه.
2. دادهٔ شرکت‌ها با `company_id` و scope سراسری جدا می‌شود.
3. API مستقل از رابط وب است تا اپ موبایل بعداً همان قرارداد را مصرف کند.
4. منطق تجاری در Controller انباشته نمی‌شود.
5. متن رابط کاربری hard-code نیست؛ فارسی پیش‌فرض و انگلیسی زبان دوم است.
