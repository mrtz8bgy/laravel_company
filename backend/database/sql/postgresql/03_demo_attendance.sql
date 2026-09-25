-- Today's live clock in Asia/Tehran. Historical work-report rows are already in 02_seed.sql.
-- Safe to skip. ON CONFLICT keeps an existing day, presence, or report.
BEGIN;

INSERT INTO attendance_days (
    company_id, uuid, user_id, work_date, location, day_status,
    check_in_at, late_minutes, worked_minutes, break_minutes, expected_minutes,
    excused, note, created_at, updated_at
)
SELECT c.id, gen_random_uuid()::text, u.id, (timezone('Asia/Tehran', now()))::date,
       'office', 'open',
       ((date_trunc('day', timezone('Asia/Tehran', now())) + time '08:50') AT TIME ZONE 'Asia/Tehran') AT TIME ZONE 'UTC',
       0, 0, 0, 420, false, 'شروع روز در دفتر', now(), now()
FROM users u
JOIN company_user cu ON cu.user_id = u.id
JOIN companies c ON c.id = cu.company_id AND c.slug = 'ideban-almas'
WHERE u.email = 'ceo@ideban.test'
ON CONFLICT (company_id, user_id, work_date) DO NOTHING;

INSERT INTO attendance_days (
    company_id, uuid, user_id, work_date, location, day_status,
    check_in_at, late_minutes, worked_minutes, break_minutes, expected_minutes,
    excused, note, created_at, updated_at
)
SELECT c.id, gen_random_uuid()::text, u.id, (timezone('Asia/Tehran', now()))::date,
       'remote', 'open',
       ((date_trunc('day', timezone('Asia/Tehran', now())) + time '09:05') AT TIME ZONE 'Asia/Tehran') AT TIME ZONE 'UTC',
       0, 0, 0, 420, false, NULL, now(), now()
FROM users u
JOIN company_user cu ON cu.user_id = u.id
JOIN companies c ON c.id = cu.company_id AND c.slug = 'ideban-almas'
WHERE u.email = 'developer@ideban.test'
ON CONFLICT (company_id, user_id, work_date) DO NOTHING;

INSERT INTO work_presences (company_id, user_id, status, note, since, created_at, updated_at)
SELECT c.id, u.id, 'office', 'شروع روز در دفتر', now(), now(), now()
FROM users u
JOIN company_user cu ON cu.user_id = u.id
JOIN companies c ON c.id = cu.company_id AND c.slug = 'ideban-almas'
WHERE u.email = 'ceo@ideban.test'
ON CONFLICT (company_id, user_id) DO NOTHING;

INSERT INTO work_presences (company_id, user_id, status, since, created_at, updated_at)
SELECT c.id, u.id, 'remote', now(), now(), now()
FROM users u
JOIN company_user cu ON cu.user_id = u.id
JOIN companies c ON c.id = cu.company_id AND c.slug = 'ideban-almas'
WHERE u.email = 'developer@ideban.test'
ON CONFLICT (company_id, user_id) DO NOTHING;

INSERT INTO daily_reports (company_id, uuid, user_id, work_date, kind, body, submitted_at, created_at, updated_at)
SELECT c.id, gen_random_uuid()::text, u.id, (timezone('Asia/Tehran', now()))::date, 'morning',
       'امروز روی محصول و گزارش روزانه کار می‌کنم.', now(), now(), now()
FROM users u
JOIN company_user cu ON cu.user_id = u.id
JOIN companies c ON c.id = cu.company_id AND c.slug = 'ideban-almas'
WHERE u.email = 'developer@ideban.test'
ON CONFLICT (company_id, user_id, work_date, kind) DO NOTHING;

SELECT setval(pg_get_serial_sequence('attendance_days', 'id'), COALESCE((SELECT MAX(id) FROM attendance_days), 1), true);
SELECT setval(pg_get_serial_sequence('work_presences', 'id'), COALESCE((SELECT MAX(id) FROM work_presences), 1), true);
SELECT setval(pg_get_serial_sequence('daily_reports', 'id'), COALESCE((SELECT MAX(id) FROM daily_reports), 1), true);

COMMIT;
