# Notification Icon Setup

## Overview
This directory contains the notification icon for Android notifications.

## Required File

### Notification Icon
- **File:** `ic_notification.png`
- **Size:** 24x24 dp (or 48x48, 72x72, 96x96, 144x144, 192x192 pixels for different densities)
- **Format:** PNG with transparency
- **Color:** White/transparent (monochrome)
- **Description:** A simple, monochrome icon that will appear in the notification bar. Should be white on transparent background.

## Design Guidelines

For the "Noor" app, the notification icon should be:
- A simplified version of the app icon (just the crescent and star, or just the mosque arch silhouette)
- White color on transparent background
- Simple and recognizable at small sizes
- No text (too small to read in notifications)

## Recommended Sizes

Create these sizes for different screen densities:
- `ic_notification.png` (mdpi): 24x24 px
- `ic_notification.png` (hdpi): 36x36 px  
- `ic_notification.png` (xhdpi): 48x48 px
- `ic_notification.png` (xxhdpi): 72x72 px
- `ic_notification.png` (xxxhdpi): 96x96 px

Or create a single high-resolution version (192x192) and place it in the `drawable` folder - Android will scale it automatically.

## Alternative: Use Vector Drawable

You can also create a vector drawable (`ic_notification.xml`) for better scaling. This is recommended for crisp icons at all sizes.

