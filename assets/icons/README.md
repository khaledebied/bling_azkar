# Islamic Icons from Flaticon

This directory is for storing custom Islamic icons downloaded from [Flaticon - Islamic Icons](https://www.flaticon.com/free-icons/islamic).

## How to Add Icons

1. Visit https://www.flaticon.com/free-icons/islamic
2. Download icons in PNG or SVG format
3. Place them in this directory
4. Update `pubspec.yaml` to include the icon assets:
   ```yaml
   flutter:
     assets:
       - assets/icons/
   ```
5. Use them in the app using `Image.asset()` or `SvgPicture.asset()`

## Recommended Icon Categories

- Mosque/Masjid icons
- Prayer beads (Tasbih)
- Crescent moon and star
- Prayer mat
- Quran
- Kaaba
- Hands in prayer (Dua)
- Islamic geometric patterns

## Current Usage

The app currently uses Material Icons, but you can replace them with custom Flaticon icons by:
1. Adding the icon file here
2. Updating `category_card.dart` to use `Image.asset()` instead of `Icon()`

