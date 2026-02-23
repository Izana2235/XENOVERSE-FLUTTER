import 'package:flutter/material.dart';

enum AppThemeMode {
  system,
  light,
  dark,
}

class AppState extends ChangeNotifier {
  AppThemeMode _themeMode = AppThemeMode.system;
  String _currentTab = 'dashboard';
  bool _sidebarExpanded = true;
  Map<String, bool> _expandedMenus = {
    'dashboard': false,
    'products': false,
    'categories': false,
    'inventory': false,
    'reports': false,
    'settings': false,
  };

  AppThemeMode get themeMode => _themeMode;
  String get currentTab => _currentTab;
  bool get sidebarExpanded => _sidebarExpanded;
  Map<String, bool> get expandedMenus => _expandedMenus;

  void setThemeMode(AppThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void switchTab(String tabName) {
    _currentTab = tabName;
    notifyListeners();
  }

  void toggleSidebar() {
    _sidebarExpanded = !_sidebarExpanded;
    notifyListeners();
  }

  void toggleMenu(String menuName) {
    _expandedMenus[menuName] = !(_expandedMenus[menuName] ?? false);
    notifyListeners();
  }

  void expandMenu(String menuName) {
    _expandedMenus[menuName] = true;
    notifyListeners();
  }

  void collapseMenu(String menuName) {
    _expandedMenus[menuName] = false;
    notifyListeners();
  }
}
