# Islamic Icons Directory

This directory was previously used for storing custom Islamic icons, but the app now uses **Muslim emojis** instead of icons.

## Current Implementation

The app now uses emojis from [emojidb.org/muslim-emojis](https://emojidb.org/muslim-emojis) as text in the category cards. This provides:
- Better visual consistency
- No need for asset files
- Native emoji support across all platforms
- Easy to update and customize

## If You Want to Use Custom Icons

If you still want to use custom icon files (SVG/PNG), you can:
1. Place them in this directory
2. Update `category_card.dart` to use `Image.asset()` or `SvgPicture.asset()` instead of emoji text
3. Make sure `pubspec.yaml` includes this directory in assets

However, emojis are recommended as they provide better cross-platform support and don't require asset management.

