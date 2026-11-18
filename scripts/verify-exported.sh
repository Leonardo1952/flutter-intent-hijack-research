#!/usr/bin/env bash
set -euo pipefail
APK=${1:?Usage: scripts/verify-exported.sh <path-to-apk>}
AAPT=$(find "${ANDROID_HOME:-$HOME/Android/Sdk}/build-tools" -name aapt -print -quit)

"$AAPT" dump xmltree "$APK" AndroidManifest.xml | awk '
  /E: activity /      { name="" }
  /android:name\(0x01010003\)="dev\.oxean\.banconow\./ {
    match($0, /dev\.oxean\.banconow\.[A-Za-z]+/)
    full = substr($0, RSTART, RLENGTH)
    name = substr(full, length("dev.oxean.banconow.") + 1)
  }
  /android:exported\(0x01010010\)/ {
    exported = ($0 ~ /0xffffffff/) ? "true " : "false"
    if (name != "") printf "  %-28s exported=%s\n", name, exported
    name=""
  }
'
