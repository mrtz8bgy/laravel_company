# Docker

`docker-compose.yml` این سرویس‌ها را دارد:

- `app` — PHP 8.4-FPM در Docker. خود برنامه از PHP 8.2.12 به بالا اجرا می‌شود، از جمله XAMPP 8.
- `nginx` — پورت 8080
- `database` — PostgreSQL 16
- `redis` — صف و کش
- `queue` — `php artisan queue:work`
- `scheduler` — `php artisan schedule:work`
- `mailpit` — پورت 8025
- `minio` — ذخیرهٔ S3-سازگار، پورت 9000 و کنسول 9001

متغیرها در `docker/env/app.env` هستند. `APP_KEY` را خودتان بسازید و در `backend/.env` بگذارید؛ کلید را commit نکنید.

```bash
docker compose up --build
docker compose exec app php artisan migrate --seed
```

فرانت در این compose نیست. در توسعه `npm run dev` جدا اجرا می‌شود. در production خروجی `npm run build` می‌تواند توسط Nginx کنار API سرو شود؛ این مرحله مربوط به استقرار فاز ۱۴ است.

بکاپ روزانهٔ دیتابیس و فایل، نگهداری، و بازیابی در فاز ۱۴ پیاده می‌شود. تا آن زمان استراتژی این است: dump روزانهٔ PostgreSQL، کپی bucket مین‌آیو، نگهداری ۱۴ روز، و آزمون restore ماهانه. health check فعلی `GET /api/v1/health` و `/up` است و برای اتصال بعدی Prometheus کافی است که همین مسیر را scrape کند.
