# Bling Azkar - Design Specification

## Overview

Bling Azkar is designed with a modern Islamic aesthetic that combines elegance, accessibility, and spiritual focus. The app prioritizes beautiful typography for Arabic text, calming color palettes, and subtle animations that enhance rather than distract from the content.

## Design Principles

1. **Clarity**: Arabic text is always displayed prominently with high contrast
2. **Calming**: Soft colors and gentle animations create a peaceful experience
3. **Accessibility**: Large tappable areas, scalable text, RTL support
4. **Beautiful**: Premium aesthetics that inspire users to engage daily

## Color Palette

### Primary Colors
- **Primary Green**: `#2D7F7B` - Main brand color, represents growth and peace
- **Primary Teal**: `#4A9B94` - Lighter variant for accents
- **Accent Gold**: `#D4AF37` - Highlights and special elements
- **Dark Green**: `#1A5653` - Darker variant for emphasis

### Neutral Colors
- **Background Light**: `#F8F9FA` - Light mode background
- **Background Dark**: `#0F1419` - Dark mode background
- **Card Light**: `#FFFFFF` - Light mode cards
- **Card Dark**: `#1C2128` - Dark mode cards
- **Text Primary**: `#1A1A1A` - Main text color
- **Text Secondary**: `#6B7280` - Secondary text
- **Text Light**: `#FFFFFF` - Text on dark backgrounds

### Gradients
- **Primary Gradient**: Green → Teal (top-left to bottom-right)
- **Card Gradient**: White → Light Gray (subtle depth)
- **Gold Gradient**: Gold → Bright Gold (highlights)

## Typography

### Arabic Text (Amiri Font)
- **Large**: 24px, line-height 1.8
- **Medium**: 18px, line-height 1.8
- **Small**: 16px, line-height 1.8

> Arabic text always uses generous line-height for readability

### Latin Text (System Font)
- **Headline Large**: 32px, bold, -0.5 letter-spacing
- **Headline Medium**: 24px, bold
- **Title Large**: 22px, semi-bold
- **Title Medium**: 18px, semi-bold
- **Body Large**: 16px, normal, 1.5 line-height
- **Body Medium**: 14px, normal, 1.5 line-height
- **Caption**: 12px, normal, 0.2 letter-spacing

## Spacing & Layout

### Padding
- **Screen edges**: 16-24px
- **Card internal**: 16-24px
- **List items**: 12-16px
- **Small elements**: 8-12px

### Border Radius
- **Cards**: 20-24px (soft rounded)
- **Buttons**: 16px
- **Small containers**: 12px
- **Circles**: 50% (perfect circles)

### Shadows
- **Light**: `rgba(0,0,0,0.06)` blur 8px, offset (0, 2)
- **Medium**: `rgba(0,0,0,0.08)` blur 12px, offset (0, 4)
- **Heavy**: `rgba(0,0,0,0.1)` blur 16px, offset (0, 4)

## Screen Designs

### 1. Home Screen

**Layout**:
- Gradient app bar (120px expanded)
- Welcome banner with gold gradient
- Horizontal scrolling category cards
- Tab bar (All, Favorites, Recent)
- Vertical list of azkar items

**Key Elements**:
- Search bar with white background + shadow
- Category cards: 160x140px with icon + bilingual labels
- Zikr list item: Hero-tagged, shows Arabic title, English subtitle, text preview, repetition count badge
- Floating action button: "Reminders"

**Colors**:
- App bar: Primary gradient
- Search bar: White with shadow
- Category cards: Card gradient
- Zikr items: White cards with subtle shadows

### 2. Zikr Detail Screen

**Layout**:
- Hero-animated gradient app bar (200px expanded)
- Title section (Arabic + English)
- Arabic text card (white background)
- Translation card (teal background)
- Repetition section (gold gradient)
- Audio preview list
- Set reminder button

**Key Elements**:
- Hero transition from list item
- Fade-in animation for content
- Large Arabic text (right-aligned, high line-height)
- Audio preview: List tiles with play icons
- Bottom sheet modal for reminder options

**Colors**:
- App bar: Primary gradient
- Arabic card: White
- Translation card: Teal #50 + border
- Repetition: Gold gradient
- Audio items: White cards

### 3. Player Screen

**Layout**:
- Full-screen gradient background
- Floating back button (top-left)
- Title (Arabic + English)
- Large Arabic text in frosted container
- Circular counter with increment buttons
- Progress circle indicator
- Bottom sheet with audio controls

**Key Elements**:
- Animated play/pause button (72x72 circle)
- Counter: 140x140 white circle, animated number switching
- Progress indicator: 200x200 circular progress
- Seek bar with custom thumb
- +/- buttons for counter

**Colors**:
- Background: Primary gradient (full screen)
- Text container: White 15% opacity + border
- Counter: White circle
- Controls sheet: White with shadow
- Play button: Primary gradient

**Animations**:
- Pulse animation on play button
- Scale animation on counter increment
- Rotation + fade on play/pause icon switch
- Smooth seek bar interaction

### 4. Reminders Screen (Not fully implemented in this version)

**Layout**:
- Standard app bar
- List of reminder cards
- Each card: Zikr title, schedule info, toggle switch
- Empty state with icon

**Key Elements**:
- Toggle switch for active/inactive
- Swipe-to-delete gesture
- Tap to edit
- FAB to add new reminder

## Animations & Micro-interactions

### Hero Animations
- List item → Detail screen (on zikr card)
- Maintains visual continuity

### Animated Play Button
- **Scale**: 1.0 → 1.1 on tap (150ms)
- **Icon transition**: Rotate + fade (300ms)
- **Shadow**: Pulsing glow effect

### Counter Increment
- **Number**: Scale transition with AnimatedSwitcher (300ms)
- **Container**: Subtle pulse on increment

### List Item Tap
- **Scale**: 1.0 → 0.95 on tap down (200ms)
- **Bounce back**: On release

### Page Transitions
- **Fade**: 800ms ease-in for content
- **Slide**: Bottom sheets slide up with curve

## Accessibility

### Touch Targets
- Minimum 48x48 pixels for all interactive elements
- Comfortable spacing between tappable items

### Text Scaling
- All text respects device font size settings
- Layout adjusts for larger text

### Color Contrast
- All text meets WCAG AA standards
- Important information uses high contrast

### RTL Support
- Full right-to-left layout for Arabic
- Mirrored navigation elements
- Proper text alignment

## Icon Usage

### Material Icons
- **menu_book**: Category icons
- **favorite / favorite_border**: Favorites
- **notifications_active**: Reminders
- **play_arrow / pause**: Playback
- **repeat**: Repetition
- **translate**: Translation
- **headphones**: Audio

### Icon Sizes
- **Large**: 32-48px (main actions)
- **Medium**: 24px (list items)
- **Small**: 16-20px (inline icons)

## Responsive Design

### Breakpoints
- **Small**: < 600px (phones)
- **Medium**: 600-900px (tablets portrait)
- **Large**: > 900px (tablets landscape)

### Adaptations
- Category cards: 2 columns on tablets
- Zikr list: 2 columns on large tablets
- Player: Larger counter and controls on tablets

## Dark Mode

All colors have dark mode variants:
- Backgrounds: Dark grays
- Cards: Slightly lighter grays
- Text: White/light gray
- Gradients: Slightly desaturated
- Shadows: More pronounced

Automatically follows system theme preference.

---

**Design Goals Achieved**:
✅ Beautiful, modern Islamic aesthetic
✅ Premium feel with gradients and shadows
✅ Smooth, delightful animations
✅ Accessible and inclusive
✅ Calming color palette
✅ Clear information hierarchy
