# Architecture

KleinPilot is a Flutter Android-first **local draft helper**. It has no backend,
no cloud services, and no network dependencies.

## Layers

```
┌──────────────────────────────────┐
│  UI Layer (screens/)             │
│  - HomeScreen                    │
│  - DraftFormScreen               │
│  - PreviewScreen                 │
│  - SafetyScreen                  │
├──────────────────────────────────┤
│  Service Layer (services/)       │
│  - DraftFormatter                │
├──────────────────────────────────┤
│  Model Layer (models/)           │
│  - Draft (data class)            │
└──────────────────────────────────┘
```

## UI Layer

The UI is built with Material Design 3 components. Navigation uses
`Navigator.push` for screen transitions.

### Screens

| Screen | Purpose | State |
|--------|---------|-------|
| HomeScreen | Dashboard, entry point | Stateless |
| DraftFormScreen | 9-field form for listing draft | Stateful (form state) |
| PreviewScreen | Generated text display + copy/export | Stateless |
| SafetyScreen | Safety guarantees display | Stateless |

## Service Layer

### DraftFormatter

Pure Dart class that takes a `Draft` model and produces a human-readable,
structured text block. No external dependencies, no I/O, no network.

## Model Layer

### Draft

Simple data class with 9 string fields. No persistence in MVP (future: local
SQLite or shared_preferences only, never cloud).

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
| flutter_test | SDK (dev) | Testing | None |
| flutter_lints | ^6.0.0 (dev) | Linting | None |

**No network, analytics, cloud, or automation dependencies.**
