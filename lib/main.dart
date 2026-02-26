import 'package:flutter/material.dart';
import 'models/app_state.dart';
import 'widgets/sidebar.dart';
import 'widgets/chatbot.dart';
import 'screens/dashboard_screen.dart';
import 'screens/all_products_screen.dart';
import 'screens/add_product_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/inventory_screens.dart';
import 'screens/other_screens.dart';

void main() => runApp(const StoreAdminApp());

// ─── App root ─────────────────────────────────────────────────────────────────

class StoreAdminApp extends StatefulWidget {
  const StoreAdminApp({super.key});
  @override
  State<StoreAdminApp> createState() => _StoreAdminAppState();
}

class _StoreAdminAppState extends State<StoreAdminApp>
    with WidgetsBindingObserver {
  final AppState _state = AppState();
  void _rebuild() => setState(() {});

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
        drawerTheme:
            const DrawerThemeData(backgroundColor: Color(0xFFFAFBFC)),
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F1117),
        colorScheme: const ColorScheme.dark(
            primary: Color(0xFF4B6BFB), surface: Color(0xFF1A1D2E)),
        appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF13162A),
            foregroundColor: Colors.white,
            elevation: 0),
        drawerTheme:
            const DrawerThemeData(backgroundColor: Color(0xFF13162A)),
      ),
      home: _AdminShell(appState: _state, onStateChanged: _rebuild),
    );
  }
}

// ─── Shell ────────────────────────────────────────────────────────────────────

class _AdminShell extends StatefulWidget {
  final AppState appState;
  final VoidCallback onStateChanged;
  const _AdminShell({required this.appState, required this.onStateChanged});
  @override
  State<_AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<_AdminShell>
    with SingleTickerProviderStateMixin {
  // Overlay sidebar (mobile only)
  bool _sidebarOpen = false;
  late AnimationController _sidebarCtrl;
  late Animation<Offset> _sidebarSlide;



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

  // Reset hamburger state every time route changes
  void _resetBtn() {}

  Widget _screen() {
    _resetBtn();
    switch (widget.appState.currentRoute) {
      case 'dashboard':
        return DashboardScreen(appState: widget.appState, onStateChanged: widget.onStateChanged);
      case 'all_products':
        return AllProductsScreen(
            appState: widget.appState,
            onStateChanged: widget.onStateChanged);
      case 'add_product':
        return AddProductScreen(
            appState: widget.appState,
            onStateChanged: widget.onStateChanged);
      case 'product_categories':
        return ProductCategoriesScreen(
            appState: widget.appState,
            onStateChanged: widget.onStateChanged);
      case 'low_stock':
        return LowStockScreen(
            appState: widget.appState,
            onStateChanged: widget.onStateChanged);
      case 'all_categories':
        return AllCategoriesScreen(
            appState: widget.appState,
            onStateChanged: widget.onStateChanged);
      case 'add_category':
        return AddCategoryScreen(
            appState: widget.appState,
            onStateChanged: widget.onStateChanged);
      case 'manage_categories':
        return ManageCategoriesScreen(
            appState: widget.appState,
            onStateChanged: widget.onStateChanged);
      case 'stock_alerts':
        return StockAlertsScreen(appState: widget.appState);
      case 'stock_history':
        return StockHistoryScreen(appState: widget.appState);
      case 'adjustments':
        return AdjustmentsScreen(
            appState: widget.appState,
            onStateChanged: widget.onStateChanged);
      case 'orders':
        return const OrderHistoryScreen();
      case 'sales_report':
        return const SalesReportScreen();
      case 'inventory_report':
        return InventoryReportScreen(appState: widget.appState);
      case 'customer_report':
        return const CustomerReportScreen();
      case 'financial_report':
        return const FinancialReportScreen();
      case 'settings_theme':
      case 'settings_store':
      case 'settings_account':
      case 'settings':
        return SettingsScreen(
            appState: widget.appState,
            onStateChanged: widget.onStateChanged);
      default:
        return DashboardScreen(appState: widget.appState, onStateChanged: widget.onStateChanged);
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

            // ── DESKTOP: hamburger always visible, no auto-hide ───────
            if (isDesktop) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // top:72 clears the hamburger (16 top + 40 height + 16 gap)
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
                          onStateChanged: () {
                            widget.onStateChanged();
                            _closeSidebar();
                          },
                        ),
                      ),
                    ),
                  ],
                  ChatbotWidget(appState: widget.appState),
                  // Hamburger last = always on top of all content including scrollables
                  // Hidden when sidebar is open so it doesn't overlap the panel
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

            // ── MOBILE: full-screen content + always-visible floating hamburger ───────
            return Stack(
              clipBehavior: Clip.none,
              children: [
                // Screen content with top padding so it never hides under the button
                Padding(
                  padding: const EdgeInsets.only(top: 72),
                  child: _screen(),
                ),

                // Dim backdrop
                if (_sidebarOpen)
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

                // Sliding sidebar panel
                if (_sidebarOpen)
                  SlideTransition(
                    position: _sidebarSlide,
                    child: GestureDetector(
                      onTap: () {},
                      behavior: HitTestBehavior.opaque,
                      child: Sidebar(
                        appState: widget.appState,
                        onStateChanged: () {
                          widget.onStateChanged();
                          _closeSidebar();
                        },
                      ),
                    ),
                  ),

                // Chatbot
                ChatbotWidget(appState: widget.appState),

                // Floating hamburger — always visible, always on top
                // Hidden when sidebar is open so it doesn't overlap the panel
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
