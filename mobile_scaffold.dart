import 'package:flutter/material.dart';

class MobileScaffold extends StatelessWidget {
  const MobileScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      drawer: buildDrawer(),
      body: buildBody(1),
    );
  }
}

AppBar buildAppBar() {
  return AppBar(
    backgroundColor: const Color(0xFF1D2634),
    title: const Text("XENOVERSE"),
    actions: const [
      Icon(Icons.search),
      SizedBox(width: 10),
      Icon(Icons.notifications),
      SizedBox(width: 10),
      Icon(Icons.account_circle),
      SizedBox(width: 10),
    ],
  );
}

Widget buildDrawer() {
  return Drawer(
    backgroundColor: const Color(0xFF263043),
    child: Column(
      children: [
        const DrawerHeader(
          child: Row(
            children: [
              Icon(Icons.shopping_cart, color: Colors.white),
              SizedBox(width: 10),
              Text(
                "STORE",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
        ),
        drawerItem(Icons.dashboard, "DASHBOARD"),
        drawerItem(Icons.inventory_2, "PRODUCTS"),
        drawerItem(Icons.category, "CATEGORIES"),
        drawerItem(Icons.storefront, "INVENTORY"),
        drawerItem(Icons.bar_chart, "REPORTS"),
        drawerItem(Icons.settings, "SETTINGS"),
      ],
    ),
  );
}

Widget drawerItem(IconData icon, String title) {
  return ListTile(
    leading: Icon(icon, color: Colors.white),
    title: Text(title, style: const TextStyle(color: Colors.white)),
    onTap: () {},
  );
}

Widget buildBody(int columns) {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "DASHBOARD",
          style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.count(
            crossAxisCount: columns,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: const [
              DashboardCard("PRODUCTS", "249", Icons.inventory_2, Color(0xFF2962FF)),
              DashboardCard("CATEGORIES", "25", Icons.category, Color(0xFFFF6D00)),
              DashboardCard("CUSTOMERS", "1500", Icons.groups, Color(0xFF2E7D32)),
              DashboardCard("INVENTORY WARNING", "56", Icons.notification_important, Color(0xFFD50000)),
            ],
          ),
        ),
      ],
    ),
  );
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const DashboardCard(this.title, this.value, this.icon, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
              Icon(icon, color: Colors.white, size: 40),
            ],
          ),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
