import 'package:firstapp/widgets/dashboard_card.dart';
import 'package:flutter/material.dart';
import '../models/app_tab.dart';

class MainContent extends StatelessWidget {
  final AppTab currentTab;
  final bool isMobile;
  final ThemeData theme;

  const MainContent({
    super.key,
    required this.currentTab,
    required this.isMobile,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Text(
            currentTab.toString().split('.').last.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Expanded(
          child: GridView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            physics: const BouncingScrollPhysics(),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              // FIX: Ginawang 260 para hindi magmukhang dambuhala sa Desktop
              maxCrossAxisExtent: 260, 
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              // Mas mababang ratio (1.3) para maging saktong rectangle lang
              childAspectRatio: 1.3, 
            ),
            children: [
              _buildStatCard("PRODUCTS", "249", Icons.inventory_2, [const Color(0xFF6366F1), const Color(0xFF8B5CF6)]),
              _buildStatCard("CATEGORIES", "25", Icons.category, [const Color(0xFFF59E0B), const Color(0xFFEF4444)]),
              _buildStatCard("CUSTOMERS", "1,500", Icons.people, [const Color(0xFF10B981), const Color(0xFF3B82F6)]),
              _buildStatCard("INVENTORY", "56", Icons.notification_important, [const Color(0xFFF43F5E), const Color(0xFFFB923C)]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, List<Color> colors) {
    return DashboardCard( 
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
        ),
        child: Stack(
          children: [
            // Background Icon para sa Aesthetic
            Positioned(
              right: -5,
              top: -5,
              child: Icon(
                icon, 
                color: Colors.white.withOpacity(0.15), 
                size: 45
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icon sa taas
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                // Text info sa baba
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white70, 
                        fontSize: 12, 
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(
                        color: Colors.white, 
                        fontSize: 28, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}