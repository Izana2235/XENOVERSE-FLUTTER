import 'dart:ui';
import 'package:flutter/material.dart';

/// Tabs that match the HTML layout
enum AppTab {
  dashboard,
  products,
  categories,
  customers,
  inventory,
  reports,
  settings,
}

class MobileScaffold extends StatefulWidget {
  const MobileScaffold({super.key});

  @override
  State<MobileScaffold> createState() => _MobileScaffoldState();
}

class _MobileScaffoldState extends State<MobileScaffold> {
  AppTab _currentTab = AppTab.dashboard;
  final Map<String, bool> _expandedSections = {};

  void _toggleSubmenu(String section) {
    setState(() {
      _expandedSections[section] = !(_expandedSections[section] ?? false);
    });
  }

  void _switchTab(AppTab tab) {
    setState(() => _currentTab = tab);
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildHeader(context),
      drawer: _buildSidebar(
        context: context,
        currentTab: _currentTab,
        expandedSections: _expandedSections,
        onToggleSubmenu: _toggleSubmenu,
        onTabSelected: _switchTab,
      ),
      body: _buildMainContent(_currentTab, columns: 1, onCardTap: _switchTab),
    );
  }
}

/// Header matching the image - menu icon, centered search, right icons
PreferredSizeWidget _buildHeader(BuildContext context) {
  return AppBar(
    backgroundColor: const Color(0xFF111928).withOpacity(0.55),
    elevation: 0,
    flexibleSpace: ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF111928).withOpacity(0.55),
            border: const Border(
              bottom: BorderSide(color: Color(0x1AFFFFFF), width: 1),
            ),
          ),
        ),
      ),
    ),
    leading: Builder(
      builder: (ctx) => IconButton(
        icon: const Icon(Icons.menu, color: Colors.white),
        onPressed: () => Scaffold.of(ctx).openDrawer(),
      ),
    ),
    centerTitle: true,
    title: Container(
      constraints: const BoxConstraints(maxWidth: 520),
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0x0FFFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x1AFFFFFF)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 20, color: Colors.white70),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Search…',
                hintStyle: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    ),
    actions: [
      IconButton(
        icon: const Icon(Icons.notifications_outlined, color: Colors.white),
        onPressed: () {},
      ),
      IconButton(
        icon: const Icon(Icons.email_outlined, color: Colors.white),
        onPressed: () {},
      ),
      IconButton(
        icon: const Icon(Icons.account_circle_outlined, color: Colors.white),
        onPressed: () {},
      ),
      const SizedBox(width: 8),
    ],
  );
}

