import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:html' as html;
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; 
import '../models/app_state.dart';
import '../services/api_service.dart';
import '../widgets/page_header.dart';
class DashboardScreen extends StatefulWidget {
  final AppState appState;
  final VoidCallback onStateChanged;
  const DashboardScreen(
      {super.key, required this.appState, required this.onStateChanged});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  double _totalRevenue = 0.0;
  List<Map<String, dynamic>> _recentOrders = [];
  int _categoryCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      // Fetch products, orders, and categories in parallel
      final categoriesFuture = WebApiService.getCategories();
      final results = await Future.wait([
        FirebaseFirestore.instance
            .collection('products')
            .where('user_id', isEqualTo: currentUser.email) 
            .get(),
        FirebaseFirestore.instance
            .collection('orders')
            .where('user_id', isEqualTo: currentUser.email) 
            .get(),
      ]);
      final liveCategories = await categoriesFuture;

      final productsSnapshot = results[0];
      final ordersSnapshot = results[1];

      // 1. Process Products
      final List<Product> liveProducts = [];
      for (var doc in productsSnapshot.docs) {
        final data = Map<String, dynamic>.from(doc.data());
        liveProducts.add(Product(
          id: doc.id,
          name: data['name'] ?? 'Unnamed',
          category: data['category'] ?? 'Uncategorized',
          price: double.tryParse(data['price']?.toString() ?? '0') ?? 0.0,
          cost: double.tryParse(data['cost']?.toString() ?? '0') ?? 0.0,
          taxRate: double.tryParse(data['taxRate']?.toString() ?? '0') ?? 0.0,
          sku: data['sku'] ?? '',
          barcode: data['barcode'] ?? '',
          stock: int.tryParse(data['stock']?.toString() ?? '0') ?? 0,
          imageUrl: data['imageUrl'] ?? data['image_url'] ?? '',
          description: data['description'] ?? '',
        ));
      }

      // 2. Process Orders & Calculate Revenue
      List<Map<String, dynamic>> liveOrders = [];
      double calculatedRevenue = 0.0;

      for (var doc in ordersSnapshot.docs) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id; 
        
        double amount = double.tryParse(data['totalAmount']?.toString() ?? data['total_amount']?.toString() ?? '0') ?? 0.0;
        
