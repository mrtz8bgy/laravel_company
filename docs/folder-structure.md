# ساختار پوشه

```text
backend/app/Core          پاسخ API، tenant، لاگ، middleware
backend/app/Modules/Auth
backend/app/Modules/Identity
backend/app/Modules/Organizations
backend/app/Modules/Access
backend/routes/api.php
frontend/src              Vue 3، RTL، i18n
docker/                   PHP-FPM و Nginx
docs/
```

مدل کاربر احراز هویت در `App\Modules\Identity\Models\User` است و در `config/auth.php` ثبت شده. بقیهٔ مدل‌های دامنه کنار ماژول خودشان هستند.

فرانت جدا است تا API به Vue وابسته نباشد.
