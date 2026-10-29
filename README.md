# Ginkgo Camera + Mic Fix (Redmi Note 8 / LineageOS 24)

إصلاح كاميرا وميكروفون **Redmi Note 8 (ginkgo)** على **LineageOS 24 / Android 17**.

المشكلة: الكاميرا الخلفية الرئيسية S5KGM1 معطوبة فيزيائيًا، ويتسبب تحميلها في انهيار
`cameraserver` وظهور شاشة سوداء. كذلك ميكروفون مكالمات VoIP لا يعمل بسبب Fluence.

هذا الموديول:

- يعطّل الكاميرا الخلفية الرئيسية المعطوبة (S5KGM1) والماكرو 2MP.
- يجعل الكاميرا الواسعة **OV8856 8MP** هي كاميرا الخلفية الافتراضية (API camera 0).
- يعطّل Fluence (`ro.vendor.audio.sdk.fluencetype=none`) ليعمل الميكروفون.
- **يبقى فعّالًا بعد تحديثات LineageOS OTA** (الموديول يعيد التطبيق عند كل إقلاع).

---

## المحتويات

```
module/                                  مصدر موديول Magisk
  module.prop
  post-fs-data.sh                        يضبط خاصية الصوت عند كل إقلاع
  system/vendor/etc/camera/camera_config.xml
scripts/reapply.sh                       إعادة الإصلاح يدويًا بعد OTA (بدون Magisk)
scripts/build-module.sh                  بناء ملف الـ zip
```

## التركيب

1. حمّل `camera-fix-ginkgo.zip` من صفحة **Releases**.
2. ثبّته من تطبيق Magisk: **Modules → Install from storage**.
3. أعد التشغيل.

> يتطلب جهازًا مفتوح الـ bootloader مع Magisk (v26+). بدون Magisk استخدم `scripts/reapply.sh`
> عبر `adb root`.

## التحقق

```bash
adb shell 'md5sum /vendor/etc/camera/camera_config.xml; getprop ro.vendor.audio.sdk.fluencetype'
# md5: 962432845ca1321fb8a69a3e18308565
# prop: none
```

أو تحقق من الكاميرات:

```bash
adb shell dumpsys media.camera | grep -E "Facing: |availableFocalLengths" -A1
```

المتوقع: كاميرا 0 خلفية بعد بؤري **1.66** (الواسعة)، وكاميرا 1 أمامية **3.51**.

## كيف يعمل

- ملف `camera_config.xml` المرفق هو نسخة من ملف قسم vendor بالجهاز مع تعطيل
  بلوكات الكاميرا المعطوبة (وماكرو) داخل تعليقات XML.
- يضعه Magisk فوق `/vendor/etc/camera/camera_config.xml` عبر Magic Mount،
  فلا يُلمس القسم نفسه ولا تتأثر سلامة OTA.
- `post-fs-data.sh` يعيد ضبط خاصية الصوت في الذاكرة عند كل إقلاع.

## بعد تحديث LineageOS

تحديث OTA يعيد كتابة قسم `/vendor` بالكامل. مع Magisk يبقى الإصلاح تلقائيًا.
إذا أزلت Magisk أو فشل شيء:

```bash
cd ginkgo-camera-mic-fix
./scripts/reapply.sh
```

## إزالة الإصلاح

Magisk app → Modules → **Ginkgo Camera + Mic Fix** → Remove → Reboot.

## استعادة الحالة الأصلية

من داخل الجهاز (النسخ الاحتياطية):

```bash
adb root
adb shell mount -o rw,remount /vendor
adb shell cp /data/local/tmp/camera_config.xml.orig /vendor/etc/camera/camera_config.xml
adb shell cp /data/local/tmp/build.prop.orig /vendor/build.prop
adb reboot
```

## البناء

```bash
./scripts/build-module.sh
# الناتج: dist/camera-fix-ginkgo.zip
```

---

## English

Magisk module for the Xiaomi Redmi Note 8 (ginkgo) that:

- disables the hardware-faulty S5KGM1 rear main camera and the 2 MP macro,
- makes the 8 MP OV8856 ultrawide the default rear camera (camera API id 0),
- disables Fluence so the microphone works in VoIP calls,
- survives LineageOS OTA updates (re-applied by Magisk on every boot).

### Install

Download `camera-fix-ginkgo.zip` from Releases, install it in the Magisk app
(Modules → Install from storage), reboot.

### Verify

```bash
adb shell 'md5sum /vendor/etc/camera/camera_config.xml; getprop ro.vendor.audio.sdk.fluencetype'
# 962432845ca1321fb8a69a3e18308565
# none
```

### How it works

The module ships a patched copy of the device `camera_config.xml` (the S5KGM1
main-camera blocks and the macro block are commented out) and overlays it on
`/vendor/etc/camera/camera_config.xml` with Magisk Magic Mount. A
`post-fs-data.sh` script restores `ro.vendor.audio.sdk.fluencetype=none` at
every boot, because an OTA rewrites `/vendor/build.prop`.

### OTA behaviour

LineageOS OTAs rewrite the whole `/vendor` partition. The module keeps working
because it lives in `/data/adb/modules`. If Magisk is removed, run
`scripts/reapply.sh` over ADB instead.

### Tested on

- Redmi Note 8 (ginkgo), LineageOS 24.0-20261021-NIGHTLY, Android 17
- Vendor `V12.5.12.0.RCOEUXM`
- Magisk v31.1

### Disclaimer

Use at your own risk. The camera configuration file originates from the
device's vendor partition; see `NOTICE.md`.
