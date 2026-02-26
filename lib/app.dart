import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'screens/all_products_screen.dart';
import 'screens/low_stock_screen.dart';
import 'screens/order_history_screen.dart';
import 'screens/sales_report_screen.dart';
import 'screens/inventory_screens.dart';
import 'screens/categories_screen.dart';
import 'screens/other_screens.dart' as other;
import 'widgets/sidebar.dart';
import 'models/app_state.dart';

class StoreAdminApp extends StatefulWidget {
  const StoreAdminApp({super.key});

  @override
  State<StoreAdminApp> createState() => _StoreAdminAppState();
}

class _StoreAdminAppState extends State<StoreAdminApp> {
  final AppState appState = AppState();

  void _rebuild() => setState(() {});

  ThemeMode get _themeMode {
    switch (appState.themePreference) {
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
      title: 'Store Admin Panel',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,

      // ── Light theme ──────────────────────────────────────────────
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: const Color(0xFFF3F4F6),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF4B6BFB),
          surface: Color(0xFFFFFFFF),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFFFFF),
          foregroundColor: Color(0xFF1A1D2E),
          elevation: 1,
        ),
        drawerTheme: const DrawerThemeData(
          backgroundColor: Color(0xFFFAFBFC),
        ),
      ),

      // ── Dark theme ───────────────────────────────────────────────
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F1117),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4B6BFB),
          surface: Color(0xFF1A1D2E),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF13162A),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        drawerTheme: const DrawerThemeData(
          backgroundColor: Color(0xFF13162A),
        ),
      ),

      home: AdminShell(appState: appState, onRebuild: _rebuild),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class AdminShell extends StatefulWidget {
  final AppState appState;
  final VoidCallback onRebuild;

  const AdminShell({
    super.key,
    required this.appState,
    required this.onRebuild,
  });

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  void _rebuild() {
    setState(() {});
    widget.onRebuild(); // propagates to MaterialApp so ThemeMode updates
  }

  String _getRouteTitle() {
    final route = widget.appState.currentRoute;
    switch (route) {
      case 'dashboard':
        return 'Dashboard';
      case 'all_products':
      case 'add_product':
        return 'All Products';
      case 'product_categories':
        return 'All Categories';
      case 'low_stock':
        return 'Low Stock';
      case 'orders':
      case 'order_history':
        return 'Order History';
      case 'stock_alerts':
        return 'Stock Alerts';
      case 'stock_history':
        return 'Stock History';
      case 'adjustments':
        return 'Stock Adjustments';
      case 'sales_report':
        return 'Sales Analytics';
      case 'inventory_report':
        return 'Inventory Report';
      case 'customer_report':
        return 'Customer Report';
      case 'financial_report':
        return 'Financial Report';
      case 'settings_theme':
      case 'settings_store':
      case 'settings_account':
      case 'settings':
        return 'Settings';
      default:
        return 'Store Admin Panel';
    }
  }

  Widget _buildContent() {
    final appState = widget.appState;
    switch (appState.currentRoute) {

      // ── Core ────────────────────────────────────────────────────
      case 'dashboard':
        return DashboardScreen(appState: appState, onStateChanged: _rebuild);

      // ── Products ────────────────────────────────────────────────
      case 'all_products':
      case 'add_product':
        return AllProductsScreen(
          appState: appState,
          onStateChanged: _rebuild,
        );
      case 'product_categories':
        return ProductCategoriesScreen(
          appState: appState,
          onStateChanged: _rebuild,
        );
      case 'low_stock':
        // Updated constructor: no separate products: param
        return LowStockScreen(
          appState: appState,
          onStateChanged: _rebuild,
        );

      // ── Orders ──────────────────────────────────────────────────
      case 'orders':
      case 'order_history':
        return const OrderHistoryScreen();

      // ── Inventory ────────────────────────────────────────────────
      case 'stock_alerts':
        return StockAlertsScreen(appState: appState);
      case 'stock_history':
        return StockHistoryScreen(appState: appState);
      case 'adjustments':
        return AdjustmentsScreen(
          appState: appState,
          onStateChanged: _rebuild,
        );

      // ── Reports ──────────────────────────────────────────────────
      case 'sales_report':
        return const SalesReportScreen();
      case 'inventory_report':
        return other.InventoryReportScreen(appState: appState);
      case 'customer_report':
        return const other.CustomerReportScreen();
      case 'financial_report':
        return const other.FinancialReportScreen();

      // ── Settings ─────────────────────────────────────────────────
      case 'settings_theme':
      case 'settings_store':
      case 'settings_account':
      case 'settings':
        return other.SettingsScreen(appState: appState, onStateChanged: _rebuild);

      default:
        return DashboardScreen(appState: appState, onStateChanged: _rebuild);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 800;

        if (isMobile) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              centerTitle: false,
              title: Text(
                _getRouteTitle(),
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
              ),
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, size: 26),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
            ),
            drawer: Drawer(
              width: 260,
              child: SafeArea(
                child: Sidebar(
                  appState: widget.appState,
                  inDrawer: true,
                  onStateChanged: () {
                    _rebuild();
                    Navigator.of(context).maybePop();
                  },
                ),
              ),
            ),
            body: _buildContent(),
          );
        }

        // ── Desktop / tablet layout ────────────────────────────────
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Row(
            children: [
              Sidebar(
                appState: widget.appState,
                onStateChanged: _rebuild,
              ),
              Expanded(child: _buildContent()),
            ],
          ),
        );
      },
    );
  }
}
