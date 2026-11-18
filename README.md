# Android Intent Hijacking in Flutter (NowBank)

<!-- TODO: add the article thumbnail here, e.g. ![thumb](./thumb.png) -->

Support project for an article about an Android Intent-hardening change in
Flutter: in **release builds**, `FlutterActivity` and `FlutterFragmentActivity`
stop blindly trusting `Intent` extras sent by external apps, and engine flags
passed at runtime are ignored (or rejected, in the CLI's case).

The target is **NowBank**, a fictional banking app that looks like a real one:
balance, statement, product offer, transfer. The vulnerable surface isn't a
screen labeled "Admin" — it comes from a plausible feature: an **embeddable
widget** that partner apps (Open Finance aggregators, digital wallets) embed
via add-to-app to show the NowBank statement inside their own app, after the
OAuth handoff. That widget is an exported Android `Activity`, and it was
forgotten without an `intent-filter` — the real configuration mistake that
this hardening mitigates. It follows the same pattern as
[`flutter-tls-mitm-research`](https://github.com/Leonardo1952/flutter-tls-mitm-research):
the target app behaves like an ordinary app, and the attack only ever arrives
from the outside, never through code the app imports on purpose.

Official references:
- [What's new in Flutter 3.50](https://flutter.dev/blog/whats-new-in-flutter-3-50)
- [Stricter Android entrypoint Intent verification](https://docs.flutter.dev/release/breaking-changes/stricter-android-entrypoint-intent-verification)
- [Restrict Android engine flags in release mode](https://docs.flutter.dev/release/breaking-changes/restrict-android-engine-flags-release-mode)

> Technical details came from a partial read of these pages (some via summary).
> Confirm against the official pages before quoting them in the article.

## Warning

This is an **educational** lab, for research on an already-public Flutter
security change (not the disclosure of a new vulnerability or a 0-day). The
"attacker" app here is `adb shell` itself, running on the same
device/emulator as the target app — there is no attack against a third-party
device, account, or app. Only use this against your own test device or
emulator, never against an app or system that isn't yours or that you don't
have explicit authorization to test.

## Goal

Exploit the case on the version before the hardening. Run the app on
**Flutter 3.47.9** (without the hardening) and demonstrate that an external
app can hijack route, entrypoint, and cached engine via `Intent` extras.

| Build | Flutter | Expected |
|---|---|---|
| release | 3.47.9 | External extras work: route/entrypoint/engine hijacked |

This lab only exercises 3.47.9, the pre-hardening behavior; it does not run
the hardened version live. The ["Confirmation against the official pages"](scripts/README.md#confirmation-against-the-official-pages)
section in `scripts/README.md` summarizes, from Flutter's own docs, what
that hardening changes — treat that part as documentation review, not as
something confirmed in this repository.

The project is **pinned to 3.47.9** via FVM (`app/.fvmrc`). The global SDK is
also 3.47.9.

## Structure

```
flutter-intent-hijack-research/
├── README.md                  # this file
├── scripts/
│   ├── build_and_install.sh   # build + install (debug|profile|release)
│   ├── probe.sh                # fires the "external" Intents via adb
│   └── verify-exported.sh      # reads exported="..." straight from the built APK (aapt dump xmltree)
└── app/                        # Flutter project (Android only) — "NowBank"
    ├── lib/
    │   ├── main.dart              # main() and supportMain() (alternate entrypoint)
    │   ├── core/routes.dart       # routes: /, /statement, /offers/<id>, /diagnostics,
    │   │                          #         /transfer, /support, /session
    │   ├── core/intent_info.dart  # reads the current Intent via MethodChannel
    │   └── screens/                # public, sensitive, and integration-diagnostics screens
    └── android/app/src/main/
        ├── AndroidManifest.xml
        └── kotlin/dev/oxean/banconow/
            ├── MainActivity.kt                # launcher + deep link banconow://connect/...
            ├── PartnerWidgetActivity.kt        # partner widget, exported, no intent-filter (VULNERABLE on purpose)
            ├── PartnerWidgetActivitySecure.kt  # same widget, exported="false" (the FIX)
            ├── SessionWidgetActivity.kt        # exported, with a FIXED engine id in code (getCachedEngineId())
            ├── WidgetHostActivity.kt           # exported, NO fixed id: reads cached_engine_id from the Intent (FlutterActivity default)
            ├── BankApplication.kt              # creates the "authenticated" session engine in cache
            └── IntentReporter.kt                # exposes the Intent to Dart
```

See [`scripts/README.md`](scripts/README.md) for the routes table, the full
10-scenario breakdown, the confirmation against Flutter's official docs,
prerequisites, how to run it end to end, and the current project status.
See [`app/README.md`](app/README.md) for the target app itself.
