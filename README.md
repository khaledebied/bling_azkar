# Bling Azkar - Production-Ready Islamic Azkar App

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.3.0+-blue.svg" alt="Flutter Version" />
  <img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey.svg" alt="Platforms" />
</p>

A beautiful, production-ready mobile application for Islamic remembrances (Azkar/Adhkar) with local notifications, offline audio playback, and a premium user experience.

## ✨ Features

- **📚 Comprehensive Azkar Library**: 33+ authentic Islamic remembrances across 5 categories
- **🔔 Smart Reminders**: Fixed daily times or custom interval notifications with audio
- **🎵 Offline Audio**: Download and play sheikh recitations offline
- **💫 Beautiful UI**: Modern Islamic aesthetic with gradients, animations, and micro-interactions
- **🌙 Dark Mode**: Full light/dark theme support
- **🌍 Bilingual**: Arabic & English interface with RTL support
- **♿ Accessible**: Large tappable areas, scalable text, high contrast
- **📱 Cross-Platform**: Works on Android & iOS with platform-specific optimizations

## 🎯 Flutter Version

This project uses **Flutter 3.3.0+** (stable channel). Compatible with Flutter 3.x and 4.x.

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.3.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / Xcode for emulators
- Android SDK 21+ (for Android)
- iOS 12.0+ (for iOS)

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/bling_azkar.git
   cd bling_azkar
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Generate code** (Freezed models):
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**:
   ```bash
   # Development
   flutter run

   # iOS
   flutter run -d ios

   # Android
   flutter run -d android
   ```

## 📦 Project Structure

```
lib/
├── main.dart                      # App entry point
└── src/
    ├── domain/                    # Domain layer (models)
    │   └── models/
    │       ├── zikr.dart
    │       ├── reminder.dart
    │       ├── sheikh.dart
    │       └── user_preferences.dart
    ├── data/                      # Data layer
    │   ├── repositories/
    │   │   └── azkar_repository.dart
    │   └── services/
    │       ├── notification_service.dart
    │       ├── audio_player_service.dart
    │       ├── download_service.dart
    │       └── storage_service.dart
    ├── presentation/              # UI layer
    │   ├── screens/
    │   │   ├── home_screen.dart
    │   │   ├── zikr_detail_screen.dart
    │   │   └── player_screen.dart
    │   └── widgets/
    │       ├── category_card.dart
    │       └── zikr_list_item.dart
    └── utils/
        └── theme.dart             # App theme & colors
```

## 🎨 Design & UX

### Color Palette
- **Primary**: Soft Green/Teal (#2D7F7B, #4A9B94)
- **Accent**: Gold (#D4AF37)
- **Backgrounds**: Light (#F8F9FA) / Dark (#0F1419)

### Typography
- **Latin**: System font with custom scale
- **Arabic**: Amiri font family (included)

### Animations
- Hero transitions between list and detail
- Animated play/pause button with scale & rotation
- Counter increment with bounce animation
- Smooth fade & slide page transitions

## 🔧 Build Flavors

Build the app for different environments:

### Development
```bash
flutter build apk --flavor dev -t lib/main.dart
flutter build ios --flavor dev -t lib/main.dart
```

### Staging
```bash
flutter build apk --flavor staging -t lib/main.dart
flutter build ios --flavor staging -t lib/main.dart
```

### Production
```bash
flutter build apk --release --flavor prod -t lib/main.dart
flutter build ipa --release --flavor prod -t lib/main.dart
```

## 📱 Platform-Specific Features

### Android
- ✅ Background notifications with custom sounds
- ✅ Optional foreground service for long audio playback
- ✅ Exact alarm scheduling (Android 12+)
- ✅ Material Design 3

### iOS
- ✅ Native notification sounds (max 30 seconds)
- ⚠️ Background audio requires app to be opened from notification
- ✅ Cupertino-style UI elements
- ⚠️ Notification sounds must be in iOS Resources folder

## 🔊 Adding Audio Files

### Bundled Notification Sounds

**Android**: Place short audio files (≤ 1 MB) in:
```
android/app/src/main/res/raw/short_zikr_1.mp3
```

**iOS**: Place audio files in AIFF or CAF format (≤ 30s) in:
```
ios/Runner/Resources/short_zikr_1.aiff
```

### Full Audio Files

Place sheikh recitations in:
```
assets/audio/sh01_morning_1_short.mp3
```

Update `pubspec.yaml` assets section if needed.

## 📊 Testing

### Run All Tests
```bash
flutter test
```

### Run Specific Test Types
```bash
# Unit tests
flutter test test/unit/

# Widget tests
flutter test test/widget/

# Integration tests
flutter test integration_test/
```

### Coverage Report
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## 🔔 Notifications Setup

### Request Permissions
The app automatically requests notification permissions on first launch. Users can also enable/disable from Settings screen.

### Scheduling Reminders
Two types of reminders are supported:

1. **Fixed Daily**: Fires at the same time every day
2. **Interval-Based**: Fires every X minutes/hours

### Testing Notifications

On **emulator**:
- Android: Works normally
- iOS Simulator: Notifications appear in Notification Center

On **physical device**:
1. Set a reminder for 1-2 minutes in the future
2. Close or background the app
3. Wait for notification
4. Tap notification to open player

## 🗄️ Data Storage

### Local Storage (Hive)
- User preferences
- Reminders
- Favorites
- Downloaded audio metadata

### File Storage
Downloaded audio files are stored in:
```
{AppDocumentsDirectory}/audio/{sheikhId}/{zikrId}_${sheikhId}.mp3
```

### Clear All Data
Go to Settings > Storage > Clear All Data

## 🌍 Localization

Currently supports:
- English
- Arabic (RTL)

To add more languages:
1. Add translation strings in `lib/src/utils/localizations.dart`
2. Update `MaterialApp` localization delegates

## 🐛 Known Limitations

### iOS
- **Notification sounds**: Limited to 30 seconds, must be in AIFF/CAF format
- **Background audio**: Requires foreground service or user interaction
- **Dynamic notification sounds**: Cannot change notification sound without rebuilding app resources

###Android
- **Exact alarms**: Android 12+ requires special permission
- **Battery optimization**: May affect reliability of interval reminders

### General
- **Offline only**: No cloud sync (future feature)
- **Fixed azkar library**: Cannot add custom azkar from UI (data is in JSON)

## 🔐 Privacy

- **No analytics by default**: App does not collect user data
- **Local-first**: All data stored on device
- **No internet required**: Works completely offline

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📞 Support

For issues, questions, or feature requests, please open an issue on GitHub.

## 🙏 Credits

- **Arabic Font**: Amiri by Khaled Hosny
- **Audio**: Sample audio files for demonstration purposes
- **Icons**: Material Design Icons

---

**Made with ❤️ for the Muslim community**
