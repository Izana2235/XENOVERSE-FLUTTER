import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:firebase_auth/firebase_auth.dart'; 
import 'firebase_options.dart'; 

import 'models/app_state.dart';
import 'widgets/sidebar.dart';
import 'widgets/chatbot.dart';
import 'screens/dashboard_screen.dart';
import 'screens/all_products_screen.dart';
import 'screens/add_product_screen.dart';
import 'screens/categories_screen.dart';

// 🌟 THE FIX: We tell main.dart to ignore the old Inventory screen here...
import 'screens/inventory_screens.dart' hide InventoryReportScreen; 
// ...so that it perfectly loads the upgraded Firebase one from here!
import 'screens/other_screens.dart'; 

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

// ─── App root ─────────────────────────────────────────────────────────────────

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const StoreAdminApp());
}

class StoreAdminApp extends StatefulWidget {
  const StoreAdminApp({super.key});
  @override
  State<StoreAdminApp> createState() => _StoreAdminAppState();
}

class _StoreAdminAppState extends State<StoreAdminApp>
    with WidgetsBindingObserver {
  final AppState _state = AppState();
  bool _isLoggedIn = false;
  bool _showHome = true;
  bool _showRegister = false;
  bool _authChecked = false;
  void _rebuild() => setState(() {});

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    // Check if Firebase already has a current user (persists across refresh)
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Restore last visited route from localStorage
      final savedRoute = html.window.localStorage['last_route'];
      if (savedRoute != null && savedRoute.isNotEmpty) {
        _state.currentRoute = savedRoute;
      }
    } else {
      // Restore pre-login screen so refresh keeps user on login/register
      final savedScreen = html.window.localStorage['pre_login_screen'];
      if (savedScreen == 'login') {
        _showHome = false;
        _showRegister = false;
      } else if (savedScreen == 'register') {
        _showHome = false;
        _showRegister = true;
      }
    }
    setState(() {
      _isLoggedIn = user != null;
      _authChecked = true;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() => setState(() {});

  ThemeMode get _themeMode {
    switch (_state.themePreference) {
      case ThemePreference.light:
        return ThemeMode.light;
      case ThemePreference.dark:
        return ThemeMode.dark;
      case ThemePreference.system:
        return ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Briefly wait for auth check — no spinner, just blank scaffold
    if (!_authChecked) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(backgroundColor: Color(0xFF0F1117)),
      );
    }

    return MaterialApp(
      title: 'Store Admin',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: const Color(0xFFF3F4F6),
        colorScheme: const ColorScheme.light(
            primary: Color(0xFF4B6BFB), surface: Color(0xFFFFFFFF)),
        appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFFFFFFF),
            foregroundColor: Color(0xFF1A1D2E),
            elevation: 1),
        drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFFFAFBFC)),
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F1117),
        colorScheme: const ColorScheme.dark(
            primary: Color(0xFF4B6BFB), surface: Color(0xFF1A1D2E)),
        appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF13162A),
            foregroundColor: Colors.white,
            elevation: 0),
        drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFF13162A)),
      ),
      home: _isLoggedIn
          ? _AdminShell(
              appState: _state,
              onStateChanged: _rebuild,
              onLogout: () async {
                await FirebaseAuth.instance.signOut();
                html.window.localStorage.remove('last_route');
                html.window.localStorage.remove('pre_login_screen');
                setState(() {
                  _isLoggedIn = false;
                  _showHome = true;
                  _showRegister = false;
                });
              },
            )
          : _showHome
              ? HomeScreen(
                  onLogin: () => setState(() {
                    _showHome = false;
                    _showRegister = false;
                    html.window.localStorage['pre_login_screen'] = 'login';
                  }),
                  onCreateAccount: () => setState(() {
                    _showHome = false;
                    _showRegister = true;
                    html.window.localStorage['pre_login_screen'] = 'register';
                  }),
                  appState: _state,
                )
              : _showRegister
                  ? RegisterWizard(
                      appState: _state,
                      onFinished: () => setState(() {
                        _isLoggedIn = true;
                        html.window.localStorage.remove('pre_login_screen');
                      }),
                      onBack: () => setState(() {
                        _showHome = true;
                        _showRegister = false;
                        html.window.localStorage.remove('pre_login_screen');
                      }),
                    )
                  : LoginScreen(
                      appState: _state,
                      onLoginSuccess: () => setState(() {
                        _isLoggedIn = true;
                        html.window.localStorage.remove('pre_login_screen');
                      }),
                      onBack: () => setState(() {
                        _showHome = true;
                        html.window.localStorage.remove('pre_login_screen');
                      }),
                    ),
    );
  }
}

// ─── Shell ────────────────────────────────────────────────────────────────────

