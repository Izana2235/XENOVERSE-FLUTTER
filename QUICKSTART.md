# Quick Start Guide - XENOVERSE Flutter App

## Installation

1. **Install dependencies:**
```bash
cd firstapp
flutter pub get
```

2. **Run the app:**
```bash
flutter run
```

## Features

### ✅ Complete Features Implemented

- **Responsive Design**: Works on mobile (≤600px), tablet, and desktop
- **Dark/Light Theme Toggle**: Manual theme selection + System preference support
- **Sidebar Navigation**: Expandable menu items with submenu support
- **Dashboard Cards**: Four interactive cards with hover effects
- **Settings Panel**: Theme and preference management
- **Header Controls**: Search bar, notifications, messages, profile dropdowns (UI ready)
- **Mobile Overlay**: Smooth sidebar animation with backdrop
- **Smooth Animations**: All transitions match the original CSS

### 📱 Responsive Behavior

- **Mobile (≤600px)**
  - Hamburger menu to toggle sidebar
  - Sidebar appears as overlay
  - Single column layout
  - Auto-close sidebar after navigation

- **Desktop (>600px)**
  - Persistent sidebar
  - Two-column layout
  - All controls visible
  - Smooth transitions

## File Organization

```
lib/
├── main.dart                    # App entry with Provider setup
├── screens/
│   └── home_page.dart          # Main layout
├── widgets/
│   ├── app_header.dart         # Top bar
│   ├── app_sidebar.dart        # Navigation menu
│   ├── dashboard_card_widget.dart
│   ├── settings_tab.dart       # Settings & theme
│   └── placeholder_tab.dart    # Other tabs
├── models/
│   └── app_state.dart          # State management
├── theme/
│   └── app_theme.dart          # Colors & theme
└── constants/
    └── app_constants.dart       # App constants
```

## How to Customize

### Change Theme Colors

Edit `lib/theme/app_theme.dart` in the `AppColors` class:

```dart
static const Color accentLight = Color(0xFF2563EB);  // Change primary color
static const Color bgDark0 = Color(0xFF0B1220);      // Change dark background
```

### Change Responsive Breakpoint

Edit `lib/constants/app_constants.dart`:

```dart
static const double mobileBreakpoint = 600;  // Change this value
```

### Add Content to Tabs

Edit `lib/screens/home_page.dart` - `_buildTabContent()` method:

```dart
case 'products':
  return const MyProductsScreen();  // Replace with actual content
```

### Modify Sidebar Items

Edit `lib/widgets/app_sidebar.dart` - the `items` list:

```dart
static final List<SidebarItem> items = [
  SidebarItem(
    id: 'custom',
    icon: Icons.custom_icon,
    label: 'CUSTOM',
    submenu: ['Item 1', 'Item 2'],
  ),
  // ...
];
```

## State Management

The app uses **Provider** package for state management:

```dart
// Access current state
final appState = context.watch<AppState>();

// Navigate to tab
appState.switchTab('products');

// Toggle theme
appState.setThemeMode(ThemeMode.dark);

// Toggle menu expansion
appState.toggleMenu('products');
```

## Next Steps

1. **Add Backend Integration**: Connect to APIs for real data
2. **Persist Theme**: Add `shared_preferences` to save theme preference
3. **Implement Features**: Add actual product management, inventory, etc.
4. **Add Authentication**: Implement user login/logout
5. **Database**: Add local database for offline support

## Troubleshooting

**Issue**: App crashes on startup
- Run `flutter clean && flutter pub get`

**Issue**: Theme not changing
- Rebuild with `flutter run`
- Check if Provider is properly wrapped in main.dart

**Issue**: Sidebar not showing on desktop
- Check `isMobile` calculation in `home_page.dart`
- Verify `MediaQuery.of(context).size.width`

## Support Files

- `CONVERSION_GUIDE.md` - Detailed conversion documentation
- `README.md` - Original project info

## Need Help?

Refer to:
- [Flutter Documentation](https://flutter.dev/docs)
- [Provider Package](https://pub.dev/packages/provider)
- `CONVERSION_GUIDE.md` in project root
