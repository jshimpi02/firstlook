# firstlook

**Lock Screen Quotes** — a small iOS app whose entire purpose is a native lock
screen widget that shows one short motivational (or Bhagavad Gita) quote at a
time. The widget sits alongside your other lock screen widgets, on top of
your own wallpaper.

## What's here

- `LockScreenQuotes/` — the main app target. A single settings screen
  (`Views/SettingsView.swift`) that toggles Gita mode, source mixing, and
  general-quote categories. No accounts, no network, nothing else.
- `QuoteWidget/` — the WidgetKit extension target, and the actual point of
  the app. One family only: `.accessoryRectangular`. See
  `QuoteWidget/QuoteTimelineProvider.swift` for the dense daily timeline
  strategy (there's no literal "on wake" event for widgets, so it pre-builds
  one entry every 20-30 minutes across waking hours instead).
- `LockScreenQuotes/Resources/Quotes.json` — the bundled content bank: ~220
  general quotes across five categories, plus Gita paraphrases covering all
  18 chapters. Every entry is ≤ 48 characters so it always fits the widget
  on one line — enforced by `LockScreenQuotesTests/QuoteValidationTests.swift`
  and by a debug-only assertion in `QuoteStore`.
- `LockScreenQuotes/Shared/AppGroupDefaults.swift` — the App Group
  (`UserDefaults(suiteName:)`) bridge the app and widget extension use to
  share settings, since they run in separate processes.

## Requirements

iOS 17+, Swift 5.10+, Xcode 15+. No third-party dependencies.

## Opening the project

Open `LockScreenQuotes.xcodeproj` in Xcode, select a development team for
both the `LockScreenQuotes` and `QuoteWidgetExtension` targets (needed for
the App Group entitlement), and run the `LockScreenQuotes` scheme on a
device or simulator running iOS 17+. Add the widget from the lock screen
editor (long-press → Customize → Lock Screen → add widget → Lock Screen
Quotes).
