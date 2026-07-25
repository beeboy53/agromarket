# AgroMarket – Real-Time Agricultural Market Price Information (Nigeria)

ND2 Final Year Project — Flutter (Android + Flutter Web, single codebase).

## Phase 1 — Foundation (this delivery)

This phase sets up the project skeleton only: folder structure, dependencies,
theme, colours, routes, and reusable widgets. Screens are placeholders
("Coming Soon") until their respective phase is generated — the app already
**builds and runs** at this stage, it just doesn't have real screens yet.

## Folder Structure

```
agromarket/
├── pubspec.yaml                # All dependencies (Phase 1 list)
├── assets/
│   ├── data/
│   │   └── commodities.json    # Local data source (filled in Phase 3)
│   ├── images/                 # Logo, onboarding illustrations, placeholders
│   └── icons/                  # Category icons
│
└── lib/
    ├── main.dart                # App entry point (Provider + Theme + Routes)
    │
    ├── core/                    # App-wide configuration (no UI screens here)
    │   ├── constants/
    │   │   ├── app_colors.dart   # Colour palette
    │   │   ├── app_strings.dart  # All text labels
    │   │   └── app_assets.dart   # Asset path constants
    │   ├── theme/
    │   │   ├── app_theme.dart     # Material 3 light/dark ThemeData
    │   │   └── theme_provider.dart# Dark/Light mode state (ChangeNotifier)
    │   └── routes/
    │       └── app_routes.dart    # Named routes + route generator
    │
    ├── shared/
    │   └── widgets/              # Small reusable widgets used everywhere
    │       ├── custom_card.dart
    │       ├── custom_button.dart
    │       ├── loading_widget.dart
    │       ├── empty_state_widget.dart
    │       └── section_title.dart
    │
    ├── models/                   # Data models (Commodity, Market, etc.)
    │                              # -> added in Phase 3
    │
    ├── services/                  # JSON loader, Database helper, API client
    │                              # -> added in Phase 3/4
    │
    └── features/                  # One folder per screen/feature (UI only)
        ├── splash/                # -> Phase 2
        ├── onboarding/            # -> Phase 2
        ├── home/                  # -> Phase 2
        ├── commodity/
        │   ├── data/              # -> Phase 3 (JSON repository)
        │   ├── screens/           # -> Phase 3 (list, details, search, filter)
        │   └── widgets/           # -> Phase 3 (commodity card, price chip)
        ├── favourites/            # -> Phase 4
        ├── settings/              # -> Phase 5
        ├── about/                 # -> Phase 5
        └── contact/               # -> Phase 5
```

## Why this structure? (for project defense)

This is a **feature-first, layered folder structure** — simple enough for an
ND2 student to explain, but organised enough to look professional:

- **`core/`** — things the whole app depends on (colours, theme, routes).
  Nothing here depends on any specific screen.
- **`shared/widgets/`** — small, generic UI pieces (a card, a button) reused
  by *many* screens, so the UI stays visually consistent.
- **`models/`** — plain Dart classes that represent data (e.g. a
  `Commodity`), completely separate from UI.
- **`services/`** — code that *fetches or stores* data (reads the JSON file,
  talks to SQLite, and later an HTTP API). Screens never read files or the
  database directly — they always go through a service. This is the key
  design decision that makes it easy to swap local JSON for a real API
  later **without changing a single screen** (Phase 3 will show this).
- **`features/`** — one folder per app screen/module, containing only the
  UI for that feature.

## Important architecture note: SQLite + Flutter Web

`sqflite` (the SQLite package) does **not** work on Flutter Web by itself,
because there is no native SQLite file system in a browser. To keep the app
working from a **single codebase** on both Android and Web, Phase 4 will use:

- `sqflite` on Android (real device/file database), and
- `sqflite_common_ffi_web` on Flutter Web (SQLite compiled to WebAssembly,
  stored in browser storage),

both accessed through **one shared `DatabaseService` class**, so the rest of
the app (Favourites, Offline cache) never needs to know which platform it is
running on. This is already reflected in `pubspec.yaml`.

## Design System (Phase 1)

- **Primary colour:** Green `#2E7D32` — represents agriculture/farming.
- **Secondary colour:** Orange `#FF8F00` — represents market/price highlights.
- **Style:** Material 3, rounded cards (16px radius), soft shadows, light &
  dark theme fully implemented and togglable (see `ThemeProvider`).

## How to run

```bash
flutter pub get
flutter run                # Android device/emulator
flutter run -d chrome       # Flutter Web
```

At this stage every route shows a temporary "Coming Soon" screen — this is
expected and will be replaced screen-by-screen in the next phases.

## Packages used (Phase 1 list, matches pubspec.yaml)

| Package                  | Purpose                                  |
|---------------------------|-------------------------------------------|
| provider                 | State management (theme, favourites, etc.)|
| http                     | Future online API calls                  |
| sqflite / sqflite_common_ffi_web | Offline database (mobile / web)   |
| shared_preferences       | Save theme choice, onboarding flag        |
| intl                     | Format prices and dates                   |
| image_picker             | Used in later phases                      |
| fl_chart                 | Price trend line chart (Phase 3)          |
| url_launcher             | Contact developer (email/phone/socials)   |

---
**Next: Phase 2 — Splash Screen, Onboarding, Home Screen, Bottom Navigation.**
