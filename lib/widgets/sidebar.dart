import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../models/settings_scroll_target.dart';

class Sidebar extends StatefulWidget {
  final AppState appState;
  final VoidCallback onStateChanged;
  final bool inDrawer;

  const Sidebar({
    super.key,
    required this.appState,
    required this.onStateChanged,
    this.inDrawer = false,
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  bool _productsExpanded = false;
  bool _categoriesExpanded = false;
  bool _inventoryExpanded = false;
  bool _reportsExpanded = false;
  bool _settingsExpanded = false;

  final Set<String> _expandedSubcategories = {};
  String? _hoveredRoute;

  @override
  void didUpdateWidget(Sidebar old) {
    super.didUpdateWidget(old);
    // Rebuild when storeName or adminName changes so the sidebar
    // immediately reflects the updated values from Settings.
    if (old.appState.storeName != widget.appState.storeName ||
        old.appState.adminName != widget.appState.adminName) {
      setState(() {});
    }
  }

  static const _activeColor = Color(0xFF4B6BFB);
  static const _animDuration = Duration(milliseconds: 150);
  static const _animCurve = Curves.fastOutSlowIn;

  void _nav(String route) {
    setState(() {
      _hoveredRoute = null;
      _expandedSubcategories.add(route);

      if (['all_products', 'add_product', 'product_categories', 'low_stock'].contains(route)) {
        _productsExpanded = true;
      }
      if (['all_categories', 'add_category', 'manage_categories'].contains(route)) {
        _categoriesExpanded = true;
      }
      if (['stock_alerts', 'stock_history', 'adjustments'].contains(route)) {
        _inventoryExpanded = true;
      }
      if (['sales_report', 'inventory_report', 'customer_report', 'financial_report'].contains(route)) {
        _reportsExpanded = true;
      }
      if (['settings_theme', 'settings', 'settings_store', 'settings_account', 'logout'].contains(route)) {
        _settingsExpanded = true;
      }
    });

    if (route == 'logout') {
      _showLogoutDialog();
      return;
    }

    // Settings sub-routes always show the SettingsScreen ('settings' route).
    // SettingsScrollTarget records which section to scroll to.
    if (route == 'settings_theme') {
      widget.appState.currentRoute = 'settings';
      SettingsScrollTarget.section = 'appearance';
    } else if (route == 'settings_store') {
      widget.appState.currentRoute = 'settings';
      SettingsScrollTarget.section = 'store';
    } else if (route == 'settings_account') {
      widget.appState.currentRoute = 'settings';
      SettingsScrollTarget.section = 'account';
    } else {
      widget.appState.currentRoute = route;
      SettingsScrollTarget.section = null;
    }

    widget.onStateChanged();
    if (widget.inDrawer) Navigator.of(context).maybePop();
  }

  void _showLogoutDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1D2E) : Colors.white,
        title: Text('Log Out',
            style: TextStyle(
                color: Theme.of(context).textTheme.titleLarge?.color)),
        content: Text('Are you sure you want to log out?',
            style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1D2E);
    final textMuted = isDark ? Colors.white54 : const Color(0xFF6B7280);
    final dividerColor = isDark ? Colors.white12 : const Color(0xFFE5E7EB);
    final bgColor = isDark ? const Color(0xFF13162A) : const Color(0xFFFAFBFC);

    return ClipRect(
      child: Container(
        width: 260,
        color: bgColor,
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
            SizedBox(
              height: 72,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                          color: _activeColor,
                          borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.shopping_cart_outlined,
                          color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(widget.appState.storeName.toUpperCase(),
                              style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                          Text('Admin Panel',
                              style: TextStyle(color: textMuted, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Divider(color: dividerColor, height: 1),

            // ── Nav items ────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Dashboard
                    _navItem(Icons.grid_view_rounded, 'DASHBOARD',
                        'dashboard', textColor, isDark),

                    // Products
                    _sectionItem(
                      icon: Icons.inventory_2_outlined,
                      label: 'PRODUCTS',
                      sectionKey: 'section_products',
                      expanded: _productsExpanded,
                      textColor: textColor,
                      textMuted: textMuted,
                      isDark: isDark,
                      onTap: () => setState(() {
                        _productsExpanded = !_productsExpanded;
                        _hoveredRoute = null;
                      }),
                    ),
                    AnimatedSize(
                      duration: _animDuration,
                      curve: _animCurve,
                      clipBehavior: Clip.antiAlias,
                      child: _productsExpanded
                          ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                              _subItem('All Products', 'all_products', isDark, textMuted),
                              _subItem('Add Product', 'add_product', isDark, textMuted),
                              _subItem('Product Categories', 'product_categories', isDark, textMuted),
                              _subItem('Low Stock', 'low_stock', isDark, textMuted),
                            ])
                          : const SizedBox.shrink(),
                    ),

                    // Categories
                    _sectionItem(
                      icon: Icons.category_outlined,
                      label: 'CATEGORIES',
                      sectionKey: 'section_categories',
                      expanded: _categoriesExpanded,
                      textColor: textColor,
                      textMuted: textMuted,
                      isDark: isDark,
                      onTap: () => setState(() {
                        _categoriesExpanded = !_categoriesExpanded;
                        _hoveredRoute = null;
                      }),
                    ),
                    AnimatedSize(
                      duration: _animDuration,
                      curve: _animCurve,
                      clipBehavior: Clip.antiAlias,
                      child: _categoriesExpanded
                          ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                              _subItem('Add Category', 'add_category', isDark, textMuted),
                              _subItem('Manage Categories', 'manage_categories', isDark, textMuted),
                            ])
                          : const SizedBox.shrink(),
                    ),

                    // Inventory
                    _sectionItem(
                      icon: Icons.warning_amber_outlined,
                      label: 'INVENTORY',
                      sectionKey: 'section_inventory',
                      expanded: _inventoryExpanded,
                      textColor: textColor,
                      textMuted: textMuted,
                      isDark: isDark,
                      onTap: () => setState(() {
                        _inventoryExpanded = !_inventoryExpanded;
                        _hoveredRoute = null;
                      }),
                    ),
                    AnimatedSize(
                      duration: _animDuration,
                      curve: _animCurve,
                      clipBehavior: Clip.antiAlias,
                      child: _inventoryExpanded
                          ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                              _subItem('Stock Alerts', 'stock_alerts', isDark, textMuted),
                              _subItem('Stock History', 'stock_history', isDark, textMuted),
                              _subItem('Adjustments', 'adjustments', isDark, textMuted),
                            ])
                          : const SizedBox.shrink(),
                    ),

                    // Order history (direct nav)
                    _navItem(Icons.shopping_cart_outlined, 'ORDER HISTORY',
                        'orders', textColor, isDark),

                    // Reports
                    _sectionItem(
                      icon: Icons.bar_chart_outlined,
                      label: 'REPORTS',
                      sectionKey: 'section_reports',
                      expanded: _reportsExpanded,
                      textColor: textColor,
                      textMuted: textMuted,
                      isDark: isDark,
                      onTap: () => setState(() {
                        _reportsExpanded = !_reportsExpanded;
                        _hoveredRoute = null;
                      }),
                    ),
                    AnimatedSize(
                      duration: _animDuration,
                      curve: _animCurve,
                      clipBehavior: Clip.antiAlias,
                      child: _reportsExpanded
                          ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                              _subItem('Sales Report', 'sales_report', isDark, textMuted),
                              _subItem('Inventory Report', 'inventory_report', isDark, textMuted),
                              _subItem('Customer Report', 'customer_report', isDark, textMuted),
                              _subItem('Financial Report', 'financial_report', isDark, textMuted),
                            ])
                          : const SizedBox.shrink(),
                    ),

                    // Settings
                    _sectionItem(
                      icon: Icons.settings_outlined,
                      label: 'SETTINGS',
                      sectionKey: 'section_settings',
                      expanded: _settingsExpanded,
                      textColor: textColor,
                      textMuted: textMuted,
                      isDark: isDark,
                      onTap: () => setState(() {
                        _settingsExpanded = !_settingsExpanded;
                        _hoveredRoute = null;
                      }),
                    ),
                    AnimatedSize(
                      duration: _animDuration,
                      curve: _animCurve,
                      clipBehavior: Clip.antiAlias,
                      child: _settingsExpanded
                          ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                              _subItem('Appearance', 'settings_theme', isDark, textMuted,
                                  icon: Icons.palette_outlined),
                              _subItem('Store Information', 'settings_store', isDark, textMuted,
                                  icon: Icons.store_outlined),
                              _subItem('Account', 'settings_account', isDark, textMuted,
                                  icon: Icons.manage_accounts_outlined),
                              _subItem('Log Out', 'logout', isDark, textMuted,
                                  icon: Icons.logout, color: Colors.redAccent),
                            ])
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),

            // ── Footer info (no theme toggle — moved to Settings > Appearance) ──
            Divider(color: dividerColor, height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _activeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.person_outline,
                        color: _activeColor, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.appState.adminName,
                            style: TextStyle(
                                color: textColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                        Text('Administrator',
                            style: TextStyle(color: textMuted, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Full nav row ─────────────────────────────────────────────────────────────
  Widget _navItem(IconData icon, String label, String route,
      Color textColor, bool isDark) {
    final active = widget.appState.currentRoute == route;
    final hovered = _hoveredRoute == route;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hoveredRoute = route),
      onExit: (_) => setState(() => _hoveredRoute = null),
      child: GestureDetector(
        onTap: () => _nav(route),
        child: AnimatedContainer(
          duration: _animDuration,
          curve: _animCurve,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          decoration: BoxDecoration(
            color: active
                ? _activeColor
                : hovered
                    ? (isDark
                        ? Colors.white.withValues(alpha: 0.07)
                        : Colors.black.withValues(alpha: 0.05))
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: _activeColor.withValues(alpha: 0.30),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    )
                  ]
                : [],
          ),
          child: Row(children: [
            Icon(icon,
                color: active ? Colors.white : textColor, size: 19),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: active ? Colors.white : textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
            ),
          ]),
        ),
      ),
    );
  }

  // ── Expandable section header ────────────────────────────────────────────────
  Widget _sectionItem({
    required IconData icon,
    required String label,
    required String sectionKey,
    required bool expanded,
    required Color textColor,
    required Color textMuted,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final hovered = _hoveredRoute == sectionKey;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hoveredRoute = sectionKey),
      onExit: (_) => setState(() => _hoveredRoute = null),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: _animDuration,
          curve: _animCurve,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          decoration: BoxDecoration(
            color: hovered
                ? (isDark
                    ? Colors.white.withValues(alpha: 0.07)
                    : Colors.black.withValues(alpha: 0.05))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(children: [
            Icon(icon, color: textColor, size: 19),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
            ),
            Icon(
                expanded
                    ? Icons.keyboard_arrow_down
                    : Icons.keyboard_arrow_right,
                color: textMuted,
                size: 18),
          ]),
        ),
      ),
    );
  }

  // ── Sub-item ─────────────────────────────────────────────────────────────────
  Widget _subItem(String label, String route, bool isDark, Color textMuted,
      {IconData? icon, Color? color}) {
    final active = widget.appState.currentRoute == route;
    final hovered = _hoveredRoute == route;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hoveredRoute = route),
      onExit: (_) => setState(() => _hoveredRoute = null),
      child: GestureDetector(
        onTap: () => _nav(route),
        child: AnimatedContainer(
          duration: _animDuration,
          curve: _animCurve,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
          padding: const EdgeInsets.only(left: 44, top: 10, bottom: 10, right: 12),
          decoration: BoxDecoration(
            color: active
                ? (isDark ? Colors.white10 : Colors.black12)
                : hovered
                    ? (isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.black.withValues(alpha: 0.04))
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(children: [
            if (icon != null) ...[
              Icon(icon, size: 15, color: color ?? textMuted),
              const SizedBox(width: 7),
            ],
            Expanded(
              child: Text(label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: color ??
                          (active
                              ? (isDark ? Colors.white : Colors.black87)
                              : textMuted),
                      fontSize: 13)),
            ),
          ]),
        ),
      ),
    );
  }
}


class SidebarDrawer extends StatelessWidget {
  final AppState appState;
  final VoidCallback onStateChanged;

  const SidebarDrawer({
    super.key,
    required this.appState,
    required this.onStateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 260,
      child: Sidebar(
        appState: appState,
        onStateChanged: onStateChanged,
        inDrawer: true,
      ),
    );
  }
}
