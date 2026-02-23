import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../theme/app_theme.dart';

class AppSidebar extends StatelessWidget {
  final bool isMobile;
  final VoidCallback onClose;

  const AppSidebar({
    super.key,
    required this.isMobile,
    required this.onClose,
  });

  static final List<SidebarItem> items = [
    SidebarItem(
      id: 'dashboard',
      icon: Icons.dashboard_outlined,
      label: 'DASHBOARD',
      submenu: ['Overview', 'Analytics', 'Statistics'],
    ),
    SidebarItem(
      id: 'products',
      icon: Icons.inventory_2_outlined,
      label: 'PRODUCTS',
      submenu: ['All Products', 'Add Product', 'Product Categories', 'Low Stock'],
    ),
    SidebarItem(
      id: 'categories',
      icon: Icons.category_outlined,
      label: 'CATEGORIES',
      submenu: ['All Categories', 'Add Category', 'Manage Categories'],
    ),
    SidebarItem(
      id: 'inventory',
      icon: Icons.storefront_outlined,
      label: 'INVENTORY',
      submenu: ['Stock Levels', 'Stock Alerts', 'Stock History', 'Adjustments'],
    ),
    SidebarItem(
      id: 'reports',
      icon: Icons.bar_chart_outlined,
      label: 'REPORTS',
      submenu: ['Sales Report', 'Inventory Report', 'Customer Report', 'Financial Report'],
    ),
    SidebarItem(
      id: 'settings',
      icon: Icons.settings_outlined,
      label: 'SETTINGS',
      submenu: ['General Settings', 'User Management', 'Payment Methods', 'System Preferences'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.bgDark1 : AppColors.bgLight0;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Container(
      width: isMobile ? MediaQuery.of(context).size.width * 0.82 : 280,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.98),
        border: Border(
          right: BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Sidebar Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(Icons.shopping_cart_outlined, size: 24),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'STORE',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                if (isMobile)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: onClose,
                  ),
              ],
            ),
          ),
          // Sidebar Menu Items
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isActive = appState.currentTab == item.id;
                final isExpanded = appState.expandedMenus[item.id] ?? false;

                return SidebarMenuItemWidget(
                  item: item,
                  isActive: isActive,
                  isExpanded: isExpanded,
                  onTap: () {
                    appState.switchTab(item.id);
                    if (isMobile) {
                      onClose();
                    }
                  },
                  onExpandTap: () {
                    appState.toggleMenu(item.id);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SidebarItem {
  final String id;
  final IconData icon;
  final String label;
  final List<String> submenu;

  SidebarItem({
    required this.id,
    required this.icon,
    required this.label,
    required this.submenu,
  });
}

class SidebarMenuItemWidget extends StatelessWidget {
  final SidebarItem item;
  final bool isActive;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onExpandTap;

  const SidebarMenuItemWidget({
    super.key,
    required this.item,
    required this.isActive,
    required this.isExpanded,
    required this.onTap,
    required this.onExpandTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;

    return Column(
      children: [
        // Main Item Header
        MouseRegion(
          child: GestureDetector(
            onTap: onExpandTap,
            child: Container(
              decoration: isActive
                  ? BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: isDark
                            ? [
                                const Color(0xFF4F86FF).withOpacity(0.22),
                                const Color(0xFF7C5CFF).withOpacity(0.1),
                              ]
                            : [
                                const Color(0xFF2563EB).withOpacity(0.12),
                                const Color(0xFF7C3AED).withOpacity(0.08),
                              ],
                      ),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF4F86FF).withOpacity(0.25)
                            : const Color(0xFF2563EB).withOpacity(0.25),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    )
                  : null,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              child: Row(
                children: [
                  Icon(
                    item.icon,
                    color: textColor,
                    size: 24,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      item.label,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_more : Icons.chevron_right,
                    color: textColor,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
        // Submenu Items
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          child: isExpanded
              ? Container(
                  color: isDark
                      ? Colors.black.withOpacity(0.14)
                      : Colors.black.withOpacity(0.04),
                  child: Column(
                    children: item.submenu
                        .asMap()
                        .entries
                        .map(
                          (entry) => GestureDetector(
                            onTap: onTap,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              margin: const EdgeInsets.only(left: 60),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  entry.value,
                                  style: TextStyle(
                                    color: textColor.withOpacity(0.6),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                )
              : SizedBox.shrink(),
        ),
      ],
    );
  }
}
