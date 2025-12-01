# Technical Handoff Notes

## For Future Developers

This document provides essential information for developers taking over or contributing to the Bling Azkar project.

## Architecture Overview

### Clean Architecture Pattern

```
Domain Layer (lib/src/domain/)
  ↓ defines models and contracts
Data Layer (lib/src/data/)
  ↓ implements repositories & services
Presentation Layer (lib/src/presentation/)
  ↓ UI screens and widgets
```

**Key Principle**: Dependencies point inward. Presentation depends on Data, Data depends on Domain.

## Critical Code Paths

### 1. Adding New Azkar

**File**: `assets/azkar.json`

Add new entries following this structure:
```json
{
  "id": "z034",
  "title": {"en": "English Title", "ar": "العنوان العربي"},
  "text": "النص العربي الكامل",
  "translation": {"en": "English translation", "ar": ""},
  "category": "morning",
  "defaultCount": 3,
  "audio": [
    {
      "sheikhId": "sh01",
      "shortFile": "assets/audio/sh01_morning_9_short.mp3",
      "fullFileUrl": "https://cdn.example.com/audio.mp3"
    }
  ]
}
```

**After adding**:
- No code changes needed (JSON is dynamically loaded)
- Add corresponding audio files to `assets/audio/`
- Update `pubspec.yaml` if new audio folder structure

### 2. Adding New Audio Files

#### Bundled Notification Sounds

**Android**:
1. Convert audio to MP3 format
2. Keep file size ≤ 1 MB
3. Place in `android/app/src/main/res/raw/`
4. Filename must be lowercase, no special characters
5. Update `NotificationService.dart`:
   ```dart
   sound: const RawResourceAndroidNotificationSound('your_sound_name'),
   ```

