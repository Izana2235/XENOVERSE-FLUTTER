import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/app_state.dart';
import '../widgets/page_header.dart';

class DashboardScreen extends StatelessWidget {
  final AppState appState;
  final VoidCallback onStateChanged;
  const DashboardScreen({super.key, required this.appState, required this.onStateChanged});

  void _navigate(String route) {
    appState.currentRoute = route;
    onStateChanged();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lowStock = appState.lowStockProducts;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(title: 'DASHBOARD'),
          const SizedBox(height: 20),
          LayoutBuilder(builder: (context, c) {
            final cols = c.maxWidth < 500 ? 2 : 4;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: cols,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: c.maxWidth < 500 ? 1.2 : 1.6,
              children: [
                _StatCard(
                  label: 'PRODUCTS',
                  value: '${appState.products.length}',
                  color: const Color(0xFF3B6FF0),
                  icon: Icons.inventory_2_outlined,
                  onTap: () => _navigate('all_products'),
                ),
                _StatCard(
                  label: 'CATEGORIES',
                  value: '${appState.categories.length}',
                  color: const Color(0xFFE8561A),
                  icon: Icons.category_outlined,
                  onTap: () => _navigate('all_categories'),
                ),
                _StatCard(
                  label: 'TOTAL REVENUE',
                  value: '₱0.00',
                  color: const Color(0xFF22C88A),
                  icon: Icons.attach_money_outlined,
                  onTap: () => _navigate('sales_report'),
                ),
                _StatCard(
                  label: 'LOW STOCK',
                  value: '${lowStock.length}',
                  color: const Color(0xFFE53935),
                  icon: Icons.warning_amber_outlined,
                  onTap: () => _navigate('low_stock'),
                ),
              ],
            );
          }),
          const SizedBox(height: 20),
          LayoutBuilder(builder: (context, c) {
            final isNarrow = c.maxWidth < 600;
            final ordersPanel = _PanelCard(
              title: 'Recent Orders',
              child: SizedBox(
                height: 160,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        color: isDark ? Colors.white24 : Colors.black12,
                        size: 44,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'No orders yet',
                        style: TextStyle(
                          color:
                              isDark ? Colors.white38 : const Color(0xFF9CA3AF),
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );

            // FIX 1: replaced undefined `bgCard` with a theme-aware color expression
            final chartBgColor =
                isDark ? const Color(0xFF1A1D2E) : const Color(0xFFFFFFFF);

            final chartPanel = Container(
              height: 260,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: chartBgColor,
                borderRadius: BorderRadius.circular(14),
                border: isDark ? null : Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Revenue & Orders Trend',
                    style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1A1D2E),
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  const Expanded(child: _RevenueChart()),
                ],
              ),
            );

            final stockPanel = _PanelCard(
              title: 'Low Stock Alert',
              child: lowStock.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'All stock levels healthy ✅',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white54
                                : const Color(0xFF6B7280),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                  : Column(children: lowStock.map(_lowStockRow).toList()),
            );

            return isNarrow
                ? Column(children: [
                    ordersPanel,
                    const SizedBox(height: 14),
                    chartPanel,
                    const SizedBox(height: 14),
                    stockPanel,
                  ])
                : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(
                        flex: 3,
                        child: Column(children: [
                          ordersPanel,
                          const SizedBox(height: 14),
                          chartPanel,
                        ])),
                    const SizedBox(width: 14),
                    Expanded(flex: 2, child: stockPanel),
                  ]);
          }),
        ],
      ),
    );
  }

  Widget _lowStockRow(dynamic p) {
    return Builder(builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Image.network(
              p.imageUrl,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                  width: 40,
                  height: 40,
                  color: isDark ? Colors.white12 : const Color(0xFFF3F4F6),
                  child: Icon(Icons.image,
                      color: isDark ? Colors.white38 : Colors.black26,
                      size: 18)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1A1D2E),
                      fontWeight: FontWeight.w500,
                      fontSize: 14)),
              Text(p.category,
                  style: TextStyle(
                      color: isDark ? Colors.white54 : const Color(0xFF6B7280),
                      fontSize: 12)),
            ]),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFF5C518),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('${p.stock} left',
                style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
        ]),
      );
    });
  }
}

// ── Stat Card with hover animation ─────────────────────────────────────────────
class _StatCard extends StatefulWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;
  const _StatCard(
      {required this.label,
      required this.value,
      required this.color,
      required this.icon,
      this.onTap});

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? widget.color
        : widget.color.withOpacity(_hovered ? 0.22 : 0.13);
    final textColor = isDark
        ? Colors.white
        : (widget.color == const Color(0xFFE53935)
            ? Colors.redAccent
            : Colors.black87);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..scale(_hovered ? 1.03 : 1.0),
        transformAlignment: Alignment.center,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border:
              isDark ? null : Border.all(color: widget.color.withOpacity(0.2)),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: widget.color.withOpacity(isDark ? 0.35 : 0.2),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  )
                ]
              : isDark
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      )
                    ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Flexible(
                child: Text(
                  widget.label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color:
                      isDark ? Colors.white24 : widget.color.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(widget.icon,
                    color: isDark ? Colors.white : widget.color, size: 17),
              ),
            ]),
            Text(widget.value,
                style: TextStyle(
                    color: textColor,
                    fontSize: 30,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      ),
    );
  }
}

// ── Panel Card ──────────────────────────────────────────────────────────────────
class _PanelCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _PanelCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1A1D2E) : const Color(0xFFFFFFFF);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1D2E);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: isDark ? null : Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: TextStyle(
                color: textColor, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 14),
        child,
      ]),
    );
  }
}

// ── Revenue/Orders trend chart for dashboard ──────────────────────────────────
class _RevenueChart extends StatelessWidget {
  const _RevenueChart();

  @override
  Widget build(BuildContext context) {
    final random = math.Random(42);
    final barData = List.generate(30, (i) => 200 + random.nextDouble() * 600);
    final lineData = List.generate(30, (i) => 10 + random.nextDouble() * 50);
    return CustomPaint(
        painter: _ChartPainter(barData: barData, lineData: lineData),
        child: Container());
  }
}

class _ChartPainter extends CustomPainter {
  final List<double> barData;
  final List<double> lineData;
  _ChartPainter({required this.barData, required this.lineData});

  @override
  void paint(Canvas canvas, Size size) {
    final maxBar = barData.reduce(math.max);
    final maxLine = lineData.reduce(math.max);
    final barPaint = Paint()..color = const Color(0xFF22C88A);
    final linePaint = Paint()
      ..color = const Color(0xFF4B6BFB)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final fillPaint = Paint()
      ..color = const Color(0xFF4B6BFB).withOpacity(0.15)
      ..style = PaintingStyle.fill;
    final gridPaint = Paint()
      ..color = Colors.white12
      ..strokeWidth = 0.5;

    for (int i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final barWidth = size.width / barData.length * 0.6;
    final barSpacing = size.width / barData.length;
    for (int i = 0; i < barData.length; i++) {
      final x = i * barSpacing + barSpacing * 0.2;
      final barH = (barData[i] / maxBar) * size.height * 0.85;
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(x, size.height - barH, barWidth, barH),
              const Radius.circular(3)),
          barPaint);
    }

    final linePath = Path();
    final fillPath = Path();
    for (int i = 0; i < lineData.length; i++) {
      final x = i * barSpacing + barSpacing / 2;
      final y = size.height - (lineData[i] / maxLine) * size.height * 0.85;
      if (i == 0) {
        linePath.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        linePath.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    final lastX = (lineData.length - 1) * barSpacing + barSpacing / 2;
    fillPath.lineTo(lastX, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
