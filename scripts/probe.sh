#!/usr/bin/env bash
set -u
PKG=dev.oxean.banconow
ADB=(adb ${1:+-s "$1"})

run() {
  local title=$1; shift
  echo; echo "=== $title"
  "${ADB[@]}" shell am force-stop "$PKG"
  "${ADB[@]}" logcat -c
  "${ADB[@]}" shell am start -W "$@" | grep -E "Status|Activity|Error" || true
  sleep 2
  echo "--- logcat (flutter/Intent):"
  "${ADB[@]}" logcat -d | grep -iE "FlutterActivity|FlutterActivityAndFragmentDelegate|FlutterEngine|intent|extra|AndroidRuntime|FATAL|Exception" | grep -i "$PKG\|flutter\|exception\|fatal" | tail -12
  "${ADB[@]}" exec-out screencap -p > "/tmp/banconow_$(echo "$title" | tr -c 'a-zA-Z0-9' '_').png" 2>/dev/null
}

run "1 legitimate deep link"            -a android.intent.action.VIEW -d "banconow://connect/statement"
run "2 route extra -> /transfer"        -n $PKG/.PartnerWidgetActivity --es route /transfer
run "3 dart_entrypoint -> supportMain"  -n $PKG/.PartnerWidgetActivity --es dart_entrypoint supportMain
run "4 cached_engine_id -> session"     -n $PKG/.SessionWidgetActivity --es cached_engine_id session_engine
run "5 activity not exported"           -n $PKG/.PartnerWidgetActivitySecure --es route /transfer
run "6 engine flags via extra"          -n $PKG/.PartnerWidgetActivity --ez trace-startup true --es dart-flags "--enable-asserts"
run "7 dart_entrypoint_args"            -n $PKG/.PartnerWidgetActivity --esal dart_entrypoint_args "--x=1"
run "8 cached_engine_group_id"          -n $PKG/.PartnerWidgetActivity --es cached_engine_group_id session_group
run "9 cached_engine_id without override" -n $PKG/.WidgetHostActivity --es cached_engine_id session_engine
run "10 deep link with malicious extra" -a android.intent.action.VIEW -d "banconow://connect/statement" --es dart_entrypoint supportMain

echo; echo "Screenshots in /tmp/banconow_*.png"