/// Sidebar / drawer content with expandable submenus
Widget _buildSidebar({
  required BuildContext context,
  required AppTab currentTab,
  required Map<String, bool> expandedSections,
  required ValueChanged<String> onToggleSubmenu,
  required ValueChanged<AppTab> onTabSelected,
}) {
  return Drawer(
    backgroundColor: const Color(0xFF111928),
    child: SafeArea(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.shopping_cart_outlined, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      'STORE',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0x1AFFFFFF)),
          _buildExpandableSection(
            icon: Icons.dashboard_outlined,
            title: 'DASHBOARD',
            currentTab: currentTab,
            isExpanded: expandedSections['dashboard'] ?? false,
            onToggle: () => onToggleSubmenu('dashboard'),
            submenuItems: const [
              ('Overview', AppTab.dashboard),
              ('Analytics', AppTab.dashboard),
              ('Statistics', AppTab.dashboard),
            ],
            onTabSelected: onTabSelected,
          ),
          _buildExpandableSection(
            icon: Icons.inventory_2_outlined,
            title: 'PRODUCTS',
            currentTab: currentTab,
            isExpanded: expandedSections['products'] ?? false,
            onToggle: () => onToggleSubmenu('products'),
            submenuItems: const [
              ('All Products', AppTab.products),
              ('Add Product', AppTab.products),
              ('Product Categories', AppTab.products),
              ('Low Stock', AppTab.products),
            ],
            onTabSelected: onTabSelected,
          ),
          _buildExpandableSection(
            icon: Icons.category_outlined,
            title: 'CATEGORIES',
            currentTab: currentTab,
            isExpanded: expandedSections['categories'] ?? false,
            onToggle: () => onToggleSubmenu('categories'),
            submenuItems: const [
              ('All Categories', AppTab.categories),
              ('Add Category', AppTab.categories),
              ('Manage Categories', AppTab.categories),
            ],
            onTabSelected: onTabSelected,
          ),
          _buildExpandableSection(
            icon: Icons.storefront_outlined,
            title: 'INVENTORY',
            currentTab: currentTab,
            isExpanded: expandedSections['inventory'] ?? false,
            onToggle: () => onToggleSubmenu('inventory'),
            submenuItems: const [
              ('Stock Levels', AppTab.inventory),
              ('Stock Alerts', AppTab.inventory),
              ('Stock History', AppTab.inventory),
              ('Adjustments', AppTab.inventory),
            ],
            onTabSelected: onTabSelected,
          ),
          _buildExpandableSection(
            icon: Icons.bar_chart_outlined,
            title: 'REPORTS',
            currentTab: currentTab,
            isExpanded: expandedSections['reports'] ?? false,
            onToggle: () => onToggleSubmenu('reports'),
            submenuItems: const [
              ('Sales Report', AppTab.reports),
              ('Inventory Report', AppTab.reports),
              ('Customer Report', AppTab.reports),
              ('Financial Report', AppTab.reports),
            ],
            onTabSelected: onTabSelected,
          ),
          _buildExpandableSection(
            icon: Icons.settings_outlined,
            title: 'SETTINGS',
            currentTab: currentTab,
            isExpanded: expandedSections['settings'] ?? false,
            onToggle: () => onToggleSubmenu('settings'),
            submenuItems: const [
              ('General Settings', AppTab.settings),
              ('User Management', AppTab.settings),
              ('Payment Methods', AppTab.settings),
              ('System Preferences', AppTab.settings),
            ],
            onTabSelected: onTabSelected,
          ),
        ],
      ),
    ),
  );
}