**iOS**:
1. Convert audio to AIFF or CAF format
2. Keep duration ≤ 30 seconds (Apple limitation)
3. Place in `ios/Runner/Resources/` via Xcode
4. Add to Xcode project (don't just drop file)
5. Update `NotificationService.dart`:
   ```dart
   sound: 'your_sound_name.aiff',
   ```

#### Sheikh Audio Files

1. Place MP3 files in `assets/audio/`
2. Follow naming convention: `{sheikhId}_{category}_{number}_short.mp3`
3. Update `azkar.json` to reference new files
4. Optionally add to downloadable sheikh list

### 3. Changing Notification Sounds Dynamically

**Current Limitation**: Notification sounds are bundled resources and cannot be changed at runtime without rebuilding.

**Workaround**:
1. User selects preferred sheikh in Settings
2. When notification fires, tapped notification opens Player with selected sheikh audio
3. Only the notification "ding" uses bundled sound
4. Full playback uses downloaded/selected audio

**Future Enhancement**: Use local file paths for Android notifications (requires additional native code).

### 4. Enabling Android Foreground Service

For automatic audio playback when notification fires (Android only):

1. Uncomment audio_service configuration in `pubspec.yaml`
2. Implement `AudioHandler` class:
   ```dart
   class AzkarAudioHandler extends BaseAudioHandler {
     // Handle play, pause, stop commands
   }
   ```
3. Update `NotificationService` to use foreground service
4. Add foreground service permission to `AndroidManifest.xml`
5. Test battery optimization exemptions

**iOS Note**: iOS does not support this. User must tap notification.

## State Management

### Riverpod Providers (Not Fully Implemented)

**Planned providers**:
```dart
final azkarProvider = FutureProvider<List<Zikr>>((ref) async {
  return AzkarRepository().loadAzkar();
});

final preferencesProvider = StateProvider<UserPreferences>((ref) {
  return StorageService().getPreferences();
});

final remindersProvider = StateProvider<List<Reminder>>((ref) {
  return StorageService().getAllReminders();
});
```

**Current State**: Services are used directly. Refactor to use Riverpod for better state management.

## Code Generation

### Freezed Models

**After modifying any model**:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Models using Freezed**:
- `Zikr`
- `Reminder`
- `Sheikh`
- `DownloadedAudio`
- `UserPreferences`

**Generates**:
- `.freezed.dart` - Immutable classes, copyWith, equality
- `.g.dart` - JSON serialization

## Database Schema (Hive)

### Boxes
- `reminders` - Stores Reminder objects (JSON)
- `preferences` - Stores UserPreferences (JSON)
- `sheikhs` - Stores Sheikh objects (JSON)
- `downloaded_audio` - Stores DownloadedAudio metadata (JSON)

### Migrations
Currently no migration system. If schema changes:
1. Update model with Freezed
2. Regenerate code
3. Handle old data in `StorageService` with try-catch + defaults

## Platform-Specific Code

### Android

**AndroidManifest.xml** permissions needed:
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.VIBRATE"/>
```

**Proguard**: Add rules if using code obfuscation.

### iOS

**Info.plist** required keys:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>Used for audio playback</string>
<key>UIBackgroundModes</key>
<array>
  <string>audio</string>
</array>
```

**Notification Sounds**: Must be added via Xcode, not just file copy.

## Testing Strategy

### Unit Tests
**Priority**:
1. `AzkarRepository` - JSON parsing, search, filtering
2. `NotificationService` - Next scheduled time calculation
3. `StorageService` - CRUD operations

### Widget Tests
**Priority**:
1. `HomeScreen` - Categories render, search works
2. `ZikrListItem` - Favorite toggle, tap navigation
3. `PlayerScreen` - Counter increment, playback controls

### Integration Tests
**Test Flow**:
1. Open app
2. Select a zikr
3. Set a reminder
4. Mock notification firing
5. Tap notification
6. Verify player opens with correct zikr

## Common Issues & Solutions

### Issue: Build fails with Freezed errors
**Solution**: Run `flutter pub run build_runner clean` then rebuild.

### Issue: Notifications don't fire
**Solution**:
- Check permissions granted
- Verify timezone package initialized
- Check DND settings
- Test on physical device (not just emulator)

### Issue: Arabic text not displaying
**Solution**:
- Verify `pubspec.yaml` includes Amiri fonts
- Run `flutter clean` and rebuild
- Check font files exist in `fonts/` directory

### Issue: Audio files not found
**Solution**:
- Verify `pubspec.yaml` assets section includes audio folder
- Run `flutter clean` and `flutter pub get`
- Check file paths are correct (case-sensitive)

## Performance Optimization

### DO:
- ✅ Use `const` constructors where possible
- ✅ Cache expensive operations (azkar list cached in repository)
- ✅ Use `ListView.builder` for long lists
- ✅ Dispose controllers in `dispose()`

### DON'T:
- ❌ Load all audio files at once
- ❌ Rebuild entire widget tree on small state changes
- ❌ Perform heavy operations in build()
- ❌ Create new objects in build() (use final fields)

## Deployment Checklist

### Pre-Release
- [ ] Run `flutter analyze` - Fix all issues
- [ ] Run all tests - `flutter test`
- [ ] Test on physical Android device
- [ ] Test on physical iOS device
- [ ] Test notifications work
- [ ] Test audio playback
- [ ] Test offline mode
- [ ] Update version in `pubspec.yaml`
- [ ] Update CHANGELOG.md

### Android Release
- [ ] Create release keystore
- [ ] Update `key.properties`
- [ ] Build release APK/AAB
- [ ] Test release build
- [ ] Upload to Play Store

### iOS Release
- [ ] Configure signing in Xcode
- [ ] Create app in App Store Connect
- [ ] Build IPA
- [ ] Upload to TestFlight
- [ ] Submit for review

## Support & Maintenance

### Updating Dependencies
- **Monthly**: `flutter pub outdated` and selectively update
- **Major updates**: Test thoroughly, especially:
  - flutter_local_notifications (breaking changes common)
  - just_audio
  - hive

### Monitoring
- **Crash reports**: Integrate Firebase Crashlytics or Sentry
- **Analytics** (optional): Firebase Analytics with user consent

## Contact Previous Developer

For questions about design decisions:
- Email: [Your Email]
- GitHub: [Your GitHub]

---

**Last Updated**: December 1, 2025  
**Author**: Senior Flutter Developer  
**Project Version**: 1.0.0
