#!/system/bin/sh
# Runs before the camera provider starts on every boot.
# Restore the audio fix in case an OTA rewrote /vendor/build.prop.
resetprop ro.vendor.audio.sdk.fluencetype none
