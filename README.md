# Care Connect

A mobile application for elderly care, medicine management and family monitoring.

Care Connect connects four kinds of people around one elderly person: the **elder** themselves, the **family members** who watch over them, the **caregivers** they hire, and the **admins** who verify caregivers and run the platform. It covers the day-to-day of care — medicines, appointments, vitals, emergencies — plus the things that make care possible: finding and paying a caregiver, chatting and calling, filing complaints, and a central fund that pays for caregivers when an elder cannot.

---

## Contents

- [Roles](#roles)
- [Features](#features)
- [Architecture](#architecture)
- [Repository layout](#repository-layout)
- [Tech stack](#tech-stack)
- [Getting started](#getting-started)
- [Documentation](#documentation)
- [Contributing](#contributing)

---

## Roles

| Role | What they do |
|---|---|
| **Elder** | Manages their own medicines, appointments and care reminders; updates vitals; presses SOS; accepts family binding requests; books caregivers; requests financial aid. |
| **Family member** | Binds to an elder (with the elder's consent), then monitors vitals and live location, manages medicines and appointments on the elder's behalf, books caregivers, and receives SOS and missed-dose alerts. |
| **Caregiver** | Signs up with documents for admin verification, appears in the public caregiver list once verified, accepts or rejects booking requests, joins the elder's care circle, and responds to complaints. |
| **Admin** | Verifies caregiver documents, manages and suspends accounts, monitors bookings and payments, resolves complaints, and allocates the central fund. |

A **care circle** is the set of people allowed to see and act on an elder's data: family members with an accepted binding, plus caregivers with an accepted booking. Missed-dose alerts, SOS alerts and chat contacts are all derived from it.

---

## Features

**Accounts and access**
- Role-based signup for elder, family member and caregiver, with JWT authentication.
- Password reset by 6-digit OTP delivered over email, expiring after 10 minutes.
- Caregiver verification: document upload (national ID, certificate, police clearance), admin review per document, and a resubmit loop when documents are rejected.
- Family–elder binding by email, which only takes effect once the elder accepts.

**Daily care**
- Medicine management — dosage, form, schedule times, date range and refill tracking, with "mark taken" limited to a grace period around each scheduled time.
- Missed-dose alerts: a background job sweeps active medicines every 5 minutes and notifies the whole care circle when a dose passes its grace period unmarked.
- Appointments and care reminders, with an automatic reminder notification an hour before an appointment.
- Health monitoring: heart rate and blood pressure, plus background location tracking visible to the care circle.
- SOS: the elder presses one button, the app takes a fresh GPS fix (falling back to last known location), and the care circle gets both a stored notification and a live WebSocket push that opens a map at the elder's coordinates.

**Caregivers and money**
- Public caregiver list with ratings and hourly rates; bookings priced from the caregiver's rate across the requested schedule.
- Booking lifecycle: request → caregiver accepts or rejects → payment via bKash → caregiver joins the care circle.
- Central fund: donations via bKash or manual entry, with a running balance snapshot.
- Financial aid: an elder requests help, an admin approves and assigns a verified caregiver, and the fund covers the booking fee once the caregiver accepts.
- Complaints against caregivers, with a caregiver explanation, internal admin notes, resolution feedback, and account action where warranted.

**Communication**
- One-to-one and group chat, restricted to care-circle contacts, with message text encrypted at rest (AES-256 per conversation key).
- Attachments (image, video, document, voice), replies, unsend, read receipts, unread counts and in-conversation search.
- Voice and video calls over WebRTC, signalled through the chat WebSocket, with call logs written into the conversation.

**Admin**
- Dashboard over users, pending verifications, bookings, complaints and fund stats.
- User management with role filters, profile detail views, suspend, reactivate and delete.
- Notification centre for verification requests, booking requests, complaints and donations.

---

## Architecture

```
┌──────────────────────────────┐         ┌──────────────────────────────┐
│   Flutter app (frontend/)     │  HTTPS  │  FastAPI API (backend/)       │
│                               │ ──────► │  hosted on Render             │
│   Cubit / Bloc state           │         │                               │
│   Dio HTTP client              │  WSS    │  Background jobs:             │
│   WebRTC + WebSocket           │ ◄─────► │  missed doses, appointments   │
└──────────────────────────────┘         └───────────────┬──────────────┘
                                                          │
                          ┌───────────────┬───────────────┼───────────────┐
                          ▼               ▼               ▼               ▼
                   PostgreSQL        Cloudinary         bKash           SMTP
                    (Neon)          (media/docs)      (payments)       (email)
```

The Flutter app talks to one hosted API over REST plus a single WebSocket for chat, calls and live SOS. The backend owns all business rules, holds the only database credentials, and runs its reminder sweeps inside the API process for as long as it is up.

---

## Repository layout

```
care-connect/
├── frontend/            # Flutter app (Android, iOS, Web, Windows)
│   ├── lib/
│   │   ├── core/        # constants, network, theme, shared widgets, services
│   │   ├── shared/      # cross-role features: chat, medicine, reminders, sos, complaints
│   │   ├── elderly/     # elder dashboard, profile, aid requests, SOS
│   │   ├── family/      # family dashboard, monitoring, profile
│   │   ├── caregiver/   # caregiver dashboard, bookings, earnings, verification state
│   │   ├── admin/       # admin dashboard, verification, users, complaints, fund
│   │   └── l10n/        # ARB translation files
│   └── test/
├── backend/             # FastAPI service — see backend/README.md
└── AGENTS.md            # architecture, style and workflow contract for all contributors
```

---

## Tech stack

| Layer | Choice |
|---|---|
| Mobile app | Flutter 3.44 / Dart 3.12 |
| App state | `bloc` / `flutter_bloc` (Cubit-first), `equatable` |
| App networking | `dio`, `web_socket_channel`, `flutter_webrtc` |
| App storage | `flutter_secure_storage`, `flutter_local_notifications` |
| Lint | `very_good_analysis`, `bloc_lint` |
| API | FastAPI (Python 3.10+), Pydantic, SQLAlchemy |
| Database | PostgreSQL on Neon |
| Auth | JWT (`python-jose`), password hashing via `passlib`/`bcrypt` |
| Media | Cloudinary |
| Payments | bKash (tokenized checkout) |
| Email | SMTP |
| Hosting | Render (API), Neon (database) |

---

## Getting started

The backend is already deployed on Render and the app points at it by default, so you only need a Flutter toolchain to run Care Connect.

### 1. Prerequisites

- Flutter SDK `^3.44.0` (Dart `^3.12.0`) — check with `flutter --version`
- An Android emulator, iOS simulator or physical device

### 2. Install dependencies

```sh
cd frontend
flutter pub get
```

### 3. Run

The app ships three flavors — `development`, `staging` and `production`. Use the launch configuration in VS Code / Android Studio, or:

```sh
flutter run --flavor development --target lib/main_development.dart
```

### 4. API endpoint

All endpoints resolve against `ApiConstants.baseUrl` in `frontend/lib/core/constants/api_constants.dart`, which points at the hosted Render service. The file also keeps a commented-out local URL for anyone running the API themselves — see [`backend/README.md`](backend/README.md).

Permissions matter on device: location (SOS and monitoring), camera and microphone (calls and document upload), notifications (reminders and alerts). Grant them or those features will silently do nothing.

### 5. Tests and analysis

```sh
cd frontend
flutter analyze
dart format --set-exit-if-changed .
very_good test --coverage --test-randomize-ordering-seed random
dart run bloc_tools:bloc lint .
```

More on translations, coverage reports and bloc lints: [`frontend/README.md`](frontend/README.md).

---

## Documentation

| What | Where |
|---|---|
| Backend API, environment and deployment | [`backend/README.md`](backend/README.md) |
| Flutter tooling, flavors, translations | [`frontend/README.md`](frontend/README.md) |
| Contributor contract — architecture, style, PR checklist | [`AGENTS.md`](AGENTS.md) |
| Live API docs (Swagger) | https://care-connect-backend-aqgr.onrender.com/docs |

---

## Contributing

[`AGENTS.md`](AGENTS.md) is the source of truth for how code in this repository is shaped — layering, state management, naming, widget rules and the pull request checklist. It binds every contributor, human or AI. Read it before your first change.

The short version:

- Feature-first folders, layered inside: `data/` → `domain/` → `cubit/` → `view/` + `widgets/`.
- Widgets are dumb, Cubits are smart, repositories are the only layer that knows about the network.
- No raw colors, spacing or text styles in feature code — everything comes from the theme.
- Typed errors all the way up: `Exception` → `Failure` → state → `ErrorView`.
- `flutter analyze` and `dart format --set-exit-if-changed .` pass clean before review.

Branch off `develop` and open a pull request against it.
