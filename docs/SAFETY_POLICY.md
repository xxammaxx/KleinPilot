# Safety Policy

KleinPilot is a **manual draft helper**. It operates entirely locally and does not
interact with Kleinanzeigen.de or any other online platform.

## Allowed

- Local draft creation (title, description, condition, defects, etc.)
- Manual preview of formatted listing text
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

## Dependencies

The app intentionally uses **zero network dependencies**:

- No `http` package
- No `dio` package
- No `webview_flutter`
- No `firebase_*`
- No `sentry_flutter`
- No analytics or crash reporting SDKs

## Privacy

- All data stays on the device
- No account creation required
- No personal data collection
- No location tracking (location is a free-text note, optional)

## Review

This safety policy must be reviewed before any dependency change or feature addition.