class _AdminShell extends StatefulWidget {
  final AppState appState;
  final VoidCallback onStateChanged;
  final VoidCallback onLogout;
  const _AdminShell(
      {required this.appState,
      required this.onStateChanged,
      required this.onLogout});
  @override
  State<_AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<_AdminShell>
    with SingleTickerProviderStateMixin {
  // Overlay sidebar (mobile only)
  bool _sidebarOpen = false;
  late AnimationController _sidebarCtrl;
  late Animation<Offset> _sidebarSlide;
  
  // Screen cache to prevent blinking
  final Map<String, Widget> _screenCache = {};

  @override
  void initState() {
    super.initState();
    _sidebarCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 240));
    _sidebarSlide = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _sidebarCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _sidebarCtrl.dispose();
    super.dispose();
  }

  void _openSidebar() {
    setState(() => _sidebarOpen = true);
    _sidebarCtrl.forward();
  }

  void _closeSidebar() {
    _sidebarCtrl.reverse().then((_) {
      if (mounted) setState(() => _sidebarOpen = false);
    });
  }

  void _resetBtn() {}

  Widget _screen() {
    _resetBtn();
    final route = widget.appState.currentRoute;
    
    // For report screens, use cached widgets to prevent blinking
    final reportRoutes = ['sales_report', 'inventory_report', 'financial_report'];
    if (reportRoutes.contains(route)) {
      if (!_screenCache.containsKey(route)) {
        switch (route) {
          case 'sales_report':
            _screenCache[route] = SalesReportScreen(appState: widget.appState);
            break;
          case 'inventory_report':
            _screenCache[route] = InventoryReportScreen(appState: widget.appState);
            break;
          case 'financial_report':
            _screenCache[route] = FinancialReportScreen(appState: widget.appState);
            break;
        }
      }
      return _screenCache[route]!;
    }
    
    switch (route) {
      case 'dashboard':
        return DashboardScreen(
            appState: widget.appState, onStateChanged: widget.onStateChanged);
      case 'all_products':
        return AllProductsScreen(
            appState: widget.appState, onStateChanged: widget.onStateChanged);
      case 'add_product':
        return AddProductScreen(
            appState: widget.appState, onStateChanged: widget.onStateChanged);
      case 'product_categories':
        return ProductCategoriesScreen(
            appState: widget.appState, onStateChanged: widget.onStateChanged);
      case 'low_stock':
        return LowStockScreen(
            appState: widget.appState, onStateChanged: widget.onStateChanged);
      case 'all_categories':
        return AllCategoriesScreen(
            appState: widget.appState, onStateChanged: widget.onStateChanged);
      case 'add_category':
        return AddCategoryScreen(
            appState: widget.appState, onStateChanged: widget.onStateChanged);
      case 'manage_categories':
        return ManageCategoriesScreen(
            appState: widget.appState, onStateChanged: widget.onStateChanged);
      case 'stock_alerts':
        return StockAlertsScreen(appState: widget.appState);
      case 'stock_history':
        return StockHistoryScreen(appState: widget.appState);
      case 'adjustments':
        return AdjustmentsScreen(
            appState: widget.appState, onStateChanged: widget.onStateChanged);
      case 'orders':
        return OrderHistoryScreen(appState: widget.appState);
        
      case 'settings_theme':
      case 'settings_store':
      case 'settings_account':
      case 'settings':
        return SettingsScreen(
            appState: widget.appState,
            onStateChanged: widget.onStateChanged,
            onLogout: widget.onLogout);
      default:
        return DashboardScreen(
            appState: widget.appState, onStateChanged: widget.onStateChanged);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hamburgerBg =
        isDark ? const Color(0xFF1A1D2E) : const Color(0xFFE4E7EB);
    final hamburgerIconColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 800;

            if (isDesktop) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 72),
                    child: _screen(),
                  ),
                  if (_sidebarOpen) ...[
                    AnimatedBuilder(
                      animation: _sidebarCtrl,
                      builder: (_, __) => GestureDetector(
                        onTap: _closeSidebar,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          color: Colors.black
                              .withOpacity(0.45 * _sidebarCtrl.value),
                        ),
                      ),
                    ),
                    SlideTransition(
                      position: _sidebarSlide,
                      child: GestureDetector(
                        onTap: () {},
                        behavior: HitTestBehavior.opaque,
                        child: Sidebar(
                          appState: widget.appState,
                          onLogout: widget.onLogout,
                          onStateChanged: () {
                            widget.onStateChanged();
                            _closeSidebar();
                          },
                        ),
                      ),
                    ),
                  ],
                  ChatbotWidget(appState: widget.appState),
                  if (!_sidebarOpen)
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Material(
                        color: Colors.transparent,
                        child: GestureDetector(
                          onTap: _openSidebar,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: hamburgerBg,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.18),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(Icons.menu,
                                color: hamburgerIconColor, size: 20),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            }

            return Stack(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 72),
                  child: _screen(),
                ),
                if (_sidebarOpen)
                  AnimatedBuilder(
                    animation: _sidebarCtrl,
                    builder: (_, __) => GestureDetector(
                      onTap: _closeSidebar,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        color:
                            Colors.black.withOpacity(0.45 * _sidebarCtrl.value),
                      ),
                    ),
                  ),
                if (_sidebarOpen)
                  SlideTransition(
                    position: _sidebarSlide,
                    child: GestureDetector(
                      onTap: () {},
                      behavior: HitTestBehavior.opaque,
                      child: Sidebar(
                        appState: widget.appState,
                        onLogout: widget.onLogout,
                        onStateChanged: () {
                          widget.onStateChanged();
                          _closeSidebar();
                        },
                      ),
                    ),
                  ),
                ChatbotWidget(appState: widget.appState),
                if (!_sidebarOpen)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Material(
                      color: Colors.transparent,
                      child: GestureDetector(
                        onTap: _openSidebar,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: hamburgerBg,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.18),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(Icons.menu,
                              color: hamburgerIconColor, size: 20),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}