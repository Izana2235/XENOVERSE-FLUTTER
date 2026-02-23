import 'package:flutter/material.dart';
import '../models/app_tab.dart';

class Sidebar extends StatelessWidget {
  final bool isCollapsed;
  final AppTab currentTab;
  final int? expandedSection;
  final Function(int) onSectionToggle;
  final Function(AppTab) onTapTab;

  const Sidebar({
    super.key,
    required this.isCollapsed,
    required this.currentTab,
    required this.expandedSection,
    required this.onSectionToggle,
    required this.onTapTab,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isCollapsed ? 70 : 260, // CSS Transition equivalent
      color: const Color(0xFF1E293B),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildItem(0, Icons.dashboard, "Dashboard", AppTab.dashboard),
          _buildItem(1, Icons.shopping_bag, "Products", AppTab.products, hasSubmenu: true),
          _buildItem(2, Icons.category, "Categories", AppTab.categories),
        ],
      ),
    );
  }

  Widget _buildItem(int index, IconData icon, String label, AppTab tab, {bool hasSubmenu = false}) {
    bool isExpanded = expandedSection == index;

    return Column(
      children: [
        ListTile(
          selected: currentTab == tab,
          leading: Icon(icon, color: Colors.white),
          title: isCollapsed ? null : Text(label, style: const TextStyle(color: Colors.white)),
          // JS Logic: Rotate chevron icon (90deg rotation)
          trailing: hasSubmenu && !isCollapsed 
            ? AnimatedRotation(
                turns: isExpanded ? 0.25 : 0, // 0.25 = 90 degrees
                duration: const Duration(milliseconds: 200),
                child: const Icon(Icons.chevron_right, color: Colors.white70, size: 18),
              )
            : null,
          onTap: () {
            if (hasSubmenu) {
              onSectionToggle(index);
            } else {
              onTapTab(tab);
            }
          },
        ),
        // JS Logic: Show submenu (maxHeight animation equivalent)
        if (hasSubmenu && isExpanded && !isCollapsed)
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: ListTile(
              title: const Text("Customers", style: TextStyle(color: Colors.white70, fontSize: 13)),
              onTap: () => onTapTab(AppTab.customers),
            ),
          ),
      ],
    );
  }
}