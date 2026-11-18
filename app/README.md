# NowBank

Fictional banking app used as the target in the Android Intent hardening
lab described in the [root README](../README.md).

NowBank is built to look and behave like a real banking app, not a test
harness: balance, statement, a product offer, a transfer flow. None of its
screens mention Intents, exported Activities, or the attack at all — the
proof that something was hijacked comes from the outside (which Activity
handled the request, what the `logcat` says), never from text printed on
screen. That's deliberate: a debug banner reading "ENTRYPOINT HIJACKED"
would defeat the point of demonstrating a realistic app.

## Screens (`lib/screens/`)

| Screen | Route | What it shows |
|---|---|---|
| `HomeScreen` | `/` | Balance, and links to the statement and an offer — the normal landing screen |
| `StatementScreen` | `/statement` | A short list of transactions — the legitimate destination of the partner deep link |
| `OfferScreen` | `/offers/<id>` | A generic product offer |
| `DiagnosticsScreen` | `/diagnostics` | Dumps the Intent that opened the current Activity (action, data, extras, `callingPackage`) — exists for integration debugging, intentionally **not** linked from any visible navigation |
| `TransferScreen` | `/transfer` | A money-transfer form — sensitive, shouldn't be reachable without going through the normal logged-in flow |
| `SupportPanelScreen` | `/support` | A customer record (name, CPF, account, phone, e-mail) — sensitive, meant only for NowBank's own support tooling |
| `SessionScreen` | `/session` | A generic "My account" view, meant to render inside an already-authenticated cached engine |
| `SupportToolApp` | (alternate entrypoint `supportMain()`, not a route) | A support console with a customer search bar — what actually renders if `supportMain()` runs instead of `main()` |

`core/routes.dart` maps routes to screens; `core/intent_info.dart` talks to
the native side over a `MethodChannel` to read the Intent that actually
reached the running Activity.

## Native side (`android/app/.../kotlin/dev/oxean/banconow/`)

Five Activities back these screens — `MainActivity` (the launcher, with the
`banconow://connect/...` deep link), `PartnerWidgetActivity` (the exported
widget left without an `intent-filter` — the vulnerable one), its fixed
counterpart `PartnerWidgetActivitySecure` (`exported="false"`),
`SessionWidgetActivity` (hardcodes a cached engine id) and `WidgetHostActivity`
(same cached-engine behavior, but via `FlutterActivity`'s own default, with
no override in code). `BankApplication` pre-creates the cached "authenticated"
engine; `IntentReporter` exposes the Intent to Dart for `DiagnosticsScreen`.

See [`../scripts/README.md`](../scripts/README.md) for what each of these
Activities is actually vulnerable to, scenario by scenario.

## Running

Pinned to Flutter 3.47.9 via FVM (`.fvmrc`):

```bash
fvm flutter run
```

## Testing

```bash
fvm flutter analyze
fvm flutter test
```

See the root README for the full attack/build scripts (`../scripts/`) and the
scenario-by-scenario walkthrough.
