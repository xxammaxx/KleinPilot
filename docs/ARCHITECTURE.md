# Architecture

KleinPilot is a Flutter Android-first **local draft helper**. It has no backend,
no cloud services, and no network dependencies.

## Layers

```
┌──────────────────────────────────┐
│  UI Layer (screens/)             │
│  - HomeScreen (Stateful)          │
│  - DraftFormScreen (Stateful)     │
│  - PreviewScreen                  │
│  - SafetyScreen                   │
├──────────────────────────────────┤
│  Service Layer (services/)       │
│  - DraftFormatter                │
│  - DraftStorage                  │
├──────────────────────────────────┤
│  Model Layer (models/)           │
│  - Draft (data + persistence)    │
└──────────────────────────────────┘
```

## UI Layer

The UI is built with Material Design 3 components. Navigation uses
`Navigator.push` for screen transitions.

### Screens

| Screen | Purpose | State |
|--------|---------|-------|
| HomeScreen | Dashboard, entry point, draft list | Stateful (async load) |
| DraftFormScreen | 9-field form for listing draft, save + preview | Stateful (form state, async save) |
| PreviewScreen | Generated text display + copy/export/save | Stateless |
| SafetyScreen | Safety guarantees display | Stateless |

## Service Layer

### DraftFormatter

Pure Dart class that takes a `Draft` model and produces a human-readable,
structured German text block. No external dependencies, no I/O, no network.

Formatting rules:
- Title is the heading (no "Titel:" prefix)
- Description is a natural intro sentence (no "Beschreibung:" prefix)
- Section headers for condition, defects, included items, price, handover, location
- Proper singular/plural for photo count ("1 Foto" / "2 Fotos")
- Empty/whitespace-only fields are silently omitted
- Manual review notice always printed at end

Future: Template modes (spare parts, electronics, furniture, bikes, etc.) could
specialize intro sentences and section ordering, but are deferred to keep the
current pass small and testable.

### DraftStorage

Service for local-only draft persistence via SharedPreferences.
Stores drafts as a JSON array under a single key. No network, no cloud sync.

- `loadDrafts()` — loads all saved drafts, sorted by recency
- `saveDraft(draft)` — creates or updates a draft with local ID
- `deleteDraft(id)` — removes a single draft
- `clearAllDrafts()` — removes all drafts (test helper)

Corrupted JSON returns an empty list without crashing.

## Model Layer

### Draft

Data class with 9 string fields, a list of local photo file paths,
and optional persistence fields (id, createdAt, updatedAt).

- `toJson()` / `fromJson()` for serialization
- `copyWith()` for immutable updates
- `id` is null for unsaved drafts; assigned on first save

No persistence in MVP (future: local SQLite or shared_preferences only, never cloud).

### Photo Attachments

Photo attachments are local draft metadata. File paths are stored as `List<String>`
in the Draft model. KleinPilot does NOT upload photos or integrate with Kleinanzeigen.de.
No EXIF/GPS data is extracted — only file paths are referenced.

## No Platform Automation

KleinPilot does **not** automate:

- Kleinanzeigen.de login
- Kleinanzeigen.de posting
- Kleinanzeigen.de search/scraping
- Kleinanzeigen.de messaging
- Any other platform interaction

It is strictly a manual preparation tool. The user must review and manually
paste the output into their platform of choice.

## Dependencies

| Package | Version | Purpose | Risk |
|---------|---------|---------|------|
| flutter | SDK | Framework | Core |
| cupertino_icons | ^1.0.8 | iOS-style icons | None |
| image_picker | ^1.2.3 | Local gallery photo selection | None — intent-based |
| shared_preferences | ^2.5.5 | Local draft persistence (JSON) | None — Android SharedPreferences |
| flutter_test | SDK (dev) | Testing | None |
| flutter_lints | ^6.0.0 (dev) | Linting | None |

## Local Draft Persistence

Drafts are stored locally on the device using SharedPreferences as a JSON array.
KleinPilot does not sync drafts to a server and does not require an account.
All draft data remains exclusively on the device.
