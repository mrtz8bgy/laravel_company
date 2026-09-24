# گزارش فاز ۴

## ساخته شد

پروندهٔ منابع انسانی، درخواست مرخصی، درخواست مأموریت، و اثر تأیید مرخصی روی حضور امروز.

`/hr/me` سمت و کد پرسنلی عضویت را نشان می‌دهد و هرگز حقوق یا کد ملی را برنمی‌گرداند.

## مهاجرت

`2026_09_25_140000_create_hr_tables`

- `hr_profiles`
- `leave_requests`
- `mission_requests`

## API

فهرست در [api.md](api.md). همه پشت `feature:hr`.

## مجوزها

- `hr.profile.view`
- `hr.profile.update`
- `hr.salary.view`
- `leave.request`
- `leave.review`
- `mission.request`
- `mission.review`

نقش مالی حقوق را نمی‌بیند. بررسی‌کننده درخواست خودش را نمی‌بندد. اگر حضور خاموش باشد، تأیید مرخصی ردیف حضور نمی‌سازد.

## تست

همان `tests/Feature/WorkApiTest.php`. کل مجموعه بعد از این فاز: ۲۷ تست، ۱۹۷ assertion.

## مانده

فاز ۵: پیام و اعلان. معماری SaaS و feature flag برای ماژول‌های بعدی دست نخورده است.
