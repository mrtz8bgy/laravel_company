# نصب و راه‌اندازی

دو راه دارید. فقط یکی را روی یک دیتابیس خالی اجرا کنید. اگر SQL را بارگذاری کردید، دیگر `migrate` نزنید؛ جدول `migrations` از قبل پر شده است.

## حساب‌های ورود

رمز همهٔ حساب‌های نمونه: `123456`

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

شرکت نمونه منطقهٔ زمانی `Asia/Tehran` و تقویم شمسی دارد. حضور، پروژه، منابع انسانی، پیام، تقویم، فروش، بازاریابی، تبلیغ، مالی، پشتیبانی، تأیید، اسناد و سنجه در دادهٔ نمونه روشن‌اند. گزارش کار هر نفر حدود سه هفته روز کاری، گزارش روزانه و وظیفهٔ فرستاده‌شده توسط مدیرعامل دارد.

## XAMPP با PHP 8.2

رابط کاربری از خود Apache سرو می‌شود. برای کار روزمره `npm run dev` لازم نیست.

بعد از گرفتن آخرین نسخه، اگر پنجرهٔ `npm run dev` باز است آن را ببندید. صفحهٔ سفید یعنی آدرس پوشهٔ `frontend` باز شده است. این آدرس را باز کنید:

`http://127.0.0.1/laravel_company/`

همان صفحه از این آدرس هم باز می‌شود:

`http://127.0.0.1/laravel_company/backend/public/`

ورود: `ceo@ideban.test` / `123456`

در `backend\.env` این دو مقدار را برابر همان آدرسی بگذارید که در مرورگر باز می‌شود. اگر `FRONTEND_URL` هنوز پورت ۵۱۷۳ باشد، لینک دعوت و بازیابی رمز به سرور Vite می‌رود و روی زمپ باز نمی‌شود.

```env
APP_URL=http://127.0.0.1/laravel_company/backend/public
FRONTEND_URL=http://127.0.0.1/laravel_company/backend/public
```

اگر نام پوشه در `htdocs` چیز دیگری است، همان نام را در آدرس بگذارید. برنامه مسیر نصب را از درخواست می‌خواند و لازم نیست در کد ثابت شود.

سلامت API:

`http://127.0.0.1/laravel_company/backend/public/api/v1/health`

اگر صفحه نوشت فرانت ساخته نشده، یا پوشهٔ `backend\public\app` در پروژه نیست، یک بار خروجی را بسازید و صفحه را تازه کنید:

```bat
cd C:\xampp8\htdocs\laravel_company\frontend
npm install
npm run build
```

`npm run dev` فقط وقتی لازم است که خود فایل‌های Vue را تغییر می‌دهید. در آن حالت مبدأ مجاز این است:

```env
CORS_ALLOWED_ORIGINS=http://localhost:5173,http://127.0.0.1:5173
```

اگر این خطا را دیدید:

`Unknown database 'virtual-company-os-mysql.sql'`