        String status = (data['status'] ?? '').toString().toLowerCase();
        if (status != 'cancelled' && status != 'refund' && status != 'refunded') {
          calculatedRevenue += amount;
        }
        liveOrders.add(data);
      }

      liveOrders.sort((a, b) {
        final tA = a['createdAt'] ?? a['date'];
        final tB = b['createdAt'] ?? b['date'];
        if (tA is Timestamp && tB is Timestamp) {
          return tB.compareTo(tA);
        }
        return 0;
      });

      if (mounted) {
        setState(() {
          widget.appState.products.clear();
          widget.appState.products.addAll(liveProducts);

          widget.appState.categories.clear();
          widget.appState.categories.addAll(liveCategories);
          _categoryCount = liveCategories.length;

          _recentOrders = liveOrders; 
          _totalRevenue = calculatedRevenue; 
          _isLoading = false;
        });
        widget.onStateChanged();
      }
    } catch (e) {
      print("🔥 Firebase Dashboard Fetch Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigate(String route) {
    widget.appState.currentRoute = route;
    html.window.localStorage['last_route'] = route;
    widget.onStateChanged();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lowStock = widget.appState.lowStockProducts;
    final currencySymbol = widget.appState.currencySymbol;

    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFF4B6BFB)));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'DASHBOARD',
            trailing: Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.white12 : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(9),
              ),
              child: IconButton(
                icon: const Icon(Icons.sync, color: Color(0xFF4B6BFB)),
                tooltip: 'Refresh Dashboard',
                onPressed: () {
                  setState(() => _isLoading = true);
                  _fetchDashboardData();
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(builder: (context, c) {
            final cols = c.maxWidth < 500 ? 2 : 4;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: cols,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: c.maxWidth < 500 ? 1.5 : 1.6,
              children: [
                _StatCard(
                  label: 'PRODUCTS',
                  value: '${widget.appState.products.length}',
                  color: const Color(0xFF3B6FF0),
                  icon: Icons.inventory_2_outlined,
                  onTap: () => _navigate('all_products'),
                ),
                _StatCard(
                  label: 'CATEGORIES',
                  value: '$_categoryCount',
                  color: const Color(0xFFE8561A),
                  icon: Icons.category_outlined,
                  onTap: () => _navigate('all_categories'),
                ),
                _StatCard(
                  label: 'TOTAL REVENUE',
                  value: '$currencySymbol${_totalRevenue.toStringAsFixed(2)}',
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
                height: 260,
                child: _recentOrders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long_outlined,
                                color: isDark ? Colors.white24 : Colors.black12,
                                size: 44),
                            const SizedBox(height: 10),
                            Text('No orders yet',
                                style: TextStyle(
                                    color: isDark
                                        ? Colors.white38
                                        : const Color(0xFF9CA3AF),
                                    fontSize: 15)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _recentOrders.length > 5
                            ? 5
                            : _recentOrders.length,
                        itemBuilder: (context, index) {
                          var order = _recentOrders[index];
                          String id = order['id']?.toString() ?? '...';
                          String amount = double.tryParse(order['totalAmount']?.toString() ?? order['total_amount']?.toString() ?? '0')?.toStringAsFixed(2) ?? '0.00';
                          String status = order['status'] ?? 'Completed';

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor:
                                  const Color(0xFF4B6BFB).withOpacity(0.1),
                              child: const Icon(Icons.receipt_long,
                                  color: Color(0xFF4B6BFB), size: 18),
                            ),
                            title: Text('Order #$id',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF1A1D2E),
                                    fontWeight: FontWeight.w600)),
                            subtitle: Text(status,
                                style: TextStyle(
                                    color:
                                        isDark ? Colors.white54 : Colors.grey,
                                    fontSize: 12)),
                            trailing: Text('$currencySymbol$amount',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF22C88A),
                                    fontSize: 14)),
                          );
                        },
                      ),
              ),
            );

            final chartBgColor =
                isDark ? const Color(0xFF1A1D2E) : const Color(0xFFFFFFFF);
            final chartPanel = Container(
              height: 300,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: chartBgColor,
                borderRadius: BorderRadius.circular(14),
                border:
                    isDark ? null : Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Revenue & Orders Trend',
                      style: TextStyle(
                          color:
                              isDark ? Colors.white : const Color(0xFF1A1D2E),
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text('Daily performance over time',
                      style: TextStyle(
                          color:
                              isDark ? Colors.white54 : const Color(0xFF6B7280),
                          fontSize: 12)),
                  const SizedBox(height: 16),
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
                        child: Text('All stock levels healthy ✅',
                            style: TextStyle(
                                color: isDark
                                    ? Colors.white54
                                    : const Color(0xFF6B7280),
                                fontSize: 14)),
                      ),
                    )
                  : Column(children: lowStock.map(_lowStockRow).toList()),
            );

            final piePanel = _PanelCard(
              title: 'Revenue by Category',
              child: SizedBox(
                height: 200,
                child: _DashPieChart(
                  textPrimary: isDark ? Colors.white : const Color(0xFF1A1D2E),
                  textMuted: isDark ? Colors.white54 : const Color(0xFF6B7280),
                ),
              ),
            );

            return isNarrow
                ? Column(children: [
                    ordersPanel,
                    const SizedBox(height: 14),
                    chartPanel,
                    const SizedBox(height: 14),
                    piePanel,
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
                    Expanded(
                        flex: 2,
                        child: Column(children: [
                          stockPanel,
                          const SizedBox(height: 14),
                          piePanel,
                        ])),
                  ]);
          }),
        ],
      ),
    );
  }

  Widget _lowStockRow(Product p) {
    return Builder(builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      
      final displayImage = p.imageUrl.isNotEmpty 
          ? p.imageUrl 
          : 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=80&h=80&fit=crop';

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Image.network(
              displayImage,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                  width: 40,
                  height: 40,
                  color: isDark ? Colors.white12 : const Color(0xFFF3F4F6),
                  child: Icon(Icons.fastfood_outlined,
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
                borderRadius: BorderRadius.circular(20)),
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
            border: isDark
                ? null
                : Border.all(color: widget.color.withOpacity(0.2)),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                        color: widget.color.withOpacity(isDark ? 0.35 : 0.2),
                        blurRadius: 18,
                        offset: const Offset(0, 6))
                  ]
                : isDark
                    ? []
                    : [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2))
                      ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Flexible(
                    child: Text(widget.label,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4))),
                Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white24
                            : widget.color.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(8)),
                    child: Icon(widget.icon,
                        color: isDark ? Colors.white : widget.color, size: 17)),
              ]),
              Text(widget.value,
                  style: TextStyle(
                      color: textColor,
                      fontSize: 22,
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

// ── Pie Chart ─────────────────────────────────────────────────────────────────
class _DashPieChart extends StatelessWidget {
  final Color textPrimary;
  final Color textMuted;
  const _DashPieChart({required this.textPrimary, required this.textMuted});

  @override
  Widget build(BuildContext context) {
    const segments = [
      _PieSegment('Food & Bev', 0.38, Color(0xFF4B6BFB)),
      _PieSegment('Electronics', 0.24, Color(0xFF22C88A)),
      _PieSegment('Clothing', 0.18, Color(0xFFF59E0B)),
      _PieSegment('Others', 0.20, Color(0xFFEC4899)),
    ];
    return Row(children: [
      Expanded(
        flex: 5,
        child: CustomPaint(
          painter: const _PieChartPainter(segments: segments),
          child: Container(),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        flex: 5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: segments
              .map((s) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                            color: s.color,
                            borderRadius: BorderRadius.circular(3)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(s.label,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  TextStyle(color: textPrimary, fontSize: 11))),
                      Text('${(s.value * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                              color: textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ]),
                  ))
              .toList(),
        ),
      ),
    ]);
  }
}

class _PieSegment {
  final String label;
  final double value;
  final Color color;
  const _PieSegment(this.label, this.value, this.color);
}

class _PieChartPainter extends CustomPainter {
  final List<_PieSegment> segments;
  const _PieChartPainter({required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 6;
    const innerRadius = 0.52;
    double startAngle = -math.pi / 2;
    const gap = 0.03;

    for (final seg in segments) {
      final sweep = seg.value * 2 * math.pi - gap;
      final paint = Paint()
        ..color = seg.color
        ..style = PaintingStyle.fill;
      final outerRect = Rect.fromCircle(center: center, radius: radius);
      final innerRect =
          Rect.fromCircle(center: center, radius: radius * innerRadius);
      final path = Path()
        ..moveTo(
          center.dx + radius * innerRadius * math.cos(startAngle + gap / 2),
          center.dy + radius * innerRadius * math.sin(startAngle + gap / 2),
        )
        ..lineTo(
          center.dx + radius * math.cos(startAngle + gap / 2),
          center.dy + radius * math.sin(startAngle + gap / 2),
        );
      path.arcTo(outerRect, startAngle + gap / 2, sweep, false);
      path.arcTo(innerRect, startAngle + sweep + gap / 2, -sweep, false);
      path.close();
      canvas.drawPath(path, paint);
      startAngle += seg.value * 2 * math.pi;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Revenue/Orders trend chart for dashboard ──────────────────────────────────
class _RevenueChart extends StatefulWidget {
  const _RevenueChart();

  @override
  State<_RevenueChart> createState() => _RevenueChartState();
}

class _RevenueChartState extends State<_RevenueChart> {
  bool _isBarChart = true;
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final random = math.Random(42);
    final barData = List.generate(30, (i) => 200 + random.nextDouble() * 600);
    final lineData = List.generate(30, (i) => 10 + random.nextDouble() * 50);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return LayoutBuilder(builder: (ctx, constraints) {
      final barSpacing = constraints.maxWidth / barData.length;
      final barWidth = constraints.maxWidth / barData.length * 0.6;
      final maxBar = barData.reduce(math.max);
      final maxLine = lineData.reduce(math.max);
      final chartH = constraints.maxHeight;
      
      return Column(
        children: [
          // Toggle buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    _ChartToggleBtn(
                      label: 'Bar',
                      icon: Icons.bar_chart_rounded,
                      active: _isBarChart,
                      isDark: isDark,
                      onTap: () => setState(() => _isBarChart = true),
                    ),
                    _ChartToggleBtn(
                      label: 'Line',
                      icon: Icons.show_chart_rounded,
                      active: !_isBarChart,
                      isDark: isDark,
                      onTap: () => setState(() => _isBarChart = false),
                    ),
                  ]),
                ),
              ],
            ),
          ),
          // Chart area
          Expanded(
            child: MouseRegion(
              onHover: (event) {
                int? hoveredIdx;
                
                if (_isBarChart) {
                  // Check if cursor is DIRECTLY over a bar
                  for (int i = 0; i < barData.length; i++) {
                    final barH = (barData[i] / maxBar) * chartH * 0.85;
                    final x = i * barSpacing + (barSpacing - barWidth) / 2;
                    final barY = chartH - barH;
                    
                    if (event.localPosition.dx >= x &&
                        event.localPosition.dx <= x + barWidth &&
                        event.localPosition.dy >= barY &&
                        event.localPosition.dy <= chartH) {
                      hoveredIdx = i;
                      break;
                    }
                  }
                } else {
                  // Check line points
                  for (int i = 0; i < lineData.length; i++) {
                    final x = i * barSpacing + barSpacing / 2;
                    final y = chartH - (lineData[i] / maxLine) * chartH * 0.85;
                    final dx = event.localPosition.dx - x;
                    final dy = event.localPosition.dy - y;
                    final distance = math.sqrt(dx * dx + dy * dy);
                    
                    if (distance <= 6.0) {
                      hoveredIdx = i;
                      break;
                    }
                  }
                }
                
                setState(() => _hoveredIndex = hoveredIdx);
              },
              onExit: (_) => setState(() => _hoveredIndex = null),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  if (_isBarChart)
                    CustomPaint(
                      painter: _BarChartPainterDash(
                        values: barData,
                        maxVal: maxBar,
                        spacing: barSpacing,
                        barW: barWidth,
                        hoveredIndex: _hoveredIndex,
                      ),
                      child: Container(),
                    )
                  else
                    CustomPaint(
                      painter: _LineChartPainterDash(
                        values: lineData,
                        maxVal: maxLine,
                        spacing: barSpacing,
                        hoveredIndex: _hoveredIndex,
                      ),
                      child: Container(),
                    ),
                  // Tooltip
                  if (_hoveredIndex != null)
                    Positioned(
                      left: (_hoveredIndex! * barSpacing + barSpacing / 2 - 80).clamp(0, constraints.maxWidth - 160),
                      top: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2A2D3E) : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 10, offset: const Offset(0, 4))],
                          border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE5E7EB)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Day ${_hoveredIndex! + 1}',
                                style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1A1D2E), fontSize: 12, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            if (_isBarChart)
                              Text('Revenue: \$${barData[_hoveredIndex!].toStringAsFixed(0)}',
                                  style: const TextStyle(color: Color(0xFF22C88A), fontSize: 12, fontWeight: FontWeight.w500))
                            else
                              Text('Orders: ${lineData[_hoveredIndex!].toStringAsFixed(0)}',
                                  style: const TextStyle(color: Color(0xFF4B6BFB), fontSize: 12, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _BarChartPainterDash extends CustomPainter {
  final List<double> values;
  final double maxVal, spacing, barW;
  final int? hoveredIndex;

  const _BarChartPainterDash({required this.values, required this.maxVal, required this.spacing, required this.barW, this.hoveredIndex});

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height;
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.15)
      ..strokeWidth = 0.5;
    
    // Draw horizontal grid lines
    for (int i = 0; i <= 4; i++) {
      final y = h * (1 - i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    
    // Draw bars
    for (int i = 0; i < values.length; i++) {
      final barH = (values[i] / maxVal) * h * 0.85;
      final x = i * spacing + (spacing - barW) / 2;
      final isHovered = hoveredIndex == i;
      final color = isHovered ? const Color(0xFF22C88A).withOpacity(0.6) : const Color(0xFF22C88A);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, h - barH, barW, barH), const Radius.circular(4)),
        Paint()..color = color,
      );
    }
    
    // Draw date labels
    final textPainter1 = TextPainter(
      text: const TextSpan(text: '03/31', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 11)),
      textDirection: TextDirection.ltr,
    );
    textPainter1.layout();
    textPainter1.paint(canvas, Offset(4, h + 5));
    
    final textPainter2 = TextPainter(
      text: const TextSpan(text: '04/21', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 11)),
      textDirection: TextDirection.ltr,
    );
    textPainter2.layout();
    textPainter2.paint(canvas, Offset(size.width - 28, h + 5));
  }

  @override
  bool shouldRepaint(_BarChartPainterDash old) => old.hoveredIndex != hoveredIndex || old.values != values;
}

