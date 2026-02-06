## Issue 1: Alignment Compatibility
The `quran_library` package version 2.3.1 has a compatibility issue with Flutter where it uses `AlignmentGeometry.bottomCenter` which doesn't exist. The correct property is `Alignment.bottomCenter`.

## Issue 2: Missing Icons in Release Mode (FIXED)
The package uses Dart reflection (`noSuchMethod`) to load SVG icons. In Release Mode, symbol names are obfuscated or stripped, causing the icon paths to break and icons (play, pause, etc.) to disappear.

## Solution
The `fix_quran_library.sh` script has been updated to:
1. Patch the Alignment issue.
2. Replace the brittle reflection-based icon loading with a stable, static implementation that works in Release Mode.

## How to Apply the Fix
After running `flutter pub get`, run:
```bash
./fix_quran_library.sh
```

## Note
This fix is applied to your local pub cache. If you run `flutter clean` or the package gets updated, you must run the script again.

