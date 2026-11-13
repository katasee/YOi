# YOi — Product Spec

First approved: 2026-07-15 (two cabinets: master + client).
Rewritten: 2026-10-09 for the **master-only pivot** (independent cabinets, one per master). The two-cabinet version lives in git history;
the full pivot design (alternatives, data model detail, open points) is
`docs/superpowers/specs/2026-10-09-master-only-pivot-design.md`. PRs M-30…M-38 (`docs/plan.md`,
item 9) moved the code there: since M-38 every screen reads `slots`, and the old `blocks` are gone.

## Goal

An iOS app for any master who books clients — nails, hair, brows, massage. Each master signs up and gets an independent cabinet: her client base,
her free windows, her bookings and her personal plans in one calendar. It replaces the Notes list she keeps today and the screenshot she posts to
Instagram. Clients never use the app — they write to the master in Instagram (or by phone), and
the master books them herself.

## Scope

- One SwiftUI app; every user is a master. Sign-up and sign-in (email + password) with email
  verification before the cabinet opens, forgot password, change password, delete account with all
  her data (App Store requires in-app deletion) — the last two on a Profile screen. No roles, no
  salons.
- Firebase Auth + Cloud Firestore; all of a master's data lives under `users/{uid}/`, readable and
  writable only by her.
  Kept behind repository protocols so it can be swapped for SwiftData + CloudKit later.
- No push notifications, no reminders, no payments, nothing sent automatically to Instagram.
- Light and dark themes (System / Light / Dark, per device), chosen on the Profile screen, which
  the round person button next to the "Статистика" title opens.

## Data model (Firestore)

```
users/{uid}              name, email                                       — created at sign-up
… and under it:
clients/{autoId}         name?, instagram? (lowercased, no "@"), phone? (+48 + 9 digits),
                         createdAt, lastBookedAt?          — name or instagram required
slots/{yyyy-MM-dd_HHmm}  date, time, clientId?, serviceId?, serviceName?, servicePrice?
                         — no client = free window; id from date+time, so no duplicates
events/{autoId}          date, startTime, endTime, templateId? + emoji/name snapshot
                         (no templateId = a one-off plan, typed in place, Y-58)
                         (weekdays[] + fromDate, skippedDates[] with the weekly repeat)
eventTemplates/{autoId}  emoji, name, isActive                            — "Мої справи"
services/{autoId}        name, price (whole PLN), isFavorite?
```

A slot is a **date + start time**; visits have no duration. Booking sets `clientId` and a snapshot
of the service; cancelling clears them (the window is free again); rescheduling moves the booking
to another date/time in one batch and frees the old window.

## Navigation

Three tabs: **Розклад / Клієнтки / Статистика**. "Мої послуги" and "Мої справи" are entries inside
Статистика ("set up once" screens), "Мої справи" also from the personal-plan sheet.

## Flows

1. **Clients** — add a client by Instagram handle and/or name (+ optional phone). Search by name,
   handle or phone. The card opens the client's Instagram profile (`https://instagram.com/<handle>`)
   and/or calls / texts the phone, and lists her bookings: "Заплановано" (nearest first) and
   "Історія записів" (newest first, or "Ще немає записів") — from the slots already read, i.e. the
   last 3 months and everything ahead, not a separate per-client query.
2. **Free windows** — "+" → "Вільні вікна на місяць": select several days on a month grid, pick
   hours, add them all at once. Repeat for days with other hours. The month under the Розклад
   title opens a month calendar to jump straight to any day (back to the 3 months of history that
   are read, forward without limit).
3. **Send the schedule** — "Надіслати графік" on Розклад: the free windows of a month (the
   current one from now on, later ones whole; arrows like a calendar) as text in the master's own
   format, one line per day — `1.10-9:00/11:00/13:00`, no title, no weekdays. "Скопіювати"
   copies it; "Надіслати" picks a client by search, copies it and opens her Instagram profile or
   an SMS with the text filled in. The stories image and the price list are out of scope for now.
4. **Book** — tap a free window (past ones too) → one popup: search focused (an empty search
   lists nobody), pick a client, optionally a service — only starred ones are offered — then
   "Записати". "+ Нова клієнтка" is always there and opens the client form over the popup;
   "+ Нова послуга", the last service chip (dashed), opens the "Мої послуги" form the same way and
   selects the new service — so a new master can book before filling "Мої послуги" (Y-57/Y-58).
   "+ Швидко додати" under a day books a client at a typed time without a window first; it works
   on past days too, back to the 1st of the oldest month the 3-month query loads in full, so a
   master who starts mid-month can enter the visits she already had (Y-61). On a past day it
   offers booking only — plans and free windows are for today and later.
5. **Booking actions** — tap a booked slot → Написати, Змінити послугу (always offered, with
   "+ Нова послуга" among the chips), Перенести, Картка
   клієнтки (opens inside Розклад), Скасувати запис (asks first). Перенести (past bookings too):
   a scroller of days from today, that day's free windows or own time; same client and service,
   the old window becomes free, Розклад jumps to the new day. A deleted client keeps only the
   actions on the window. Where the recipient is known,
   "Надіслати @нік" copies the message and opens her chat; the master pastes and sends.
6. **Personal plans** — "Своя справа" (boxing, gym): a "Мої справи" template (emoji + name), or a
   one-off plan typed in place (an emoji tile that opens the emoji grid + a name; not saved as a
   template; a typed name and a template chip exclude each other), start–end, on one or several picked days (the "Мої справи" tab of Розклад's "+") or weekly on
   chosen days; shown in the day list like a booking, tap → change (always offered: another template or a one-off name) / move / delete. A free window that overlaps a plan (assuming
   a 60-minute visit) is flagged and left out of what is published; it is not deleted. Adding
   something that overlaps on **one** day offers "Замінити" after a confirmation listing what
   changes: a plan deletes the windows under it (booked ones too); a booking or window trims the
   plan to end at it, or deletes the plan when it starts there. Over several days an overlap still
   blocks the add.

## Statistics (calendar month, navigable back)

- **Revenue** — sum of `servicePrice` over booked slots that already happened.
- **Expected** — the same over all booked slots of the month, past and future; hidden for a
  finished month.
- **Visits** — booked slots that already happened. **Clients** — distinct `clientId` among them.
- **Free windows** — in the current month the ones still ahead; in a past month the unbooked ones.
- **Occupancy** — booked windows ÷ all windows of the month (past and future), as a percent;
  "—" for a month with no windows; no comparison.
- **Comparison with the previous month** — money (percent) and clients (count), full calendar
  months; hidden when the previous month earned nothing or is not fully loaded.
- **How far back** — the first month the 3-month slot query loads in full; older months come from
  stored monthly summaries in M-38.1. A month's summary is written only once it leaves that
  window, since until then it can still be booked into (Y-61).
- No "hours worked": visits have no duration.

## Out of scope

Client accounts or a client app; salons or data shared between masters; automatic sending to Instagram; WhatsApp; push notifications and
reminders; payments; service durations; reviews, portfolio; price ranges;
no-show status; per-service statistics; a client-facing web page (possible later).
