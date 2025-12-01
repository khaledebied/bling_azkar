# Audio Assets Setup

This directory contains audio files for the Bling Azkar app.

## Directory Structure

```
assets/audio/
├── sh01_morning_1_short.mp3
├── sh01_morning_2_short.mp3
├── sh01_evening_1_short.mp3
└── ... (other audio files)
```

## Audio File Requirements

### Bundled Audio (Assets)
- **Format**: MP3 (recommended) or AAC
- **Sample Rate**: 44.1 kHz
- **Bitrate**: 128 kbps (good quality, reasonable size)
- **File Size**: ≤ 1 MB per file (for short previews)
- **Duration**: 10-30 seconds for short files, 1-5 minutes for full recitations

### Naming Convention
```
{sheikhId}_{category}_{number}_short.mp3
```

Examples:
- `sh01_morning_1_short.mp3` - Sheikh 01, Morning category, first zikr, short version
- `sh02_prayer_3_full.mp3` - Sheikh 02, Prayer category, third zikr, full version

## Sheikh IDs

Currently supported:
- `sh01` - Default Sheikh (placeholder)

To add more sheikhs:
1. Create new sheikh ID (e.g., `sh02`, `sh03`)
2. Add sheikh info to app's sheikh database
3. Record/source audio files with that sheikh ID prefix

## Adding New Audio Files

### Step 1: Prepare Audio
1. Record or source high-quality Islamic recitation
2. Convert to MP3 format
3. Normalize audio levels
4. Trim silence from beginning/end

### Step 2: Add to Project
1. Place MP3 file in `assets/audio/` directory
2. Follow naming convention
3. Verify file size ≤ 1 MB for short versions

### Step 3: Update JSON
Update `assets/azkar.json` to reference new audio:
```json
{
  "id": "z001",
  "audio": [
    {
      "sheikhId": "sh01",
      "shortFile": "assets/audio/sh01_morning_1_short.mp3",
      "fullFileUrl": "https://cdn.example.com/full_audio.mp3"
    }
  ]
}
```

### Step 4: Rebuild
```bash
flutter clean
flutter pub get
flutter run
```

## Native Notification Sounds

### Android
Place notification sounds in:
```
android/app/src/main/res/raw/short_zikr_1.mp3
```

Requirements:
- Lowercase filename only
- No spaces or special characters
- MP3 format
- ≤ 1 MB

### iOS
Place notification sounds in:
```
ios/Runner/Resources/short_zikr_1.aiff
```

Requirements:
- AIFF or CAF format
- ≤ 30 seconds duration (Apple restriction)
- Add to Xcode project (don't just copy file)

To add via Xcode:
1. Open `ios/Runner.xcworkspace`
2. Right-click Resources folder
3. Add Files to "Runner"
4. Select your .aiff file
5. Ensure "Copy items if needed" is checked

## Placeholder Audio

This repository includes placeholder/empty audio files for demonstration. Replace with actual Islamic recitations before production release.

## Audio Sources

When sourcing audio:
- ✅ Ensure proper permissions and license
- ✅ Verify authentic Islamic sources
- ✅ Credit original reciters appropriately
- ✅ Respect copyright and intellectual property

## Recommended Tools

### Audio Editing
- **Audacity** (free, cross-platform)
- **Adobe Audition** (professional)
- **GarageBand** (Mac)

### Format Conversion
```bash
# MP3 to AIFF (for iOS)
ffmpeg -i input.mp3 -acodec pcm_s16le -ar 44100 output.aiff

# Normalize audio
ffmpeg -i input.mp3 -af loudnorm output.mp3

# Trim silence
ffmpeg -i input.mp3 -af silenceremove=1:0:-50dB output.mp3
```

## Testing Audio

1. Add audio files as described above
2. Run app: `flutter run`
3. Navigate to Zikr Detail screen
4. Tap audio preview
5. Verify playback works
6. Test notification sounds (set a reminder)

## Troubleshooting

### Audio Not Playing
- Verify file path in azkar.json matches actual file location
- Check pubspec.yaml includes `assets/audio/` in assets section
- Run `flutter clean` and rebuild

### Notification Sound Not Playing
- **Android**: Verify file in `res/raw/` folder, lowercase name
- **iOS**: Verify file added to Xcode project, not just copied
- Check notification permissions granted
- Test on physical device (simulators may not play sounds)

---

**Note**: This app is designed for Islamic remembrances. Please ensure all audio content is authentic, properly licensed, and respectful of Islamic traditions.