Widget _buildExpandableSection({
  required IconData icon,
  required String title,
  required AppTab currentTab,
  required bool isExpanded,
  required VoidCallback onToggle,
  required List<(String, AppTab)> submenuItems,
  required ValueChanged<AppTab> onTabSelected,
}) {
  final bool isActive = _isTabActive(currentTab, title);

  return Column(
    children: [
      InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: isActive
                ? const LinearGradient(
                    colors: [
                      Color(0x384F86FF),
                      Color(0x1A7C5CFF),
                    ],
                  )
                : null,
            border: isActive
                ? Border.all(color: const Color(0x407C5CFF))
                : null,
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
              AnimatedRotation(
                turns: isExpanded ? 0.25 : 0,
                duration: const Duration(milliseconds: 300),
                child: const Icon(
                  Icons.chevron_right,
                  color: Colors.white70,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
      AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: isExpanded ? null : 0,
        child: isExpanded
            ? Container(
                color: const Color(0x24000000),
                child: Column(
                  children: submenuItems.map((item) {
                    return InkWell(
                      onTap: () => onTabSelected(item.$2),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ).copyWith(left: 60),
                        child: Row(
                          children: [
                            Text(
                              item.$1,
                              style: const TextStyle(
                                color: Color(0xFFA3A3A3),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              )
            : const SizedBox.shrink(),
      ),
    ],
  );
}

bool _isTabActive(AppTab currentTab, String title) {
  switch (currentTab) {
    case AppTab.dashboard:
      return title == 'DASHBOARD';
    case AppTab.products:
      return title == 'PRODUCTS';
    case AppTab.categories:
      return title == 'CATEGORIES';
    case AppTab.inventory:
      return title == 'INVENTORY';
    case AppTab.reports:
      return title == 'REPORTS';
    case AppTab.settings:
      return title == 'SETTINGS';
    case AppTab.customers:
      return title == 'PRODUCTS';
  }
}

/// Main content with radial gradient background matching the image
Widget _buildMainContent(
  AppTab tab, {
  required int columns,
  required ValueChanged<AppTab> onCardTap,
}) {
  return Container(
    decoration: const BoxDecoration(
      gradient: RadialGradient(
        center: Alignment(-0.15, -0.1),
        radius: 1.5,
        colors: [
          Color(0x402982FF), // rgba(79, 134, 255, 0.25)
          Colors.transparent,
        ],
        stops: [0.0, 0.6],
      ),
    ),
    child: Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0.95, 0.15),
          radius: 1.2,
          colors: [
            Color(0x337C5CFF), // rgba(124, 92, 255, 0.20)
            Colors.transparent,
          ],
          stops: [0.0, 0.55],
        ),
      ),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F1A2E),
              Color(0xFF0B1220),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DASHBOARD',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTabBody(tab, columns, onCardTap),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _buildTabBody(AppTab tab, int columns, ValueChanged<AppTab> onCardTap) {
  if (tab == AppTab.dashboard) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: columns,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      childAspectRatio: 1.2,
      children: [
        _DashboardCard(
          title: 'PRODUCTS',
          value: '249',
          icon: Icons.inventory_2_outlined,
          gradientColors: const [
            Color(0xFF4F86FF),
            Color(0xFF7C5CFF),
          ],
          onTap: () => onCardTap(AppTab.products),
        ),
        _DashboardCard(
          title: 'CATEGORIES',
          value: '25',
          icon: Icons.category_outlined,
          gradientColors: const [
            Color(0xFFFF7D40),
            Color(0xFFFFB247),
          ],
          onTap: () => onCardTap(AppTab.categories),
        ),
        _DashboardCard(
          title: 'CUSTOMERS',
          value: '1,500',
          icon: Icons.groups_outlined,
          gradientColors: const [
            Color(0xFF2EC58A),
            Color(0xFF2282FF),
          ],
          onTap: () => onCardTap(AppTab.customers),
        ),
        _DashboardCard(
          title: 'INVENTORY WARNING',
          value: '56',
          icon: Icons.notification_important_outlined,
          gradientColors: const [
            Color(0xFFFF4D6D),
            Color(0xFFFF7A3C),
          ],
          onTap: () => onCardTap(AppTab.inventory),
        ),
      ],
    );
  }

  IconData icon;
  String description;
  String placeholderText;

  switch (tab) {
    case AppTab.products:
      icon = Icons.inventory_2_outlined;
      description =
          'Product management section. Here you can view, add, edit, and delete products.';
      placeholderText = 'Product list will be displayed here';
      break;
    case AppTab.categories:
      icon = Icons.category_outlined;
      description =
          'Category management section. Organize your products into categories.';
      placeholderText = 'Category list will be displayed here';
      break;
    case AppTab.customers:
      icon = Icons.groups_outlined;
      description =
          'Customer management section. View and manage customer information.';
      placeholderText = 'Customer list will be displayed here';
      break;
    case AppTab.inventory:
      icon = Icons.storefront_outlined;
      description =
          'Inventory management section. Track stock levels and inventory warnings.';
      placeholderText = 'Inventory details will be displayed here';
      break;
    case AppTab.reports:
      icon = Icons.bar_chart_outlined;
      description =
          'Reports and analytics section. View sales reports and statistics.';
      placeholderText = 'Reports and charts will be displayed here';
      break;
    case AppTab.settings:
      icon = Icons.settings_outlined;
      description = 'System settings and configuration.';
      placeholderText = 'Settings options will be displayed here';
      break;
    case AppTab.dashboard:
      icon = Icons.dashboard_outlined;
      description = '';
      placeholderText = '';
      break;
  }

  return Container(
    margin: const EdgeInsets.only(top: 30),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0x0FFFFFFF),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0x1AFFFFFF)),
      boxShadow: const [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 16,
          offset: Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          description,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF9E9EA4),
          ),
        ),
        const Spacer(),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 80,
                color: Colors.white.withOpacity(0.3),
              ),
              const SizedBox(height: 20),
              Text(
                placeholderText,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const Spacer(),
      ],
    ),
  );
}

/// Dashboard card matching the image - icon top-right, title and value bottom-left
class _DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          border: Border.all(color: const Color(0x1AFFFFFF)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon in top-right
            Align(
              alignment: Alignment.topRight,
              child: Icon(icon, color: Colors.white, size: 40),
            ),
            // Title and value at bottom-left
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
