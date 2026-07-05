# Safety Policy

KleinPilot is a **manual draft helper**. It operates entirely locally and does not
interact with Kleinanzeigen.de or any other online platform.

## Allowed

- Local draft creation (title, description, condition, defects, etc.)
- Local photo attachment to drafts (file paths only, no upload)
- Manual preview of formatted listing text with photo count
- Manual copy to clipboard
- Manual export via dialog
- Owner review before publishing

## Forbidden

- Automated login to any platform
- Automated posting of listings
- Scraping or crawling of any website
- Messaging automation
- Account automation or session management
- CAPTCHA bypass or solving
- Rate-limit bypass
- Terms of Service bypass
- Hidden telemetry or analytics
- Background uploads or services
- Cloud storage or sync
- Collection of third-party personal data
- Buyer message collection
- Any direct HTTP/API integration with Kleinanzeigen.de
- Automatic photo upload or cloud sync
- EXIF/GPS metadata extraction from photos

## Dependencies

The app intentionally uses **zero network dependencies**:

- No `http` package
- No `dio` package
- No `webview_flutter`
- No `firebase_*`
- No `sentry_flutter`
- No analytics or crash reporting SDKs
- `image_picker` (intent-based gallery access, no network for Android)

### Transitive Dependencies
- `http` is a transitive dependency of `image_picker_platform_interface` (used only by web/linux plugins, not compiled into Android APK)

## Privacy

- All data stays on the device
- No account creation required
- No personal data collection
- No location tracking (location is a free-text note, optional)

## Review

This safety policy must be reviewed before any dependency change or feature addition.

## Photo Safety

Photos attached to drafts remain strictly local:

- Photos are stored as local file path references only
- No automatic upload — photos are never sent to any server
- No cloud synchronization
- No EXIF/GPS metadata extraction
- No connection to Kleinanzeigen.de
- Photos must be manually reviewed by the user before any use

The `image_picker` package is used solely for accessing the device gallery
via Android intents. It does not introduce network access for photo operations
on Android.
