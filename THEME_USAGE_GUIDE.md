# Theme-Aware Text Colors Usage Guide

This app supports both Light and Dark modes. Use the following approaches to ensure text colors adapt properly:

## 🎨 Quick Usage with Extensions

Import the extension:
```dart
import 'package:bling_azkar/src/utils/theme_extensions.dart';
```

Use context extensions:
```dart
Text(
  'Your text',
  style: TextStyle(
    color: context.textPrimary,  // Adapts to theme
  ),
)
```

## 📝 Available Extensions

### Colors
- `context.textPrimary` - Primary text color (black in light, white in dark)
- `context.textSecondary` - Secondary text color (grey variations)
- `context.cardColor` - Card background color
- `context.backgroundColor` - Screen background color

### Helpers
- `context.isDarkMode` - Boolean to check if dark mode
- `context.colors` - Access ColorScheme
- `context.textTheme` - Access TextTheme

## 🎯 Usage Examples

### Basic Text
```dart
// ✅ Good - Adapts to theme
Text(
  'Hello',
  style: AppTheme.titleMedium.copyWith(
    color: context.textPrimary,
  ),
)

// ✅ Alternative - Use Theme.of
Text(
  'Hello',
  style: AppTheme.titleMedium.copyWith(
    color: Theme.of(context).textTheme.titleMedium?.color,
  ),
)

// ❌ Bad - Hard-coded color
Text(
  'Hello',
  style: AppTheme.titleMedium.copyWith(
    color: AppTheme.textPrimary, // Always black!
  ),
)
```

### Conditional Styling
```dart
Text(
  'Content',
  style: TextStyle(
    color: context.isDarkMode 
      ? Colors.white 
      : Colors.black,
  ),
)
```

### Container Backgrounds
```dart
Container(
  color: context.cardColor,
  child: Text(
    'Card content',
    style: TextStyle(color: context.textPrimary),
  ),
)
```

### Icons
```dart
Icon(
  Icons.home,
  color: context.textPrimary,
)
```

## 🛠️ Helper Methods in AppTheme

Direct access (without extensions):
```dart
// Get text color
Color textColor = AppTheme.getTextPrimary(context);

// Get card color
Color cardBg = AppTheme.getCardColor(context);

// Get background color
Color screenBg = AppTheme.getBackgroundColor(context);
```

## 📦 Pre-configured Theme Colors

The theme already provides:
- `Theme.of(context).colorScheme.onBackground` - For text on background
- `Theme.of(context).colorScheme.onSurface` - For text on cards/surfaces
- `Theme.of(context).textTheme.bodyMedium?.color` - Themed text color

## 🎨 Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:bling_azkar/src/utils/theme.dart';
import 'package:bling_azkar/src/utils/theme_extensions.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.backgroundColor,
      child: Card(
        color: context.cardColor,
        child: Column(
          children: [
            // Primary text
            Text(
              'Title',
              style: AppTheme.titleLarge.copyWith(
                color: context.textPrimary,
              ),
            ),
            
            // Secondary text
            Text(
              'Subtitle',
              style: AppTheme.bodyMedium.copyWith(
                color: context.textSecondary,
              ),
            ),
            
            // Icon
            Icon(
              Icons.star,
              color: context.textPrimary,
            ),
          ],
        ),
      ),
    );
  }
}
```

## 🌙 Theme Detection

Check current theme:
```dart
if (context.isDarkMode) {
  // Dark mode specific code
} else {
  // Light mode specific code
}
```

## 📱 Applying to Existing Widgets

Replace hard-coded colors:

### Before:
```dart
Text(
  'Text',
  style: TextStyle(color: AppTheme.textPrimary),
)
```

### After:
```dart
Text(
  'Text',
  style: TextStyle(color: context.textPrimary),
)
```

## ✨ Best Practices

1. ✅ Always use `context.textPrimary` or `AppTheme.getTextPrimary(context)`
2. ✅ Import theme_extensions.dart for cleaner code
3. ✅ Use `Theme.of(context)` for accessing theme properties
4. ❌ Avoid hard-coded colors like `AppTheme.textPrimary` directly
5. ❌ Don't use `Colors.black` or `Colors.white` for text
6. ✅ Test in both light and dark modes

## 🔄 Migration Checklist

For each screen/widget:
- [ ] Replace `AppTheme.textPrimary` with `context.textPrimary`
- [ ] Replace `AppTheme.textSecondary` with `context.textSecondary`
- [ ] Replace `Colors.black` with `context.textPrimary`
- [ ] Replace `Colors.white` with appropriate theme color
- [ ] Check backgrounds use `context.cardColor` or `context.backgroundColor`
- [ ] Test in both light and dark modes

