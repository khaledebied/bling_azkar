# Category Card UI Update & Emoji Integration Guide

## Changes Made

### 1. Consistent Color Scheme
- **Before**: Category cards used various colors based on category hash
- **After**: All category cards now use a beautiful, consistent emerald-to-teal gradient
  - Light mode: White background with shadow (matching zikr items)
  - Dark mode: Subtle versions of the same gradient with transparency

### 2. Emoji-Based Icons
- **Replaced Material Icons with Muslim Emojis** from [emojidb.org/muslim-emojis](https://emojidb.org/muslim-emojis)
- All category cards now use emojis as text instead of icons
- Better categorization of emojis based on Islamic concepts:
  - 🤲 (Praying hands) for prayer-related categories
  - 🕌 (Mosque) for mosque and adhan categories
  - 🌙 (Moon) for evening, sleep, and fasting categories
  - 🌅 (Sunrise) for morning categories
  - 📿 (Prayer beads) for dhikr categories
  - 💧 (Water drop) for Wudu categories
  - And more...

### 3. Enhanced Card Design
- White background in light mode (matching zikr items)
- Elegant shadows matching zikr item style
- Emoji container with subtle gradient background
- Refined typography and spacing
- Consistent 20px border radius

## Emoji Mapping

The app uses the following emoji mappings for categories:

| Category Type | Emoji | Usage |
|-------------|-------|-------|
| Morning | 🌅 | Sunrise for morning azkar |
| Evening | 🌙 | Moon for evening azkar |
| Sleep | 🌙 | Moon for sleep azkar |
| Waking Up | ☀️ | Sun for waking up |
| Prayer | 🤲 | Praying hands for prayer azkar |
| Mosque/Adhan | 🕌 | Mosque for mosque-related azkar |
| Wudu | 💧 | Water drop for wudu azkar |
| Home | 🏠 | Home for home-related azkar |
| Food | 🍽️ | Food for food-related azkar |
| Fasting | 🌙 | Moon for fasting azkar |
| Travel | ✈️ | Airplane for travel azkar |
| Health | 🤲 | Praying hands for healing azkar |
| Dhikr | 📿 | Prayer beads for dhikr |
| Dua | 🤲 | Praying hands for supplications |
| Default | 📿 | Prayer beads as default |

## How to Update Emojis

To change or add emojis for categories, edit the `_getCategoryEmoji()` method in `lib/src/presentation/widgets/category_card.dart`:

```dart
String _getCategoryEmoji(String categoryName) {
  final lowerName = categoryName.toLowerCase();
  
  if (lowerName.contains('your_category')) {
    return '🕌'; // Your emoji here
  }
  
  // Add more mappings...
  
  return '📿'; // Default emoji
}
```

## Available Muslim Emojis

You can find more Muslim emojis at:
- [emojidb.org/muslim-emojis](https://emojidb.org/muslim-emojis)

Popular emojis used:
- 🕌 (Mosque)
- 🕋 (Kaaba)
- 🤲 (Praying hands)
- 🌙 (Moon)
- ☪️ (Crescent moon)
- 📿 (Prayer beads)
- And many more...

## Color Scheme

The app now uses a consistent, elegant color scheme:
- **Primary Gradient**: `#059669` → `#10B981` → `#14B8A6`
- Works beautifully in both light and dark modes
- All category cards share the same gradient for visual consistency

## Benefits

✅ **Consistent Visual Identity**: All cards look cohesive
✅ **Better UX**: Users can focus on content, not varied colors
✅ **Professional Look**: Elegant gradient design
✅ **Easy Icon Integration**: Simple structure for adding custom icons
✅ **Theme Support**: Works perfectly in light and dark modes

