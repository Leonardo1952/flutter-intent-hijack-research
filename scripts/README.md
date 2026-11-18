# Scripts

Detailed reference for the attack/build tooling described in the [root README](../README.md).

| Script | What it does |
|---|---|
| `build_and_install.sh` | Builds the APK (`debug`\|`profile`\|`release`) and installs it via `adb` |
| `probe.sh` | Fires the 10 "external" Intents via `adb shell am start`, one per scenario |
| `verify-exported.sh` | Reads `exported="..."` straight from the built APK's compiled manifest (`aapt dump xmltree`) |

### Routes

| Route | Type | Note |
|---|---|---|
| `/`, `/statement`, `/offers/<id>` | public | reachable via legitimate deep link (partner handoff) |
| `/diagnostics` | public | shows the received Intent (action, data, extras, callingPackage) |
| `/transfer` | sensitive | money movement; shouldn't open from an external Intent |
| `/support` | sensitive | internal support panel, with the full customer record |
| `/session` | sensitive | lives in an already-"authenticated" cached engine |

## Scenarios tested (`probe.sh`)

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
- An Android emulator or device to run the app and `probe.sh`.
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
./build_and_install.sh release   # install step fails harmlessly with no device attached

# root-cause proof straight from the compiled artifact (not the source code)
./verify-exported.sh ../app/build/app/outputs/flutter-apk/app-release.apk

# emulator
emulator -avd Medium_Phone &

# install + run the 10 scenarios
./build_and_install.sh release
./probe.sh
```

Uses FVM (`~/.pub-cache/bin/fvm`); the version comes from `FLUTTER_VERSION`
(default, and only tested value, 3.47.9). Output: `logcat` logs in the
terminal and screenshots in `/tmp/banconow_*.png` (copy the ones used in the
article into a `docs/` folder).

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
      with the current (English, rewritten) screens in `../docs/fase1-3.47.9/`
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
      `../docs/fase1-3.47.9/05b-activity-not-exported-logcat.png`, a rendered
      capture of the actual `SecurityException: ... not exported from uid`
      confirmed live on the emulator
