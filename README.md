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
- Attach local photos to drafts (local file references only — no upload)
- Preview formatted listing text with photo count
- Manual copy to clipboard
- Manual export dialog
- Safety / About section with all guarantees

## Platform

- Flutter (Android-first)
- No iOS/web in MVP
- Tested on Samsung SM T595 (Android 10 / API 29)

## MVP Status (2026-07-05)

| Gate | Result |
|------|--------|
| flutter pub get | ✅ |
| flutter analyze | ✅ No issues |
| flutter test | ✅ 11/11 passed |
| flutter build apk --debug | ✅ `app-debug.apk` |
| Android install (SM T595, API 29) | ✅ |
| Android run | ✅ App launched |
| Safety: no network deps | ✅ |
| Safety: no telemetry | ✅ |
| Safety: no secrets | ✅ |

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

## Android Draft Flow (2026-07-05)

| Check | Result |
|-------|--------|
| Manual draft form flow | ✅ 9 fields, scrollable, editable |
| Preview generation | ✅ Navigated and displayed |
| Safety screen | ✅ Visible, guarantees confirmed |
| Manual copy/export | ✅ Widget-test verified |
| No automation UI | ✅ No login/posting/scraping |

Status: **GREEN_MANUAL_FLOW_VERIFIED**

## Photo Attachments

KleinPilot can attach local photos to a draft for manual review.

- Photos remain local on your device
- No upload — files are not sent anywhere
- No automatic posting to Kleinanzeigen.de
- No EXIF/GPS data extraction
- Photos must be manually reviewed before use

## Evidence

See [docs/EVIDENCE.md](docs/EVIDENCE.md) for MVP scaffold and Android draft flow evidence.
