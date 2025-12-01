# Changelog

All notable changes to the Bling Azkar project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-12-01

### Added

#### Core Features
- **Azkar Library**: 33 authentic Islamic remembrances in JSON format
- **Categories**: Morning, Evening, After Prayer, Before Sleep, General
- **Bilingual Support**: Arabic and English text with translations
- **Audio Playback**: just_audio integration for offline playback
- **Local Notifications**: Scheduled reminders with custom sounds
- **Local Storage**: Hive-based persistence for preferences and reminders
- **Download Manager**: Dio-based audio file downloads with progress tracking

#### UI Screens
- **Home Screen**: Categories, search, tabs (All/Favorites/Recent), azkar list
- **Zikr Detail Screen**: Full text display, translation, audio preview, reminder setting
- **Player Screen**: Full audio playback with controls, repetition counter, progress indicator

#### UI Components
- **CategoryCard**: Horizontal scrolling category cards with gradients
- **ZikrListItem**: Animated list item with Hero transition, favorite toggle
- **AnimatedPlayButton**: Custom play/pause button with scale and rotation animations

#### Design & UX
- **App Theme**: Complete light/dark mode with Islamic aesthetic (green/teal + gold)
- **Typography**: Custom Arabic font (Amiri) with generous line-height
- **Animations**: Hero transitions, animated counters, play button morphing, pulse effects
- **Gradients**: Primary, gold, and card gradients throughout
- **Accessibility**: RTL support, scalable text, high contrast, large touch targets

#### Services
- **NotificationService**: flutter_local_notifications with zonedSchedule support
- **AudioPlayerService**: just_audio wrapper with session management
- **DownloadService**: File download/delete with progress tracking
- **StorageService**: Hive wrapper for all local data operations

#### Data Layer
- **AzkarRepository**: JSON loading, caching, search, category filtering
- **Domain Models**: Freezed models for Zikr, Reminder, Sheikh, UserPreferences
- **Clean Architecture**: Separated domain, data, and presentation layers

#### Platform-Specific
- **Android**: Material Design 3, native notification sounds setup
- **iOS**: Cupertino elements, iOS notification sound documentation

### Documentation
- Comprehensive README with setup, build, and testing instructions
- DESIGN.md with full design specification and screen mockups
- Platform-specific limitations and workarounds documented
- Code generation setup for Freezed and JSON serialization

### Testing
- Unit test structure for repositories and services
- Widget test structure for screens
- Integration test placeholder for notification flow

## Known Issues

### iOS Limitations
- Notification sounds limited to 30 seconds (platform limitation)
- Background audio requires app to be brought to foreground
- Cannot dynamically change notification sounds without rebuild

### Android Limitations
- Exact alarms require special permission on Android 12+
- Battery optimization may affect interval reminders

### Missing Features (Planned for v1.1)
- Settings screen not fully implemented
- Reminders screen (list/edit/delete) not implemented
- Sounds/Sheikh management screen not implemented
- No audio files included (only placeholders)
- build_runner code generation not run (requires manual step)
- No unit/widget tests written (only structure created)
- No CI/CD configuration

## [Unreleased]

### Planned for v1.1
- Complete Settings screen (language, DND, permissions, storage)
- Complete Reminders screen (list, edit, delete, toggle)
- Sounds screen for sheikh management
- Sample audio files for all categories
- Complete test suite (unit, widget, integration)
- CI/CD with GitHub Actions
- App icons and splash screens

### Planned for v2.0
- Cloud sync for favorites and reminders
- Custom azkar creation
- More sheikh voices
- Hadith of the day
- Prayer times integration
- Tasbih counter
- Statistics and streaks

---

**Initial Release**: December 1, 2025  
**License**: MIT  
**Platform**: Flutter 3.3.0+
