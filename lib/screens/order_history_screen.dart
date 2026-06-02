import 'dart:async'; 
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; 
import '../models/app_state.dart';
import '../services/api_service.dart';

class OrderHistoryScreen extends StatefulWidget {
  final AppState appState;
  const OrderHistoryScreen({super.key, required this.appState});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  String _filter = 'All'; 
  String _search = '';
  bool _isLoading = true;
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    // 🌟 THE FIX: Using the API fetcher instead of a direct Firebase listener
    _fetchOrders();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // 🌟 THE ULTIMATE FIX: Now it uses the working Node.js server!
  Future<void> _fetchOrders() async {
    try {
      // This uses the WebApiService with the correct 192.168.100.4 IP!
      final fetchedOrders = await WebApiService.getOrders();
      
      final List<Map<String, dynamic>> freshOrders = [];
      
      for (var item in fetchedOrders) {
        final data = Map<String, dynamic>.from(item);
        data['id'] = data['order_id'] ?? data['_id'] ?? data['id'] ?? 'Unknown'; 
        freshOrders.add(data);
      }

      // Sort to show newest first safely
      freshOrders.sort((a, b) {
        final dateA = _parseDate(a['createdAt'] ?? a['created_at'] ?? a['date']) ?? DateTime.fromMillisecondsSinceEpoch(0);
        final dateB = _parseDate(b['createdAt'] ?? b['created_at'] ?? b['date']) ?? DateTime.fromMillisecondsSinceEpoch(0);
        return dateB.compareTo(dateA); 
      });
      
      if (mounted) {
        setState(() {
          _orders = freshOrders;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("🔥 API Fetch Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 🌟 BULLETPROOF DATE PARSER
  DateTime? _parseDate(dynamic dateVal) {
    if (dateVal == null) return null;
    if (dateVal is Timestamp) return dateVal.toDate();
    if (dateVal is int) return DateTime.fromMillisecondsSinceEpoch(dateVal);
    if (dateVal is String) {
      final tryInt = int.tryParse(dateVal);
      if (tryInt != null && tryInt > 10000000000) {
        return DateTime.fromMillisecondsSinceEpoch(tryInt);
      }
      return DateTime.tryParse(dateVal);
    }
    return null;
  }

  List<Map<String, dynamic>> get filteredOrders {
    var filtered = _orders.where((o) {
      final id = o['id']?.toString() ?? '';
      return id.toLowerCase().contains(_search.toLowerCase());
    }).toList();

    final now = DateTime.now();

    if (_filter == 'Today') {
      filtered = filtered.where((o) {
        final date = _parseDate(o['createdAt'] ?? o['created_at'] ?? o['date']);
        if (date == null) return true; 
        return date.year == now.year && date.month == now.month && date.day == now.day;
      }).toList();
    } else if (_filter == 'Week') {
      filtered = filtered.where((o) {
        final date = _parseDate(o['createdAt'] ?? o['created_at'] ?? o['date']);
        if (date == null) return true;
        return now.difference(date).inDays <= 7;
      }).toList();
    } else if (_filter != 'All') {
      filtered = filtered.where((o) {
        final status = (o['status'] ?? 'completed').toString().toLowerCase();
        final type = (o['type'] ?? o['orderType'] ?? o['order_type'] ?? '').toString().toLowerCase();
        final target = _filter.toLowerCase();
        
        if (target == 'dine in') return type == 'dine in' || type == 'dine_in';
        if (target == 'take out') return type == 'take out' || type == 'take_out';
        if (target == 'refund') return status == 'refunded' || status == 'refund';
        if (target == 'cancelled') return status == 'cancelled' || status == 'canceled';
        if (target == 'completed') return status == 'completed';
        
        return false;
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1D2E);
    final textMuted = isDark ? Colors.white54 : const Color(0xFF6B7280);
    final bgCard = isDark ? const Color(0xFF1A1D2E) : Colors.white;
    final bgSearch = isDark ? const Color(0xFF252840) : const Color(0xFFF3F4F6);
    
    final sym = widget.appState.currencySymbol;

    final totalOrders = filteredOrders.length;
    double totalRevenue = 0;
    for (var o in filteredOrders) {
      final stat = (o['status'] ?? '').toString().toLowerCase();
      if (stat != 'cancelled' && stat != 'refund' && stat != 'refunded') {
        totalRevenue += double.tryParse(o['totalAmount']?.toString() ?? o['total_amount']?.toString() ?? '0') ?? 0;
      }
    }
    final avgOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(50),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        
        // ── HEADER ──
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order History', style: TextStyle(color: textPrimary, fontSize: 24, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('View and manage all orders', style: TextStyle(color: textMuted, fontSize: 13), overflow: TextOverflow.ellipsis),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ── METRICS ──
        LayoutBuilder(builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 460;
          final cards = [
            _MetricCard(icon: Icons.attach_money, iconColor: const Color(0xFF4B6BFB), label: 'Total Revenue', value: '$sym${totalRevenue.toStringAsFixed(2)}', isDark: isDark),
            _MetricCard(icon: Icons.calendar_today_outlined, iconColor: const Color(0xFF22C88A), label: 'Total Orders', value: '$totalOrders', isDark: isDark),
            _MetricCard(icon: Icons.analytics_outlined, iconColor: const Color(0xFF9B59B6), label: 'Avg Order Value', value: '$sym${avgOrderValue.toStringAsFixed(2)}', isDark: isDark),
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

        // ── SEARCH & FILTERS ──
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(14),
            border: isDark ? null : Border.all(color: const Color(0xFFE5E7EB))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            TextField(
              onChanged: (v) => setState(() => _search = v),
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
            const SizedBox(height: 16),
            
            Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    'All', 'Today', 'Week', 'Completed', 'Cancelled', 'Refund', 'Dine In', 'Take Out'
                  ].map((f) => _FilterChip(
                    label: f, 
                    selected: _filter == f, 
                    onTap: () => setState(() => _filter = f), 
                    isDark: isDark,
                  )).toList(),
                ),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 16),

        // ── ORDER CARDS ──
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(48.0),
            child: Center(child: CircularProgressIndicator(color: Color(0xFF4B6BFB))),
          )
        else if (filteredOrders.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 48),
            decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(14), border: isDark ? null : Border.all(color: const Color(0xFFE5E7EB))),
            child: Column(children: [
              Icon(Icons.receipt_long_outlined, color: isDark ? Colors.white24 : Colors.black12, size: 48),
              const SizedBox(height: 12),
              Text('No orders found', style: TextStyle(color: textMuted, fontSize: 14)),
            ]),
          )
        else
          LayoutBuilder(builder: (context, constraints) {
            int crossAxisCount = 1;
            if (constraints.maxWidth > 1200) {
              crossAxisCount = 3;
            } else if (constraints.maxWidth > 800) crossAxisCount = 2;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                mainAxisExtent: 180, 
              ),
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) {
                final order = filteredOrders[index];
                return _buildOrderCard(order, isDark, textPrimary, textMuted, bgCard, sym);
              },
            );
          }),
      ]),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, bool isDark, Color textPrimary, Color textMuted, Color bgCard, String sym) {
    final orderId = order['id']?.toString() ?? 'Unknown';
    
    // Safely look for items
    List<dynamic> items = [];
    if (order['items'] != null && order['items'] is List) items = order['items'];
    if (order['cart_items'] != null && order['cart_items'] is List) items = order['cart_items']; 
    if (order['cartItems'] != null && order['cartItems'] is List) items = order['cartItems'];

    final total = double.tryParse(order['totalAmount']?.toString() ?? order['total_amount']?.toString() ?? '0') ?? 0.0;
    
    final status = (order['status'] ?? 'Completed').toString().toUpperCase();
    Color statusColor = const Color(0xFF22C88A); 
    if (status.contains('CANCEL')) statusColor = Colors.redAccent;
    if (status.contains('REFUND')) statusColor = Colors.orange;

    final type = (order['type'] ?? order['orderType'] ?? order['order_type'] ?? '').toString().toUpperCase();
    
    String formattedDate = 'Unknown Date';
    final date = _parseDate(order['createdAt'] ?? order['created_at'] ?? order['date']);
    if (date != null) {
      formattedDate = DateFormat('MMM dd, yyyy • hh:mm a').format(date);
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252840) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isDark ? Border.all(color: Colors.white12) : Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order #$orderId', 
                        style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 13), 
                        overflow: TextOverflow.ellipsis),
                      if (type.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(type, style: TextStyle(color: textMuted, fontSize: 10, fontWeight: FontWeight.w600)),
                      ]
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: isDark ? Colors.white12 : const Color(0xFFE5E7EB)),
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 14, color: textMuted),
                            const SizedBox(width: 8),
                            Text(formattedDate, style: TextStyle(color: textMuted, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.shopping_bag_outlined, size: 14, color: textMuted),
                            const SizedBox(width: 8),
                            Text('${items.length} item${items.length == 1 ? '' : 's'}', style: TextStyle(color: textMuted, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Total', style: TextStyle(color: textMuted, fontSize: 11)),
                        const SizedBox(height: 4),
                        Text('$sym${total.toStringAsFixed(2)}', 
                          style: const TextStyle(color: Color(0xFF4B6BFB), fontSize: 18, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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