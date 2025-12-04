# App Icon Setup Instructions

## Overview
This directory contains the app icons for both Android and iOS platforms.

## Required Files

### 1. App Icon (Main)
- **File:** `app_icon.png`
- **Size:** 1024x1024 pixels
- **Format:** PNG with transparency
- **Description:** This is the main app icon that will be used to generate all platform-specific icons.

### 2. Adaptive Icon Foreground (Android)
- **File:** `app_icon_foreground.png`
- **Size:** 1024x1024 pixels
- **Format:** PNG with transparency
- **Description:** The foreground layer for Android adaptive icons. This should contain the main icon design (the mosque arch with crescent and star, and "NOOR" text).

## Setup Steps

1. **Place your icon files:**
   - Add `app_icon.png` (1024x1024) to this directory
   - Add `app_icon_foreground.png` (1024x1024) to this directory

2. **Generate icons:**
   ```bash
   flutter pub get
   flutter pub run flutter_launcher_icons
   ```

3. **Rebuild the app:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

## Icon Design Guidelines

Based on the "Noor - DAILY AZKAR" logo:
- **Main Icon:** Should include the dark green mosque arch with golden crescent moon and star, plus "NOOR" text
- **Foreground Icon:** Should be the same design but optimized for Android adaptive icons (may need padding)
- **Background:** White (#FFFFFF) for adaptive icon background

## Notes

- The `flutter_launcher_icons` package will automatically generate all required icon sizes for Android and iOS
- Android icons will be placed in `android/app/src/main/res/mipmap-*/`
- iOS icons will be placed in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

