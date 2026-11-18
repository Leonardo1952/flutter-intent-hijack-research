#!/usr/bin/env bash
set -euo pipefail
MODE=${1:?mode: debug|profile|release}
export PATH="$PATH:$HOME/.pub-cache/bin"
cd "$(dirname "$0")/../app"
VERSION=${FLUTTER_VERSION:-3.47.9}
FLUTTER=(fvm spawn "$VERSION")
"${FLUTTER[@]}" --version | { head -1; cat >/dev/null; }
"${FLUTTER[@]}" build apk "--$MODE"
adb ${2:+-s "$2"} install -r "build/app/outputs/flutter-apk/app-$MODE.apk"