class _LineChartPainterDash extends CustomPainter {
  final List<double> values;
  final double maxVal, spacing;
  final int? hoveredIndex;

  const _LineChartPainterDash({required this.values, required this.maxVal, required this.spacing, this.hoveredIndex});

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height;
    if (values.isEmpty) return;

    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.15)
      ..strokeWidth = 0.5;
    
    // Draw horizontal grid lines
    for (int i = 0; i <= 4; i++) {
      final y = h * (1 - i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final pts = <Offset>[];
    for (int i = 0; i < values.length; i++) {
      pts.add(Offset(i * spacing + spacing / 2, h - (values[i] / maxVal) * h * 0.85));
    }

    // Fill
    final fp = Path()..moveTo(pts.first.dx, h);
    for (final p in pts) {
      fp.lineTo(p.dx, p.dy);
    }
    fp.lineTo(pts.last.dx, h);
    fp.close();
    canvas.drawPath(fp, Paint()..color = const Color(0xFF4B6BFB).withOpacity(0.12));

    // Line
    final lp = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      final cp1 = Offset((pts[i - 1].dx + pts[i].dx) / 2, pts[i - 1].dy);
      final cp2 = Offset((pts[i - 1].dx + pts[i].dx) / 2, pts[i].dy);
      lp.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, pts[i].dx, pts[i].dy);
    }
    canvas.drawPath(lp, Paint()..color = const Color(0xFF4B6BFB)..strokeWidth = 2.5..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);

    // Dots
    for (int i = 0; i < pts.length; i++) {
      final isHovered = hoveredIndex == i;
      canvas.drawCircle(pts[i], isHovered ? 5 : 3, Paint()..color = const Color(0xFF4B6BFB));
      if (isHovered) {
        canvas.drawCircle(pts[i], 7, Paint()..color = const Color(0xFF4B6BFB).withOpacity(0.2));
      }
    }
    
    // Draw date labels
    final textPainter1 = TextPainter(
      text: const TextSpan(text: '03/31', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 11)),
      textDirection: TextDirection.ltr,
    );
    textPainter1.layout();
    textPainter1.paint(canvas, Offset(4, h + 5));
    
    final textPainter2 = TextPainter(
      text: const TextSpan(text: '04/21', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 11)),
      textDirection: TextDirection.ltr,
    );
    textPainter2.layout();
    textPainter2.paint(canvas, Offset(size.width - 28, h + 5));
  }

  @override
  bool shouldRepaint(_LineChartPainterDash old) => old.hoveredIndex != hoveredIndex || old.values != values;
}

class _ChartToggleBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active, isDark;
  final VoidCallback onTap;

  const _ChartToggleBtn({required this.label, required this.icon, required this.active, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF4B6BFB) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: active ? Colors.white : (isDark ? Colors.white54 : const Color(0xFF6B7280))),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: active ? Colors.white : (isDark ? Colors.white54 : const Color(0xFF6B7280)))),
        ]),
      ),
    );
  }
}

