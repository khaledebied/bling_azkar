# App Icon and Notification Icon Setup Guide

## Overview
This guide will help you set up the app icons for Android and iOS, as well as the notification icon for Android.

## Prerequisites
- A 1024x1024 PNG image of your app icon (the "Noor - نُور" logo)
- A simplified white/transparent notification icon (24x24 to 96x96 pixels)

## Step 1: Prepare Your Icons

### App Icon
1. Create or obtain a 1024x1024 PNG image of your app icon
   - Should include: Dark green mosque arch, golden crescent moon and star, "NOOR" text
   - Format: PNG with transparency
   - Size: 1024x1024 pixels

### Adaptive Icon Foreground (Android)
1. Create a 1024x1024 PNG image for the foreground layer
   - Same design as app icon but optimized for Android adaptive icons
   - May need padding around edges (Android will add background)
   - Format: PNG with transparency

### Notification Icon (Android)
1. Create a simplified, monochrome icon
   - White color on transparent background
   - Simple design (crescent and star, or mosque arch silhouette)
   - Recommended sizes: 24x24, 48x48, 72x72, 96x96 pixels
   - Or create a single 192x192 version (Android will scale it)

## Step 2: Place Icon Files

1. **App Icons:**
   - Place `app_icon.png` (1024x1024) in `assets/icon/`
   - Place `app_icon_foreground.png` (1024x1024) in `assets/icon/`

2. **Notification Icon:**
   - Place `ic_notification.png` in `android/app/src/main/res/drawable/`
   - Or create multiple sizes in density-specific folders:
     - `drawable-mdpi/ic_notification.png` (24x24)
     - `drawable-hdpi/ic_notification.png` (36x36)
     - `drawable-xhdpi/ic_notification.png` (48x48)
     - `drawable-xxhdpi/ic_notification.png` (72x72)
     - `drawable-xxxhdpi/ic_notification.png` (96x96)

## Step 3: Generate Icons

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Generate app icons:**
   ```bash
   flutter pub run flutter_launcher_icons
   ```

   This will automatically:
   - Generate all Android icon sizes in `android/app/src/main/res/mipmap-*/`
   - Generate all iOS icon sizes in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

## Step 4: Verify and Rebuild

1. **Clean the project:**
   ```bash
   flutter clean
   ```

2. **Get dependencies:**
   ```bash
   flutter pub get
   ```

3. **Rebuild the app:**
   ```bash
   flutter run
   ```

## Step 5: Test Notifications

After setting up the icons, test that notifications display correctly:
1. Open the app
2. Go to Settings
3. Enable notifications
4. Set a test reminder
5. Verify the notification icon appears correctly

## Troubleshooting

### Icons not updating?
- Make sure you've run `flutter clean` before rebuilding
- For Android: Uninstall the app completely, then reinstall
- For iOS: Clean build folder in Xcode (Product > Clean Build Folder)

### Notification icon not showing?
- Ensure `ic_notification.png` is in `android/app/src/main/res/drawable/`
- Check that the icon is white/transparent (monochrome)
- Verify the file name matches exactly: `ic_notification.png`

### Adaptive icon issues?
- Ensure `app_icon_foreground.png` has proper padding
- The background color is set to white (#FFFFFF) in `pubspec.yaml`
- Test on different Android devices as adaptive icons can vary

## File Structure

```
bling_azkar-1/
├── assets/
│   └── icon/
│       ├── app_icon.png (1024x1024)
│       ├── app_icon_foreground.png (1024x1024)
│       └── README.md
├── android/
│   └── app/
│       └── src/
│           └── main/
│               └── res/
│                   ├── drawable/
│                   │   └── ic_notification.png
│                   └── mipmap-*/
│                       └── ic_launcher.png (generated)
└── ios/
    └── Runner/
        └── Assets.xcassets/
            └── AppIcon.appiconset/
                └── Icon-App-*.png (generated)
```

## Notes

- The `flutter_launcher_icons` package handles all icon generation automatically
- iOS uses the same icon for notifications (no separate notification icon needed)
- Android requires a separate, monochrome notification icon
- All generated icons will be based on your source `app_icon.png` file

