import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/dashboard_card_widget.dart';
import '../widgets/settings_tab.dart';
import '../widgets/placeholder_tab.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _sidebarOpen = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 600;
    final appState = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.bgDark0 : AppColors.bgLight0;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Main Layout
          Row(
            children: [
              // Sidebar (Desktop)
              if (!isMobile)
                AppSidebar(
                  isMobile: false,
                  onClose: () {},
                ),
              // Main Content
              Expanded(
                child: Column(
                  children: [
                    // Header
                    AppHeader(
                      isMobile: isMobile,
                      onMenuPressed: () {
                        setState(() => _sidebarOpen = !_sidebarOpen);
                      },
                    ),
                    // Tab Content
                    Expanded(
                      child: Container(
                        color: bgColor,
                        child: SingleChildScrollView(
                          child: _buildTabContent(appState.currentTab),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Sidebar Overlay (Mobile)
          if (isMobile && _sidebarOpen)
            GestureDetector(
              onTap: () => setState(() => _sidebarOpen = false),
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
          // Animated Sidebar (Mobile)
          if (isMobile)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              left: _sidebarOpen ? 0 : -320,
              top: 0,
              bottom: 0,
              child: AppSidebar(
                isMobile: true,
                onClose: () => setState(() => _sidebarOpen = false),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabContent(String tabName) {
    switch (tabName) {
      case 'dashboard':
        return const DashboardTab();
      case 'products':
        return const PlaceholderTab(
          title: 'PRODUCTS',
          description: 'Product management section. Here you can view, add, edit, and delete products.',
          icon: Icons.inventory_2_outlined,
        );
      case 'categories':
        return const PlaceholderTab(
          title: 'CATEGORIES',
          description: 'Category management section. Organize your products into categories.',
          icon: Icons.category_outlined,
        );
      case 'customers':
        return const PlaceholderTab(
          title: 'CUSTOMERS',
          description: 'Customer management section. View and manage customer information.',
          icon: Icons.groups_outlined,
        );
      case 'inventory':
        return const PlaceholderTab(
          title: 'INVENTORY',
          description: 'Inventory management section. Track stock levels and inventory warnings.',
          icon: Icons.storefront_outlined,
        );
      case 'reports':
        return const PlaceholderTab(
          title: 'REPORTS',
          description: 'Reports and analytics section. View sales reports and statistics.',
          icon: Icons.bar_chart_outlined,
        );
      case 'settings':
        return const SettingsTab();
      default:
        return const DashboardTab();
    }
  }
}