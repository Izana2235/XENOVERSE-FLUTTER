import 'package:flutter/material.dart';
import 'dart:math' as math;

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  String _period = 'Last 30 Days';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1D2E);
    final textMuted = isDark ? Colors.white54 : const Color(0xFF6B7280);
    final bgCard = isDark ? const Color(0xFF1A1D2E) : Colors.white;
    final borderColor = isDark ? Colors.white24 : const Color(0xFFD1D5DB);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sales Analytics',
                      style: TextStyle(
                          color: textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Comprehensive business intelligence and insights',
                      style: TextStyle(color: textMuted, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: bgCard,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderColor),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _period,
                        dropdownColor: bgCard,
                        style: TextStyle(color: textPrimary),
                        icon: Icon(Icons.keyboard_arrow_down, color: textMuted),
                        items: ['Last 7 Days', 'Last 30 Days', 'Last 90 Days']
                            .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                            .toList(),
                        onChanged: (v) => setState(() => _period = v!),
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textPrimary,
                      side: BorderSide(color: borderColor),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.download_outlined, size: 18),
                    label: const Text('Export'),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Analytic cards ────────────────────────────────────────────────
          LayoutBuilder(builder: (context, constraints) {
            final cols = constraints.maxWidth < 500 ? 2 : 4;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: cols,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: constraints.maxWidth < 500 ? 1.2 : 1.4,
              children: const [
                _AnalyticCard(icon: Icons.attach_money, iconBg: Color(0xFF2A4A8A),
                    label: 'Total Revenue', value: '₱0.00', sub: 'Gross sales', trend: '12.5% increase', isPositive: true),
                _AnalyticCard(icon: Icons.shopping_cart_outlined, iconBg: Color(0xFF1A5A3A),
                    label: 'Total Orders', value: '0', sub: 'Completed', trend: '8.3% increase', isPositive: true),
                _AnalyticCard(icon: Icons.trending_up, iconBg: Color(0xFF5A3A1A),
                    label: 'Avg Order Value', value: '₱0.00', sub: 'Per transaction', trend: '2.1% decrease', isPositive: false),
                _AnalyticCard(icon: Icons.people_outline, iconBg: Color(0xFF3A1A5A),
                    label: 'Active Products', value: '9', sub: 'In catalog', trend: '5.7% increase', isPositive: true),
              ],
            );
          }),
          const SizedBox(height: 20),

          // ── Charts ────────────────────────────────────────────────────────
          LayoutBuilder(builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 600;
            final chartPanel = Container(
              height: 260,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: bgCard,
                borderRadius: BorderRadius.circular(14),
                border: isDark ? null : Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Revenue & Orders Trend',
                    style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis),
                  Text('Daily performance over time',
                    style: TextStyle(color: textMuted, fontSize: 12),
                    overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 16),
                  const Expanded(child: _RevenueChart()),
                ],
              ),
            );
            final catPanel = Container(
              height: isNarrow ? null : 260,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: bgCard,
                borderRadius: BorderRadius.circular(14),
                border: isDark ? null : Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Revenue by Category',
                    style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 60),
                  Center(child: Text('No data available', style: TextStyle(color: textMuted))),
                ],
              ),
            );

            if (isNarrow) {
              return Column(children: [
                chartPanel,
                const SizedBox(height: 14),
                catPanel,
              ]);
            }
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 3, child: chartPanel),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: catPanel),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Analytic Card ─────────────────────────────────────────────────────────────
class _AnalyticCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String label, value, sub, trend;
  final bool isPositive;

  const _AnalyticCard({
    required this.icon,
    required this.iconBg,
    required this.label,
    required this.value,
    required this.sub,
    required this.trend,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1D2E);
    final textMuted = isDark ? Colors.white54 : const Color(0xFF6B7280);
    final bgCard = isDark ? const Color(0xFF1A1D2E) : Colors.white;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(14),
        border: isDark ? null : Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
              child: Text(label, overflow: TextOverflow.ellipsis, maxLines: 1,
                style: TextStyle(color: textMuted, fontSize: 12)),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: Colors.white, size: 14),
            ),
          ]),
          const SizedBox(height: 6),
          Text(value, overflow: TextOverflow.ellipsis, maxLines: 1,
            style: TextStyle(color: textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
          Text(sub, overflow: TextOverflow.ellipsis, maxLines: 1,
            style: TextStyle(color: textMuted, fontSize: 11)),
          const SizedBox(height: 8),
          Row(children: [
            Icon(isPositive ? Icons.trending_up : Icons.trending_down,
                color: isPositive ? const Color(0xFF22C88A) : Colors.redAccent, size: 13),
            const SizedBox(width: 4),
            Flexible(child: Text(trend, overflow: TextOverflow.ellipsis, maxLines: 1,
              style: TextStyle(
                color: isPositive ? const Color(0xFF22C88A) : Colors.redAccent,
                fontSize: 11, fontWeight: FontWeight.w600))),
          ]),
          Flexible(child: Text('vs last period', overflow: TextOverflow.ellipsis, maxLines: 1,
            style: TextStyle(color: textMuted, fontSize: 10))),
        ],
      ),
    );
  }
}

// ── Revenue Chart ─────────────────────────────────────────────────────────────
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
