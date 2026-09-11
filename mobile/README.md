# DaySkew Mobile (Flutter)

The Flutter client for the DaySkew scheduler — a headless constraint-based
reflow engine. Renders the computed timeline, the wake-up reflow hero, and the
Pass 2 conflict section.

The UI follows Apple's Human Interface Guidelines (see `design.md`): semantic
system colors that adapt to light/dark, a Cupertino type ramp, grouped inset
lists and cards, familiar sheets and action sheets, and tactile haptics.

## Features

- **Reflow hero** — one-tap "Just Woke Up" stamps the current time and reflows,
  or pick a specific wake time.
- **Timeline** — placed tasks as tier-tinted cards with time column,
  constraint badges, and drift indicators.
- **Needs attention** — unplaceable tasks open an action sheet to Move to
  Tomorrow, Change Time, or Drop.
- **Task management** — create/edit/drop tasks across all CRUD endpoints.

## Install

Public Android builds are published as GitHub Releases:
[github.com/Trephyyy/dayskew/releases](https://github.com/Trephyyy/dayskew/releases).
On a version tag push (`v*`), a workflow builds the APK and attaches
`DaySkew-<tag>.apk` automatically.

## Run

```sh
flutter pub get
flutter run
```

The app targets the public API by default (`https://dayskew.danailmihov.com/api`,
whose `/api` prefix is stripped by a reverse proxy on the server). For local
dev, override it (Android emulators reach the host via `10.0.2.2`).

### Environment variables

Values are baked in at **compile time** via `--dart-define`, so they come from
an `.env` file rather than runtime config. Copy the template, fill in values,
then pass the file to Flutter:

```sh
cp .env.example .env
# edit .env ...

flutter run --dart-define-from-file=.env
flutter build apk --release --dart-define-from-file=.env
```

`.env` is gitignored; `.env.example` documents the available keys
(`GOOGLE_CLIENT_ID`, `API_BASE_URL`).

The equivalent one-liner without a file:

```sh
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

Start the backend with `make compose` from the repo root.

## Google Calendar (Save Day)

"Saving a day" writes the computed timeline into your Google Calendar via the
Google Calendar API (OAuth). It keeps events in a dedicated **DaySkew**
calendar that's auto-created on first save.

Requirements:
1. In [Google Cloud Console](https://console.cloud.google.com):
   - Enable the **Google Calendar API** for your project.
   - Create an **OAuth 2.0 Web client ID** (for `GOOGLE_CLIENT_ID` below).
   - Create an **OAuth 2.0 Android client** for package `dev.dayskew.dayskew`
     using your release keystore **SHA-1** fingerprint.
2. Pass the web client id at build time (inline, or via `.env`):

```sh
flutter build apk --release --dart-define=GOOGLE_CLIENT_ID=xxxx.apps.googleusercontent.com
# or: flutter build apk --release --dart-define-from-file=.env
```

Without a configured client id, the save button shows an explanatory
sign-in error instead of silently doing nothing.

## Layout

- `lib/src/models/` — Task, PlacedTask, ScheduleResult (mirrors the Go API)
- `lib/src/services/api_client.dart` — stateless REST client
- `lib/src/state/app_controller.dart` — ChangeNotifier app state
- `lib/src/screens/` — home (timeline + reflow) and task management screens
- `lib/src/widgets/` — reflow hero, timeline cards, conflict section, buttons,
  cards/section headers, badges, picker sheets, toasts
- `lib/src/theme/` — semantic color system and typography tokens
- `lib/src/utils/time_format.dart` — minutes-since-midnight formatting

## Test

```sh
flutter analyze
flutter test
```