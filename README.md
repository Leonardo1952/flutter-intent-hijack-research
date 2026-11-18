# Android Intent Hijacking in Flutter (NowBank)

<img width="640" height="338" alt="image" src="https://github.com/user-attachments/assets/eb3d742b-1cb9-4c59-8685-98c259e45ec6" />


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
the hardened version live. The ["Confirmation against the official pages"](#confirmation-against-the-official-pages)
section below summarizes, from Flutter's own docs, what that hardening
changes — treat that part as documentation review, not as something
confirmed in this repository.

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

### Routes

| Route | Type | Note |
|---|---|---|
| `/`, `/statement`, `/offers/<id>` | public | reachable via legitimate deep link (partner handoff) |
| `/diagnostics` | public | shows the received Intent (action, data, extras, callingPackage) |
| `/transfer` | sensitive | money movement; shouldn't open from an external Intent |
| `/support` | sensitive | internal support panel, with the full customer record |
| `/session` | sensitive | lives in an already-"authenticated" cached engine |

## Scenarios tested (`scripts/probe.sh`)

| # | Intent | Target | Risk demonstrated |
|---|---|---|---|
| 1 | `VIEW banconow://connect/statement` | MainActivity | Legitimate deep link — the baseline, unaffected case |
| 2 | extra `route=/transfer` | PartnerWidgetActivity | Navigation to an internal route |
| 3 | extra `dart_entrypoint=supportMain` | PartnerWidgetActivity | Arbitrary entrypoint execution, without login |
| 4 | extra `cached_engine_id=session_engine` | SessionWidgetActivity | Reuse of a pre-authenticated banking session |
| 5 | extra `route=/transfer` | PartnerWidgetActivitySecure | Blocked by Android (`exported="false"`), independent of this hardening |
| 6 | extras `trace-startup`, `dart-flags` | PartnerWidgetActivity | Engine flags injected at runtime |
| 7 | extra `dart_entrypoint_args` | PartnerWidgetActivity | Arbitrary arguments for the entrypoint |
| 8 | extra `cached_engine_group_id` | PartnerWidgetActivity | Engine from a cached group |
| 9 | extra `cached_engine_id=session_engine` | WidgetHostActivity | Session reuse via `FlutterActivity`'s **default** behavior (no fixed id in code) |
| 10 | deep link `VIEW banconow://connect/statement` + extra `dart_entrypoint=supportMain` | MainActivity (via intent-filter) | Entrypoint hijacked even going through the deep link's "trusted" Activity |

## Confirmation against the official pages

Pages read (part of the text came from a summary, since reading truncated
~30% of each docs page; double-check in the browser before quoting literally):

- **Platform:** Android only. No source mentions iOS, web, or desktop as affected.
- **Extras checked (5):** `route`, `dart_entrypoint`, `dart_entrypoint_args`, `cached_engine_id`,
  `cached_engine_group_id` (the blog post only mentions three).
- **Conditions:** release only; only exported Activities (`exported="false"` is trusted);
  Android 14+ compares `getLaunchedFromUid()` against the app's UID; Android 13- compares
  `getCallingPackage()` (requires `startActivityForResult()`/`startActivityIfNeeded()`).
- **When it fails (release):** `route` → meta-data `io.flutter.InitialRoute` or `/`;
  `dart_entrypoint` → `io.flutter.Entrypoint` or `main`; engine args and ids → ignored.
- **Engine flags:** discarded with a log warning in release (the blog says "rejected";
  follow the docs page). Debug/profile accept them. The CLI fails fatally with
  `flutter run --release --use-application-binary` plus flags.
- **Deep links:** need to match an `<intent-filter>`; keep working.
- **Engine created with `FlutterEngine(context, args)`:** programmatic flags still apply.
- **Not captured in this lab:** the exact log warning text on the hardened
  release — this repository only runs 3.47.9 live.

Migration (also from the official pages): `android:exported="false"` where
possible, deep links instead of `route`, `<meta-data io.flutter.InitialRoute /
io.flutter.Entrypoint>` in the manifest, and `getFlutterEngineFlags()`
(replaces `getFlutterShellArgs`) for flags. Also:
`getDartEntrypointFunctionName()`/`getDartEntrypointArgs()` for a dynamic
entrypoint, the `io.flutter.embedding.android.DartFlags` meta-data, and
`startActivityForResult()` for internal launches on Android 13-. In NowBank,
the fix already demonstrated is `PartnerWidgetActivitySecure` (the same
widget, `exported="false"`): the partner would start entering only through
`MainActivity`'s verified deep link, not directly into the widget's Activity.

## Prerequisites

- [FVM](https://fvm.app/) (`dart pub global activate fvm`), with Flutter **3.47.9**
  installed (`fvm install 3.47.9`). The project already pins this as the
  default version in `app/.fvmrc`.
- Android SDK with `adb` on `PATH`, and JDK 17+.
- An Android emulator or device to run the app and `scripts/probe.sh`.
  - **Android 14+ (API 34+)** covers the verification branch that checks the
    UID of whoever launched the Activity (`getLaunchedFromUid()`).
  - **Android 13 or earlier (API ≤ 33)** covers the other branch, which checks
    `getCallingPackage()`. Not yet tested in this repository.

Optional: a separate "attacker" app (a different `applicationId`), for a demo
closer to reality than `adb shell`. Through `adb shell`, the sender is already
a different UID than the target app, which is already enough to reproduce the
same Android security check.

## How to run

```bash
# build only, no emulator needed yet
scripts/build_and_install.sh release   # install step fails harmlessly with no device attached

# root-cause proof straight from the compiled artifact (not the source code)
scripts/verify-exported.sh app/build/app/outputs/flutter-apk/app-release.apk

# emulator
emulator -avd Medium_Phone &

# install + run the 10 scenarios
scripts/build_and_install.sh release
scripts/probe.sh
```

The scripts use FVM (`~/.pub-cache/bin/fvm`); the version comes from
`FLUTTER_VERSION` (default, and only tested value, 3.47.9). Output: `logcat`
logs in the terminal and screenshots in `/tmp/banconow_*.png` (copy the ones
used in the article into a `docs/` folder).

## Current status

- [x] App renamed to NowBank (banking facade, with `PartnerWidgetActivity` /
      `SessionWidgetActivity` / `BankApplication` instead of the earlier
      didactic names)
- [x] Sensitive screens rewritten to look like real banking-app screens (no
      debug/narration text about the attack): `TransferScreen`,
      `SupportPanelScreen`, `SessionScreen`, `SupportToolApp`, and removed the
      "Integration diagnostics" item from the main menu (the `/diagnostics`
      route still exists, it just no longer appears in visible navigation)
- [x] `flutter analyze` and the widget tests, after each restructuring: no
      issues, 2/2 tests passing
- [x] Release build on 3.47.9, `verify-exported.sh` run against
      the compiled APK, `probe.sh` run (10 scenarios), evidence recaptured
      with the current (English, rewritten) screens in `docs/fase1-3.47.9/`
- [x] Closed the gap in scenario 4 (`WidgetHostActivity`, scenario 9: cached
      engine via `FlutterActivity`'s default behavior, no fixed id in code)
- [x] Confirmed that a legitimate deep link with a piggybacking extra hijacks
      the entrypoint even through the "trusted" Activity (scenario 10)
- [x] Validated the real effect of the engine flag extras (scenario 6) and
      scenarios 7/8 in `logcat` — found and fixed a probe bug in scenario 7
      (wrong extra type, needs `--esal` not `--es`/`--esa`) and confirmed
      scenario 8's crash is real (no cached `FlutterEngineGroup` under that
      id in this app), not a probe bug
- [x] Fixed scenario 5's evidence: the screen alone just falls back to the
      home screen and proves nothing by itself; added
      `docs/fase1-3.47.9/05b-activity-not-exported-logcat.png`, a rendered
      capture of the actual `SecurityException: ... not exported from uid`
      confirmed live on the emulator
