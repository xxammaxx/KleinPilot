# KleinPilot

Local-first Android app for preparing manual Kleinanzeigen listing drafts.

## Scope

KleinPilot helps create local listing drafts. It does **not** post listings automatically.

## Non-goals

- No login automation
- No automatic posting
- No scraping
- No messaging automation
- No account automation
- No telemetry
- No cloud storage
- No background services

## MVP Features

- Create local draft with title, description, condition, defects, price, handover notes
- Preview formatted listing text
- Manual copy to clipboard
- Manual export dialog
- Safety / About section with all guarantees

## Platform

- Flutter (Android-first)
- No iOS/web in MVP
- Tested on Samsung SM T595 (Android 10 / API 29)

## Getting Started

```bash
flutter pub get
flutter test
flutter build apk --debug
flutter install -d <device_id>
```

## Safety

See [docs/SAFETY_POLICY.md](docs/SAFETY_POLICY.md) for full safety guarantees.

## Architecture

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for architecture overview.

## Evidence

See [docs/EVIDENCE.md](docs/EVIDENCE.md) for MVP scaffold evidence.
