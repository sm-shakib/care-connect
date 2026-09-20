# Care Connect Backend (FastAPI)

The Care Connect API. Built with **FastAPI** on **PostgreSQL** (hosted on Neon), it owns every business rule in the product: authentication, role-based access, the care circle, medicines and reminders, bookings and payments, encrypted chat, call signalling, and the central fund.

**This service is deployed on [Render](https://render.com).** The Flutter app points at it by default, so nothing here needs to run on your machine to develop the app.

- **Base URL:** `https://care-connect-backend-aqgr.onrender.com`
- **Interactive API docs (Swagger):** [`/docs`](https://care-connect-backend-aqgr.onrender.com/docs)
- **Health check:** `GET /` → `{"message": "Care Connect Backend with DB is running!"}`

> Render's free tier spins a service down when idle. The first request after a quiet period can take 30–60 seconds while it wakes; subsequent requests are fast. If the app looks hung on login, that is usually why.

---

## Contents

- [Deployment](#deployment)
- [Environment variables](#environment-variables)
- [Project structure](#project-structure)
- [Authentication and authorization](#authentication-and-authorization)
- [API surface](#api-surface)
- [Real-time: chat, calls and SOS](#real-time-chat-calls-and-sos)
- [Background jobs](#background-jobs)
- [Database and schema changes](#database-and-schema-changes)
- [External services](#external-services)
- [Troubleshooting](#troubleshooting)

---

## Deployment

Render builds from this repository's `backend` directory. The authoritative build command, start command and environment variables live in the Render dashboard for the service — treat the dashboard as the source of truth and this section as a description of it.

| Setting | Value |
|---|---|
| Root directory | `backend` |
| Build command | `pip install -r requirements.txt` |
| Start command | binds Render's injected `$PORT`, e.g. `gunicorn app.main:app -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:$PORT` |
| Runtime | Python 3.10+ |

Deploys are triggered by pushes to the tracked branch. Two things to keep in mind:

- **Secrets are set in the Render dashboard**, never committed. `.env` is gitignored; [`.env.example`](.env.example) lists the keys without values.
- **Keep the worker count at 1 unless you change how background jobs are scheduled.** The missed-dose and appointment sweeps run inside the API process (see [Background jobs](#background-jobs)), so every extra worker runs its own copy of them and users get duplicate notifications.

---

## Environment variables

All of these are read in [`app/core/config.py`](app/core/config.py). Copy the shape from [`.env.example`](.env.example).

| Variable | Required | Purpose |
|---|---|---|
| `DATABASE_URL` | yes | Neon PostgreSQL connection string, `?sslmode=require`. |
| `SECRET_KEY` | yes | JWT signing key (HS256). Tokens last 7 days. |
| `CHAT_MASTER_KEY` | recommended | Wraps per-conversation chat keys. Falls back to a value derived from `SECRET_KEY`; **rotating `SECRET_KEY` without setting this makes existing messages unreadable.** |
| `CLOUDINARY_CLOUD_NAME` / `CLOUDINARY_API_KEY` / `CLOUDINARY_API_SECRET` | yes | Uploads: profile photos, caregiver documents, chat attachments. |
| `SMTP_USER` / `SMTP_PASSWORD` / `SMTP_SERVER` / `SMTP_PORT` / `FROM_EMAIL` | yes | Password-reset OTPs and caregiver verification emails. Defaults to `smtp.gmail.com:587`. |
| `BKASH_USERNAME` / `BKASH_PASSWORD` / `BKASH_APP_KEY` / `BKASH_APP_SECRET` | yes | bKash tokenized checkout for bookings and donations. |
| `BKASH_BASE_URL` | no | Defaults to the sandbox, `https://tokenized.sandbox.bka.sh/v1.2.0-beta`. Point at production to take real payments. |
| `STUN_URLS` | no | Comma-separated STUN servers for WebRTC. Defaults to `stun:stun.l.google.com:19302`. |
| `TURN_URLS` | no | Comma-separated TURN relays. Without one, calls fail between peers behind symmetric NAT. |
| `TURN_USERNAME` / `TURN_PASSWORD` | no | Long-lived credential pair from a hosted TURN provider. |
| `TURN_STATIC_AUTH_SECRET` | no | Self-hosted coturn in `use-auth-secret` mode. Takes precedence over the static pair, since credentials expire per user. |
| `TURN_CREDENTIAL_TTL` | no | Lifetime of generated TURN credentials, in seconds. Defaults to 43200 (12h). |

---

## Project structure

```text
backend/
├── app/
│   ├── api/              # Routers — one module per feature area
│   │   ├── auth.py       # login, forgot/verify/reset password
│   │   ├── elder.py      # elder profile, SOS, appointments, care reminders, vitals
│   │   ├── caregiver.py  # caregiver signup, public list, document resubmission
│   │   ├── family.py     # family signup and profile
│   │   ├── users.py      # /users/me and profile patching
│   │   ├── binding.py    # family–elder binding requests and responses
│   │   ├── booking.py    # bookings + bKash payment for a booking
│   │   ├── medicine.py   # medicines and "mark taken"
│   │   ├── complaint.py  # filing complaints, caregiver responses
│   │   ├── fund.py       # donations, aid requests, admin fund actions
│   │   ├── notification.py
│   │   ├── chat.py       # conversations, messages, attachments, read receipts
│   │   ├── chat_ws.py    # single WebSocket: chat, call signalling, SOS push
│   │   ├── admin.py      # dashboard, verification queue, users, bookings, complaints
│   │   ├── utils.py      # /upload
│   │   └── deps.py       # auth dependencies and role guards
│   ├── core/
│   │   ├── config.py     # settings loaded from .env
│   │   ├── security.py   # password hashing, JWT encode/decode
│   │   ├── crypto.py     # AES-256 message encryption
│   │   ├── media.py      # Cloudinary uploads
│   │   ├── email.py      # SMTP sending
│   │   ├── bkash.py      # bKash token, create, execute
│   │   ├── pricing.py    # booking price from hourly rate and schedule
│   │   └── turn.py       # STUN/TURN credential generation
│   ├── db/session.py     # engine, SessionLocal, Base
│   ├── models/           # SQLAlchemy tables
│   ├── schemas/          # Pydantic request/response models
│   ├── services/
│   │   ├── care_circle.py          # who may see/act on an elder
│   │   ├── notification_jobs.py    # the 5-minute reminder sweep
│   │   ├── admin_notification.py   # fan-out to all admins
│   │   └── time_parsing.py
│   └── main.py           # app, CORS, router registration, job lifespan
├── scripts/              # one-off additive migrations (see below)
├── .env.example          # variable names, no values
└── requirements.txt
```

---

## Authentication and authorization

`POST /login` returns a JWT carrying the user's `role`, their `profile_id` and, for caregivers, their verification `status`. Clients send it as `Authorization: Bearer <token>`; tokens are valid for one week.

Authorization is enforced in two places, and both matter:

1. **Role guards** in [`app/api/deps.py`](app/api/deps.py) — e.g. only an `admin` may reach `/admin/*`, only an `elder` may trigger SOS.
2. **Care-circle checks** in [`app/services/care_circle.py`](app/services/care_circle.py) — for anything touching a specific elder's data. A caller passes only if they are that elder, a family member with an **accepted** binding, or a caregiver with an **accepted** booking. Everything else is a `403`.

Suspended accounts (`users.is_active = false`) are rejected at login.

---

## API surface

Full request and response schemas are browsable at [`/docs`](https://care-connect-backend-aqgr.onrender.com/docs). The shape of it:

| Prefix | Area | Notable endpoints |
|---|---|---|
| *(none)* | Auth | `POST /login`, `POST /forgot-password`, `POST /verify-otp`, `POST /reset-password` |
| *(none)* | Signup | `POST /elders/signup/elder`, `POST /signup/caregiver`, `POST /families/signup/family` |
| *(none)* | Public caregivers | `GET /caregivers`, `GET /caregivers/{id}` |
| *(none)* | Upload | `POST /upload` |
| `/users` | Account | `GET /users/me`, `PATCH /users/me`, `PATCH /users/me/profile` |
| `/elders` | Elder data | `GET|PUT /elders/me`, `POST /elders/sos`, `PATCH /elders/{id}/vitals`, appointments and reminders (own + by elder id) |
| `/families` | Family | `GET|PUT /families/me` |
| `/bindings` | Binding | `POST /bindings/request`, `PUT /bindings/{id}/respond`, `GET /bindings/pending/me`, `GET /bindings/family/members`, `GET /bindings/elder/members` |
| `/medicines` | Medicines | `GET /medicines/me`, `GET /medicines/{elder_id}`, `POST`/`PUT`/`DELETE`, `PATCH /medicines/{id}/take` |
| `/bookings` | Bookings | `POST /bookings/`, `GET /bookings/caregiver/{id}`, `GET /bookings/elder/{id}`, `PATCH /bookings/{id}`, `POST /bookings/{id}/bkash/create`, `POST /bookings/{id}/bkash/execute` |
| `/complaints` | Complaints | `POST /complaints/`, `GET /complaints/me`, `GET /complaints/caregiver`, `PATCH /complaints/{id}/respond` |
| `/fund` | Central fund | `GET /fund/stats`, `POST /fund/donate`, bKash create/execute, `POST /fund/request-aid`, `GET /fund/my-donations`, `GET /fund/my-requests`, admin donation/request/assign/review endpoints |
| `/chat` | Chat | `GET /chat/contacts`, `GET /chat/ice-servers`, conversation CRUD (direct + group), messages, attachments, media, read, search, mute, members |
| `/notifications` | Notifications | `GET /notifications/`, `GET /notifications/unread-count`, `PUT /notifications/read-all`, `PUT /notifications/{id}/read` |
| `/admin` | Admin | `GET /admin/dashboard`, caregiver verification queue and per-document verify, user list/detail/status/delete, bookings, complaints and notes |
| `/ws/chat` | WebSocket | chat delivery, call signalling, live SOS — see below |

CORS is currently open (`allow_origins=["*"]`), which suits a mobile client. Tighten it before putting a browser front end on a shared domain.

---

## Real-time: chat, calls and SOS

One WebSocket, `GET /ws/chat` ([`app/api/chat_ws.py`](app/api/chat_ws.py)), carries three things:

- **Chat delivery** — `message:new` broadcasts to participants, plus unsend events.
- **Call signalling** — `call:invite`, `offer`, `answer` and `ice` are relayed between peers; media itself flows peer-to-peer over WebRTC. Clients fetch `GET /chat/ice-servers` for STUN/TURN configuration. Call outcome and duration are written back as a `call_log` message.
- **SOS push** — `sos:alert` reaches care-circle members who are connected right now. Offline members still get the stored notification, so nothing is lost either way.

Message text is encrypted with a per-conversation AES-256 key ([`app/core/crypto.py`](app/core/crypto.py)); the conversation keys themselves are wrapped with `CHAT_MASTER_KEY`. Unsending a message wipes the ciphertext and its attachments rather than just flagging a row.

---

## Background jobs

[`app/services/notification_jobs.py`](app/services/notification_jobs.py) runs as an `asyncio` task started in the app's `lifespan` and cancelled on shutdown. Every 5 minutes it:

1. Loads medicines active today, and for any dose still unmarked past its grace period — and not already reported today — creates a `medicine_missed` notification for every care-circle member.
2. Parses appointment dates and times, and creates an `appointment_reminder` for any appointment starting within the next hour that has not been notified yet.

Because this lives in the API process, it only runs while the service is awake. On Render's free tier, a service that has spun down is not sweeping — doses missed during that window are reported when it next wakes.

---

## Database and schema changes

Tables are created on startup by `Base.metadata.create_all(bind=engine)` in [`app/main.py`](app/main.py). That creates **missing tables**; it does not alter existing ones. Adding a field to an existing model therefore needs an explicit migration.

There is no Alembic setup. Column additions are handled by small additive scripts in [`scripts/`](scripts), each paired with a rollback where reversing it is not obvious:

```text
scripts/add_aid_assignment_columns.py       + rollback_aid_assignment_columns.py
scripts/add_care_notification_columns.py
scripts/add_sos_notification_columns.py
```

Run one against the deployed database from a Render shell, or locally with `DATABASE_URL` pointed at the same Neon instance. `fix_amounts.py`, `fix_chat_schema.py` and `fix_db.py` in this directory are historical one-off repairs kept for reference — read them before running anything.

Twenty-two tables in all, defined in [`app/models/`](app/models): users, OTPs, the three profile tables, caregiver documents, family–elder links, bookings, medicines, appointments, care reminders, notifications, complaints and notes, the four chat tables, donations, aid requests and the fund snapshot.

---

## External services

| Service | Used for | Fails as |
|---|---|---|
| **Neon** (PostgreSQL) | everything persistent | total outage |
| **Cloudinary** | profile photos, caregiver documents, chat attachments | uploads rejected; existing media unaffected |
| **bKash** | booking payments and donations | payment cannot be created or executed; the booking stays `payment_status = pending` |
| **SMTP** | OTP emails, caregiver verification emails | password reset silently stalls at the OTP step — worth checking first when reset "does nothing" |
| **STUN / TURN** | WebRTC connectivity | calls ring but never connect for peers behind restrictive NAT |

---

## Troubleshooting

**First request after idle takes ~a minute.** Render free-tier cold start. Expected.

**`401` on every authenticated request.** Token expired (7 days) or `SECRET_KEY` changed on the server — existing tokens are invalidated by a rotation. Log in again.

**`403` on an elder's data.** The caller is not in that elder's care circle. Check the binding is `accepted`, or the booking is `accepted` — a `pending` one grants nothing.

**Password reset emails never arrive.** Check the SMTP variables in the Render dashboard. Note that `POST /forgot-password` returns a generic success even for unknown emails, by design, so a silent failure looks identical to a typo'd address.

**Chat messages come back empty or garbled.** `CHAT_MASTER_KEY` no longer matches the one the messages were encrypted under. Restore the original value; there is no recovery without it.

**Duplicate missed-dose notifications.** More than one worker process is running the background sweep. See [Deployment](#deployment).

**New column missing after a model change.** `create_all` does not alter existing tables. Write and run a script in [`scripts/`](scripts).

---

## Running the API locally

Not needed for app development — the app targets the hosted service. If you are changing the backend itself and want to test before deploying: create a virtualenv, `pip install -r requirements.txt`, provide a `.env` (copy `.env.example`, and point `DATABASE_URL` at a **separate** Neon branch rather than the live database), then run `uvicorn app.main:app --reload --host 0.0.0.0` and switch `baseUrl` in `frontend/lib/core/constants/api_constants.dart` to the commented-out local URL — `10.0.2.2` for the Android emulator, your machine's LAN IP for a physical device.