نام دیتابیس را برابر نام فایل گذاشته‌اید. فایل SQL دیتابیس نیست. در `backend\.env` این مقدارها را بگذارید:

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=virtual_company
DB_USERNAME=root
DB_PASSWORD=
```

در محیط محلی، اگر نام دیتابیس به `.sql` ختم شود، برنامه خودش دیتابیس `virtual_company` را می‌سازد و فایل `backend/database/sql/mysql/virtual-company-os.sql` را داخل آن وارد می‌کند. صفحه را یک بار تازه کنید.

اگر این خطا را دیدید:

`No application encryption key has been specified.`

یعنی `APP_KEY` در `backend\.env` خالی است. نسخهٔ جدید با اولین باز شدن سایت آن را می‌سازد و در همان فایل ذخیره می‌کند. صفحه را یک بار تازه کنید. اگر هنوز ماند، این را بزنید:

```bat
C:\xampp8\php\php.exe artisan key:generate
```

اگر صفحهٔ خطا خودش این را نشان داد:

`file_get_contents(.../exceptions/renderer/dist/styles.css): Failed to open stream`

پوشهٔ `dist` صفحهٔ خطای لاراول در کپی پروژه نبوده است. فایل‌های جایگزین داخل `backend/resources/exceptions-renderer` هستند و با اولین درخواست، یا با این دستور، سر جایشان کپی می‌شوند:

```bat
C:\xampp8\php\php.exe scripts\install-exception-renderer.php
```

اگر این خطا را دیدید:

`Your Composer dependencies require a PHP version ">= 8.4.1". You are running 8.2.12.`

نسخهٔ PHP شما کافی است. قفل قدیمی وابستگی‌ها Symfony 8 را آورده بود و آن فقط روی PHP 8.4 اجرا می‌شود. پروژه اکنون روی Laravel 12 و Symfony 7 است و حداقل PHP آن 8.2.0 است. PHP 7.4 با این فریمورک سازگار نیست و نباید پایین‌تر از 8.2 بروید.

در `C:\xampp8\htdocs\laravel_company\backend` پوشهٔ `vendor` را پاک کنید، بعد با همان PHP ایکس‌امپ این را بزنید:

```bat
C:\xampp8\php\php.exe C:\ProgramData\ComposerSetup\bin\composer.phar update
```

اگر Composer جای دیگری است، مسیر همان فایل را بگذارید. بعد از آن `vendor\composer\platform_check.php` باید `>= 8.2.0` بخواهد، نه `8.4.1`. ریشهٔ سایت باید `backend\public` باشد، نه خود پوشهٔ `backend`.

در `php.ini` همین ایکس‌امپ این‌ها باید روشن باشند: `openssl`، `pdo_mysql`، `mbstring`، `tokenizer`، `xml`، `ctype`، `fileinfo`، `bcmath`.

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

رابط توسعه: `http://localhost:5173`  
رابط بدون Vite، بعد از `npm run build`: `http://localhost:8000`  
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

## راه ۳ — بارگذاری یک فایل روی MySQL یا MariaDB

اگر هاست شما MySQL است و با phpMyAdmin یا mysqli کار می‌کنید، فقط همین فایل را ایمپورت کنید:

`virtual-company-os-mysql.sql`

نسخهٔ داخل پروژه: `backend/database/sql/mysql/virtual-company-os.sql`

این فایل اسکیما، شرکت نمونه، نقش‌ها و حساب‌های ورود را با هم دارد. رمز همه `123456` است. فایل‌های پوشهٔ `postgresql` را روی MySQL نزنید.

1. در پنل هاست یک دیتابیس خالی با یونیکد `utf8mb4` بسازید.
2. همان دیتابیس را در phpMyAdmin انتخاب کنید.
3. از زبانهٔ Import فایل را بارگذاری کنید.
4. در `backend/.env` اتصال را روی همان دیتابیس بگذارید و کلید برنامه را بسازید. بعد از این ایمپورت، `migrate --seed` نزنید.

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=نام_دیتابیس_شما
DB_USERNAME=کاربر_دیتابیس
DB_PASSWORD=رمز_دیتابیس
```

```bash
php artisan key:generate
```

اگر این دیتابیس را قبلاً ساخته‌اید، فایل را دوباره ایمپورت نکنید. مهاجرت تازه‌ای هم نیست. تقویم شمسی بدون تغییر اسکیما کار می‌کند. برای پر شدن گزارش کار نمونه، بعد از گرفتن کد:

```bash
php artisan db:seed --class=Database\\Seeders\\DemoWorkHistorySeeder
```

جزئیات ذخیره و همین دستور در [database.md](database.md) است.

برای ساخت دوبارهٔ هر دو فایل SQL بعد از تغییر seeder، فقط روی دیتابیس محلی:

```bash
cd backend
php artisan migrate:fresh --seed
python3 database/sql/export-mysql.py
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
