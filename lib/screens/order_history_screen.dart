import 'package:flutter/material.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1D2E);
    final textMuted = isDark ? Colors.white54 : const Color(0xFF6B7280);
    final bgCard = isDark ? const Color(0xFF1A1D2E) : Colors.white;
    final bgSearch = isDark ? const Color(0xFF252840) : const Color(0xFFF3F4F6);
    final divider = isDark ? Colors.white12 : const Color(0xFFE5E7EB);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(50),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Order History', style: TextStyle(color: textPrimary, fontSize: 24, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4),
        Text('View and manage all orders', style: TextStyle(color: textMuted, fontSize: 13), overflow: TextOverflow.ellipsis),
        const SizedBox(height: 24),

        LayoutBuilder(builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 460;
          final cards = [
            _MetricCard(icon: Icons.attach_money, iconColor: const Color(0xFF4B6BFB), label: 'Total Revenue', value: '₱0.00', isDark: isDark),
            _MetricCard(icon: Icons.calendar_today_outlined, iconColor: const Color(0xFF22C88A), label: 'Total Orders', value: '0', isDark: isDark),
            _MetricCard(icon: Icons.attach_money, iconColor: const Color(0xFF9B59B6), label: 'Avg Order Value', value: '₱0.00', isDark: isDark),
          ];
          if (isNarrow) {
            return Column(children: [cards[0], const SizedBox(height: 12), cards[1], const SizedBox(height: 12), cards[2]]);
          }
          return Row(children: [
            Expanded(child: cards[0]), const SizedBox(width: 16),
            Expanded(child: cards[1]), const SizedBox(width: 16),
            Expanded(child: cards[2]),
          ]);
        }),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(14),
            border: isDark ? null : Border.all(color: const Color(0xFFE5E7EB))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            TextField(
              style: TextStyle(color: textPrimary),
              decoration: InputDecoration(
                hintText: 'Search order ID...',
                hintStyle: TextStyle(color: textMuted),
                prefixIcon: Icon(Icons.search, color: textMuted),
                filled: true, fillColor: bgSearch,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: ['All', 'Today', 'Week'].map((f) => _FilterChip(
                label: f, selected: _filter == f, onTap: () => setState(() => _filter = f), isDark: isDark,
              )).toList()),
            ),
          ]),
        ),
        const SizedBox(height: 16),

        Container(
          decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(14),
            border: isDark ? null : Border.all(color: const Color(0xFFE5E7EB))),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(children: [
                Expanded(flex: 2, child: Text('Order ID', overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: textMuted, fontWeight: FontWeight.w600, fontSize: 13))),
                Expanded(flex: 3, child: Text('Date & Time', overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: textMuted, fontWeight: FontWeight.w600, fontSize: 13))),
                Expanded(flex: 2, child: Text('Items', overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: textMuted, fontWeight: FontWeight.w600, fontSize: 13))),
                Expanded(flex: 2, child: Text('Total', overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: textMuted, fontWeight: FontWeight.w600, fontSize: 13))),
                Expanded(flex: 2, child: Text('Actions', overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: textMuted, fontWeight: FontWeight.w600, fontSize: 13))),
              ]),
            ),
            Divider(color: divider, height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Center(child: Column(children: [
                Icon(Icons.receipt_long_outlined, color: isDark ? Colors.white24 : Colors.black12, size: 48),
                const SizedBox(height: 12),
                Text('No orders found', style: TextStyle(color: textMuted, fontSize: 14)),
              ])),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final bool isDark;

  const _MetricCard({required this.icon, required this.iconColor, required this.label, required this.value, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1D2E);
    final textMuted = isDark ? Colors.white54 : const Color(0xFF6B7280);
    final bgCard = isDark ? const Color(0xFF1A1D2E) : Colors.white;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(14),
        border: isDark ? null : Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: iconColor.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: iconColor, size: 20)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, overflow: TextOverflow.ellipsis, maxLines: 1,
            style: TextStyle(color: textMuted, fontSize: 13)),
          const SizedBox(height: 6),
          Text(value, overflow: TextOverflow.ellipsis, maxLines: 1,
            style: TextStyle(color: textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
        ])),
      ]),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool isDark;

  const _FilterChip({required this.label, required this.selected, required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textMuted = isDark ? Colors.white54 : const Color(0xFF6B7280);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF4B6BFB) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: selected ? null : Border.all(color: isDark ? Colors.white24 : const Color(0xFFD1D5DB)),
        ),
        child: Text(label, overflow: TextOverflow.ellipsis,
          style: TextStyle(color: selected ? Colors.white : textMuted, fontWeight: FontWeight.w500)),
      ),
    );
  }
}
