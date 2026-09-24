# نصب و راه‌اندازی

دو راه دارید. فقط یکی را روی یک دیتابیس خالی اجرا کنید. اگر SQL را بارگذاری کردید، دیگر `migrate` نزنید؛ جدول `migrations` از قبل پر شده است.

## حساب‌های ورود

رمز همهٔ حساب‌های نمونه: `ChangeMe!2026`

این رمز فقط برای توسعه است. قبل از هر محیط مشترک عوض شود.

| نقش | ایمیل | شرکت |
| --- | --- | --- |
| ادمین پلتفرم | `platform@virtual-company.test` | بدون شرکت؛ برای فهرست شرکت‌ها |
| مدیرعامل و مالک | `ceo@ideban.test` | شبکه پردازان ایده‌بان الماس |
| توسعه‌دهنده / سرپرست محصول | `developer@ideban.test` | همان |
| مهندس دوآپس | `devops@ideban.test` | همان |
| پشتیبانی | `support@ideban.test` | همان |
| مدیر فروش | `sales@ideban.test` | همان |
| بازاریابی | `marketing@ideban.test` | همان |
| مدیر مالی | `finance@ideban.test` | همان |
| منابع انسانی | `hr@ideban.test` | همان |

ادمین پلتفرم عضو شرکت نمونه نیست. برای دیدن دادهٔ شرکت باید هنگام ورود شرکت را انتخاب کند یا هدر `X-Company-Id` بفرستد.

شرکت نمونه منطقهٔ زمانی `Asia/Tehran` دارد. حضور، پروژه، منابع انسانی، پیام، تقویم، فروش، بازاریابی، تبلیغ، مالی، پشتیبانی، تأیید، اسناد و سنجه در دادهٔ نمونه روشن‌اند.

## راه ۱ — Laravel

برای SQLite محلی، PostgreSQL یا MySQL.

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

رابط: `http://localhost:5173`  
API: `http://localhost:8000/api/v1`

اگر شرکت از قبل ساخته شده و فقط مجوزهای جدید را می‌خواهید:

```bash
php artisan migrate
php artisan permissions:sync
```

## راه ۲ — بارگذاری SQL روی PostgreSQL

فایل‌ها اسکیما و دادهٔ پیش‌فرض را دارند، از جمله همان حساب‌های جدول بالا. رمزها به‌صورت bcrypt ذخیره شده‌اند.

```bash
createdb virtual_company
psql -d virtual_company -v ON_ERROR_STOP=1 -f backend/database/sql/postgresql/01_schema.sql
psql -d virtual_company -v ON_ERROR_STOP=1 -f backend/database/sql/postgresql/02_seed.sql
psql -d virtual_company -v ON_ERROR_STOP=1 -f backend/database/sql/postgresql/03_demo_attendance.sql
```

سپس در `backend/.env`:

```env
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=virtual_company
DB_USERNAME=vcos
DB_PASSWORD=vcos
```

`APP_KEY` را با `php artisan key:generate` بسازید. بدون کلید، لاراول بالا نمی‌آید حتی اگر داده در دیتابیس باشد.

فایل سوم حضور نمونهٔ امروز را به وقت تهران می‌سازد. اگر نخواهید، ردش کنید؛ ورود و سازمان بدون آن کار می‌کند.

برای ساخت دوبارهٔ SQL بعد از تغییر seeder:

```bash
cd backend
php artisan migrate:fresh --seed
php database/sql/export-postgresql.php
```

## Docker

```bash
cp docker/env/app.env backend/.env
php artisan key:generate --show
# کلید را در backend/.env بگذارید
docker compose up --build
docker compose exec app php artisan migrate --seed
```

اگر به‌جای migrate می‌خواهید SQL را در کانتینر بگذارید، فقط روی دیتابیس خالی:

```bash
docker compose exec -T database psql -U vcos -d virtual_company -f - < backend/database/sql/postgresql/01_schema.sql
docker compose exec -T database psql -U vcos -d virtual_company -f - < backend/database/sql/postgresql/02_seed.sql
docker compose exec -T database psql -U vcos -d virtual_company -f - < backend/database/sql/postgresql/03_demo_attendance.sql
```

جزئیات سرویس‌ها در [docker.md](docker.md).

## بعد از ورود

1. با `ceo@ideban.test` وارد شوید.
2. از میز کار به حضور، پروژه‌ها، فروش یا مالی بروید. منوی کناری بر اساس مجوز همان کاربر ساخته می‌شود.
3. نمونهٔ seeder دو پروژه دارد: فروشگاه و دفتر مجازی. پروندهٔ نمونهٔ توسعه‌دهنده حقوق و کد ملی ساختگی دارد؛ این مقدارها فقط برای نقش مجاز در API دیده می‌شوند و داخل `02_seed.sql` هم هستند.
4. اگر یکی از قابلیت‌ها خاموش بود، مالک از تنظیمات شرکت آن را روشن می‌کند.
5. رمز نمونه را عوض کنید.
