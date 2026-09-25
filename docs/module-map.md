# نقشه ماژول

```text
Platform
  Auth
  Organizations        Company, Department, Team, Schedule, Invitation, Feature
  Identity             User, Membership
  Access               Role, Permission
  Core                 Tenant, Activity log, API envelope, Search, Dashboard
  Attendance           Clock, presence, daily report
  Projects             Project, member, kanban, task
  Hr                   Profile, leave, mission
  Communication        Channel, message, announcement
  Calendar             Event
  Crm                  Account, contact, deal
  Marketing            Campaign, advertising
  Finance              Invoice, expense
  Operations           Ticket
  Workflows            Approval
  Documents            Text document
  Analytics            Permission-gated overview
  Portal               Customer registration, catalog, orders, messages, tickets, profile
```

هر ماژول feature flag خودش را دارد:

| فاز | ماژول | flag |
| --- | --- | --- |
| 2 | Attendance, Check-in, Daily report | attendance |
| 3 | Projects, Tasks, Kanban | projects |
| 4 | HR profile, Leave, Mission | hr |
| 5 | Messages, Announcements | communication |
| 6 | Calendar, Meetings | calendar |
| 7 | CRM, Sales | crm |
| 8 | Marketing, Advertising | marketing, advertising |
| 9 | Finance | finance |
| 10 | Help desk | operations |
| 11 | Workflow, Approval | workflows |
| 12 | Documents, Wiki | documents |
| 13 | KPI, Reports | analytics |
| — | Customer portal | portal |

فاز ۲ تا ۱۳ جدول، API و صفحه دارند. در شرکت نمونه همهٔ این flagها روشن‌اند و از تنظیمات شرکت خاموش می‌شوند. آپلود فایل و صورتحساب SaaS هنوز نیستند.
