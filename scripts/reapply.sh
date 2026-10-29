#!/usr/bin/env bash
# Re-apply the ginkgo camera + mic fix to /vendor after a LineageOS OTA
# (which rewrites the whole /vendor partition). Needs root over ADB:
# LineageOS userdebug builds provide it via `adb root`; no Magisk required.
#
# Usage: ./scripts/reapply.sh
set -euo pipefail
cd "$(dirname "$0")/.."

XML="module/system/vendor/etc/camera/camera_config.xml"
[ -f "$XML" ] || { echo "Missing $XML" >&2; exit 1; }

if ! adb get-state >/dev/null 2>&1; then
  echo "No device connected." >&2
  exit 1
fi

adb root >/dev/null 2>&1 || true
sleep 1

echo "Remounting /vendor rw..."
adb shell 'mount -o rw,remount /vendor'

echo "Pushing camera config..."
adb push "$XML" /data/local/tmp/camera_config.xml >/dev/null
adb shell 'cp /data/local/tmp/camera_config.xml /vendor/etc/camera/camera_config.xml && chown root:root /vendor/etc/camera/camera_config.xml && chmod 644 /vendor/etc/camera/camera_config.xml && chcon u:object_r:vendor_configs_file:s0 /vendor/etc/camera/camera_config.xml'

echo "Restoring audio prop..."
adb shell 'if grep -q "^ro.vendor.audio.sdk.fluencetype=" /vendor/build.prop; then sed -i "s/^ro.vendor.audio.sdk.fluencetype=.*/ro.vendor.audio.sdk.fluencetype=none/" /vendor/build.prop; else echo "ro.vendor.audio.sdk.fluencetype=none" >> /vendor/build.prop; fi'

echo "Verifying..."
adb shell 'grep -c DISABLED /vendor/etc/camera/camera_config.xml; grep "^ro.vendor.audio.sdk.fluencetype=" /vendor/build.prop'

echo "Rebooting..."
adb reboot
