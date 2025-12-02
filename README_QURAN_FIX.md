# Quran Library Compatibility Fix

## Issue
The `quran_library` package version 2.3.1 has a compatibility issue with Flutter 3.32.6 where it uses `AlignmentGeometry.bottomCenter` which doesn't exist. The correct property is `Alignment.bottomCenter`.

## Solution
A fix script has been created to automatically patch this issue.

## How to Apply the Fix

### Option 1: Run the fix script manually
After running `flutter pub get`, run:
```bash
./fix_quran_library.sh
```

### Option 2: Apply fix automatically
The fix has already been applied to the package in your pub cache. If you run `flutter clean` or the package gets updated, you'll need to run the fix script again.

## What the Fix Does
The script replaces `AlignmentGeometry.bottomCenter` with `Alignment.bottomCenter` in the package file:
- File: `quran_library-2.3.1/lib/src/audio/widgets/ayah_audio_widget.dart`
- Line 82: Changes `alignment: AlignmentGeometry.bottomCenter` to `alignment: Alignment.bottomCenter`

## Note
This is a temporary fix until the package maintainers update the package. The fix is applied to the local pub cache and will need to be reapplied if you:
- Run `flutter clean`
- Delete the pub cache
- Update the package version

