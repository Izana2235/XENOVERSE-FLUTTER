import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_state.dart';

// ─── Inventory Report (NEW FIREBASE VERSION) ──────────────────────────────────
class InventoryReportScreen extends StatefulWidget {
  final AppState appState;
  const InventoryReportScreen({super.key, required this.appState});

  @override
  State<InventoryReportScreen> createState() => _InventoryReportScreenState();
}

class _InventoryReportScreenState extends State<InventoryReportScreen> {
  bool _isLoading = true;
  List<Product> _liveProducts = [];

  @override
  void initState() {
    super.initState();
    _fetchInventoryData();
  }

  Future<void> _fetchInventoryData() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('user_id', isEqualTo: currentUser.email)
          .get();

      final List<Product> products = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        products.add(Product(
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

      if (mounted) {
        setState(() {
          _liveProducts = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Inventory Fetch Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1D2E);
    final textMuted = isDark ? Colors.white54 : const Color(0xFF6B7280);
    final bgCard = isDark ? const Color(0xFF1A1D2E) : Colors.white;
    final headerMuted = isDark ? Colors.white54 : const Color(0xFF6B7280);

    final sym = widget.appState.currencySymbol;

    int totalUnits = 0;
    double inventoryValue = 0.0;
    int lowStockCount = 0;

    for (var p in _liveProducts) {
      totalUnits += p.stock;
      // Value is calculated as stock * cost (or price if cost is 0)
      double itemValue = p.cost > 0 ? p.cost : p.price;
      inventoryValue += (p.stock * itemValue);
      if (p.isLowStock) lowStockCount++;
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF4B6BFB)));
    }

    return Padding(
      padding: const EdgeInsets.all(50),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Inventory Report', style: TextStyle(color: textPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
            Text('Overview of your inventory status', style: TextStyle(color: textMuted, fontSize: 12)),
            const SizedBox(height: 24),

            // ── Top Summary Cards ──
            LayoutBuilder(builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 600;
              final cards = [
                _SummaryCard(title: 'Total Units', value: '$totalUnits', icon: Icons.inventory_2_outlined, color: const Color(0xFF4B6BFB), isDark: isDark),
                _SummaryCard(title: 'Low Stock Items Count', value: '$lowStockCount', icon: Icons.warning_amber_rounded, color: Colors.redAccent, isDark: isDark),
                _SummaryCard(title: 'Inventory Value', value: '$sym${inventoryValue.toStringAsFixed(2)}', icon: Icons.attach_money, color: const Color(0xFF22C88A), isDark: isDark),
              ];
              if (isNarrow) {
                return Column(children: [cards[0], const SizedBox(height: 12), cards[1], const SizedBox(height: 12), cards[2]]);
              }
              return Row(children: [Expanded(child: cards[0]), const SizedBox(width: 16), Expanded(child: cards[1]), const SizedBox(width: 16), Expanded(child: cards[2])]);
            }),
            const SizedBox(height: 32),

            // ── Product Breakdown Table ──
            Text('Product Breakdown', style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: bgCard,
                borderRadius: BorderRadius.circular(12),
                border: isDark ? null : Border.all(color: const Color(0xFFE5E7EB)),
                boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: Text('Product', style: TextStyle(color: headerMuted, fontWeight: FontWeight.w600, fontSize: 12))),
                        Expanded(flex: 2, child: Text('Category', style: TextStyle(color: headerMuted, fontWeight: FontWeight.w600, fontSize: 12))),
                        Expanded(flex: 1, child: Text('Stock', style: TextStyle(color: headerMuted, fontWeight: FontWeight.w600, fontSize: 12))),
                        Expanded(flex: 2, child: Text('Value', style: TextStyle(color: headerMuted, fontWeight: FontWeight.w600, fontSize: 12))),
                        Expanded(flex: 1, child: Text('Status', style: TextStyle(color: headerMuted, fontWeight: FontWeight.w600, fontSize: 12))),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: isDark ? Colors.white12 : const Color(0xFFE5E7EB)),
                  if (_liveProducts.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(child: Text('No products found.', style: TextStyle(color: textMuted))),
                    )
                  else
                    ..._liveProducts.map((p) {
                      double itemValue = p.cost > 0 ? p.cost : p.price;
                      double totalItemValue = p.stock * itemValue;
                      
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            child: Row(
                              children: [
                                Expanded(flex: 3, child: Text(p.name, style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w500))),
                                Expanded(flex: 2, child: Text(p.category, style: TextStyle(color: textMuted, fontSize: 13))),
                                Expanded(flex: 1, child: Text('${p.stock}', style: TextStyle(color: textPrimary, fontSize: 13))),
                                Expanded(flex: 2, child: Text('$sym${totalItemValue.toStringAsFixed(2)}', style: TextStyle(color: textPrimary, fontSize: 13))),
                                Expanded(
                                  flex: 1, 
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: p.isLowStock ? const Color(0xFFF5C518).withOpacity(0.15) : const Color(0xFF22C88A).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(6)
                                      ),
                                      child: Text(
                                        p.isLowStock ? 'Low' : 'OK',
                                        style: TextStyle(color: p.isLowStock ? const Color(0xFFF5C518) : const Color(0xFF22C88A), fontSize: 10, fontWeight: FontWeight.bold)
                                      ),
                                    ),
                                  )
                                ),
                              ],
                            ),
                          ),
                          Divider(height: 1, color: isDark ? Colors.white12 : const Color(0xFFE5E7EB)),
                        ],
                      );
                    }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _SummaryCard({required this.title, required this.value, required this.icon, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isDark ? null : Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: isDark ? Colors.white54 : const Color(0xFF6B7280), fontSize: 13)),
                const SizedBox(height: 4),
                Text(value, style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1A1D2E), fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
    );
  }
}


// ─── Stock Alerts ─────────────────────────────────────────────────────────────
class StockAlertsScreen extends StatelessWidget {
  final AppState appState;
  const StockAlertsScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1D2E);
    final textMuted = isDark ? Colors.white54 : const Color(0xFF6B7280);
    final bgCard = isDark ? const Color(0xFF1A1D2E) : Colors.white;
    final border = isDark ? null : Border.all(color: const Color(0xFFE5E7EB));

    final lowStock = appState.lowStockProducts;
    final critical = lowStock.where((p) => p.stock <= 10).toList();
    final warning  = lowStock.where((p) => p.stock > 10).toList();

    return Padding(
      padding: const EdgeInsets.all(50),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Stock Alerts',
            style: TextStyle(color: textPrimary, fontSize: 24, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis),
          Text('Monitor inventory levels and alerts',
            style: TextStyle(color: textMuted, fontSize: 12),
            overflow: TextOverflow.ellipsis),
          const SizedBox(height: 20),

          Row(children: [
            Flexible(child: _alertChip('Critical', critical.length, Colors.redAccent)),
            const SizedBox(width: 12),
            Flexible(child: _alertChip('Warning', warning.length, const Color(0xFFF5C518))),
            const SizedBox(width: 12),
            Flexible(child: _alertChip('Healthy', appState.products.length - lowStock.length, const Color(0xFF22C88A))),
          ]),
          const SizedBox(height: 24),

          if (critical.isNotEmpty) ...[
            _sectionTitle('🔴 Critical (≤10 units)', Colors.redAccent),
            const SizedBox(height: 10),
            ...critical.map((p) => _alertCard(p, Colors.redAccent, bgCard, textPrimary, textMuted, border, isDark)),
            const SizedBox(height: 20),
          ],
          if (warning.isNotEmpty) ...[
            _sectionTitle('🟡 Warning (11–20 units)', const Color(0xFFF5C518)),
            const SizedBox(height: 10),
            ...warning.map((p) => _alertCard(p, const Color(0xFFF5C518), bgCard, textPrimary, textMuted, border, isDark)),
            const SizedBox(height: 20),
          ],
          if (lowStock.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: bgCard,
                borderRadius: BorderRadius.circular(12),
                border: border,
              ),
              child: Center(child: Column(children: [
                const Icon(Icons.check_circle_outline, color: Color(0xFF22C88A), size: 48),
                const SizedBox(height: 12),
                Text('All stock levels are healthy!',
                  style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
                Text('No products require immediate attention.',
                  style: TextStyle(color: textMuted, fontSize: 13),
                  textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
              ])),
            ),
        ]),
      ),
    );
  }

  Widget _alertChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(children: [
        FittedBox(fit: BoxFit.scaleDown,
          child: Text('$count', style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold))),
        Text(label, style: TextStyle(color: color, fontSize: 11), overflow: TextOverflow.ellipsis),
      ]),
    );
  }

  Widget _sectionTitle(String t, Color c) => Text(t,
    style: TextStyle(color: c, fontSize: 14, fontWeight: FontWeight.w700),
    overflow: TextOverflow.ellipsis);

  Widget _alertCard(Product p, Color color, Color bgCard, Color textPrimary, Color textMuted, BoxBorder? border, bool isDark) {
    final displayImage = p.imageUrl.isNotEmpty 
          ? p.imageUrl 
          : 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=80&h=80&fit=crop';
          
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(children: [
        Container(width: 4, height: 40,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: Image.network(displayImage, width: 38, height: 38, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(width: 38, height: 38,
              color: isDark ? Colors.white12 : const Color(0xFFF3F4F6),
              child: Icon(Icons.fastfood_outlined, color: isDark ? Colors.white38 : Colors.black26, size: 16))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(p.name, overflow: TextOverflow.ellipsis, maxLines: 1,
            style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600)),
          Text(p.category, overflow: TextOverflow.ellipsis, maxLines: 1,
            style: TextStyle(color: textMuted, fontSize: 12)),
        ])),
        const SizedBox(width: 8),
        FittedBox(fit: BoxFit.scaleDown,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
            child: Text('${p.stock} units',
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          )),
      ]),
    );
  }
}

// ─── Stock History ────────────────────────────────────────────────────────────
class StockHistoryScreen extends StatelessWidget {
  final AppState appState;
  const StockHistoryScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1D2E);
    final textMuted = isDark ? Colors.white54 : const Color(0xFF6B7280);
    final headerMuted = isDark ? Colors.white54 : const Color(0xFF6B7280);
    final bgCard = isDark ? const Color(0xFF1A1D2E) : Colors.white;
    final divider = isDark ? Colors.white12 : const Color(0xFFE5E7EB);

    final history = appState.stockHistory;
    return Padding(
      padding: const EdgeInsets.all(50),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Stock History',
            style: TextStyle(color: textPrimary, fontSize: 24, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis),
          Text('Track all stock movements',
            style: TextStyle(color: textMuted, fontSize: 12),
            overflow: TextOverflow.ellipsis),
          const SizedBox(height: 20),
          LayoutBuilder(builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 460;
            return Container(
              decoration: BoxDecoration(
                color: bgCard,
                borderRadius: BorderRadius.circular(12),
                border: isDark ? null : Border.all(color: const Color(0xFFE5E7EB)),
                boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  child: Row(children: [
                    Expanded(flex: 3, child: Text('Product', overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: headerMuted, fontWeight: FontWeight.w600, fontSize: 12))),
                    Expanded(flex: 2, child: Text('Action', overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: headerMuted, fontWeight: FontWeight.w600, fontSize: 12))),
                    Expanded(flex: 1, child: Text('Qty', overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: headerMuted, fontWeight: FontWeight.w600, fontSize: 12))),
                    if (!isNarrow)
                      Expanded(flex: 2, child: Text('Date', overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: headerMuted, fontWeight: FontWeight.w600, fontSize: 12))),
                  ]),
                ),
                Divider(color: divider, height: 1),
                history.isEmpty
                    ? Padding(padding: const EdgeInsets.all(32),
                        child: Center(child: Text('No stock history yet',
                          style: TextStyle(color: textMuted))))
                    : Column(children: history.map((r) {
                        final color = r['action'] == 'Added'
                            ? const Color(0xFF22C88A)
                            : r['action'] == 'Removed'
                                ? Colors.redAccent
                                : const Color(0xFFF5C518);
                        return Column(children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                            child: Row(children: [
                              Expanded(flex: 3, child: Text(r['productName'].toString(),
                                overflow: TextOverflow.ellipsis, maxLines: 1,
                                style: TextStyle(color: textPrimary, fontSize: 13))),
                              Expanded(flex: 2, child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                                  decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                                  child: Text(r['action'].toString(), overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600))))),
                              Expanded(flex: 1, child: Text(
                                '${r['action'] == "Removed" ? "-" : "+"}${r['quantity']}',
                                overflow: TextOverflow.ellipsis, maxLines: 1,
                                style: TextStyle(color: color, fontWeight: FontWeight.bold))),
                              if (!isNarrow)
                                Expanded(flex: 2, child: Text(
                                  '${(r['timestamp'] as DateTime).month}/${(r['timestamp'] as DateTime).day}/${(r['timestamp'] as DateTime).year}',
                                  overflow: TextOverflow.ellipsis, maxLines: 1,
                                  style: TextStyle(color: textMuted, fontSize: 12))),
                            ]),
                          ),
                          Divider(color: divider, height: 1),
                        ]);
                      }).toList()),
              ]),
            );
          }),
        ]),
      ),
    );
  }
}

// ─── Adjustments ─────────────────────────────────────────────────────────────
class AdjustmentsScreen extends StatefulWidget {
  final AppState appState;
  final VoidCallback onStateChanged;
  const AdjustmentsScreen({super.key, required this.appState, required this.onStateChanged});

  @override
  State<AdjustmentsScreen> createState() => _AdjustmentsScreenState();
}

class _AdjustmentsScreenState extends State<AdjustmentsScreen> {
  Product? _selected;
  final _qtyCtrl = TextEditingController();
  String _action = 'Add';
  final _noteCtrl = TextEditingController();

  @override
  void dispose() { _qtyCtrl.dispose(); _noteCtrl.dispose(); super.dispose(); }

  void _apply() async {
    if (_selected == null || _qtyCtrl.text.isEmpty) return;
    final qty = int.tryParse(_qtyCtrl.text) ?? 0;
    if (qty <= 0) return;
    
    final newStock = _action == 'Add' ? _selected!.stock + qty : (_selected!.stock - qty).clamp(0, 9999);
    
    try {
      // 🌟 1. THE FIREBASE UPDATE: Actually push the new stock number to the cloud!
      await FirebaseFirestore.instance.collection('products').doc(_selected!.id).update({
        'stock': newStock,
      });

      // 🌟 2. PERMANENT HISTORY LOG: Save this action to a Firebase history collection
      await FirebaseFirestore.instance.collection('stock_history').add({
        'product_id': _selected!.id,
        'productName': _selected!.name,
        'action': _action == 'Add' ? 'Added' : 'Removed',
        'quantity': qty,
        'note': _noteCtrl.text,
        'timestamp': FieldValue.serverTimestamp(),
        'user_id': FirebaseAuth.instance.currentUser?.email ?? 'admin',
      });

      // 🌟 3. SAFE LOCAL UPDATE: Update the UI without accidentally erasing the cost, tax, and SKU!
      widget.appState.updateProduct(_selected!.id, Product(
        id: _selected!.id, 
        name: _selected!.name, 
        category: _selected!.category,
        price: _selected!.price, 
        cost: _selected!.cost,         // Saved!
        taxRate: _selected!.taxRate,   // Saved!
        sku: _selected!.sku,           // Saved!
        barcode: _selected!.barcode,   // Saved!
        stock: newStock, 
        imageUrl: _selected!.imageUrl, 
        description: _selected!.description,
      ));

      // 🌟 4. INSTANT HISTORY UI: Push it to the local history list so the tab updates immediately
      widget.appState.stockHistory.insert(0, {
        'productName': _selected!.name,
        'action': _action == 'Add' ? 'Added' : 'Removed',
        'quantity': qty,
        'timestamp': DateTime.now(),
      });

      widget.onStateChanged();
      
      _qtyCtrl.clear(); 
      _noteCtrl.clear();
      setState(() => _selected = null);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Stock adjusted! New qty: $newStock'),
          backgroundColor: const Color(0xFF22C88A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to update Firebase: $e'),
          backgroundColor: Colors.redAccent,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1D2E);
    final textMuted = isDark ? Colors.white54 : const Color(0xFF6B7280);
    final bgCard = isDark ? const Color(0xFF1A1D2E) : Colors.white;
    final bgInput = isDark ? const Color(0xFF252840) : const Color(0xFFF3F4F6);
    final inputText = isDark ? Colors.white : const Color(0xFF1A1D2E);
    final hintColor = isDark ? Colors.white38 : const Color(0xFF9CA3AF);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(50),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Stock Adjustments',
          style: TextStyle(color: textPrimary, fontSize: 24, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis),
        Text('Manually adjust product stock levels',
          style: TextStyle(color: textMuted, fontSize: 12),
          overflow: TextOverflow.ellipsis),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: bgCard,
            borderRadius: BorderRadius.circular(14),
            border: isDark ? null : Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Select Product', style: TextStyle(color: textMuted, fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: bgInput,
                borderRadius: BorderRadius.circular(8),
                border: isDark ? null : Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Product>(
                  value: _selected,
                  isExpanded: true,
                  dropdownColor: isDark ? const Color(0xFF252840) : Colors.white,
                  hint: Text('Choose a product', style: TextStyle(color: hintColor)),
                  style: TextStyle(color: inputText, fontSize: 14),
                  items: widget.appState.products.map((p) => DropdownMenuItem(
                    value: p,
                    child: Text('${p.name} (${p.stock} units)', overflow: TextOverflow.ellipsis),
                  )).toList(),
                  onChanged: (v) => setState(() => _selected = v),
                ),
              ),
            ),
            if (_selected != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF252840) : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Row(children: [
                  ClipRRect(borderRadius: BorderRadius.circular(7),
                    child: Image.network(
                      _selected!.imageUrl.isNotEmpty ? _selected!.imageUrl : 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=80&h=80&fit=crop', 
                      width: 40, height: 40, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(width: 40, height: 40,
                        color: isDark ? Colors.white12 : const Color(0xFFE5E7EB)))),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_selected!.name, overflow: TextOverflow.ellipsis, maxLines: 1,
                      style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600)),
                    Text('Current stock: ${_selected!.stock} units',
                      overflow: TextOverflow.ellipsis, maxLines: 1,
                      style: TextStyle(
                        color: _selected!.isLowStock ? const Color(0xFFF5C518) : const Color(0xFF22C88A),
                        fontSize: 12)),
                  ])),
                ]),
              ),
            ],
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _actionBtn('Add', Icons.add_circle_outline, const Color(0xFF22C88A), isDark)),
              const SizedBox(width: 12),
              Expanded(child: _actionBtn('Remove', Icons.remove_circle_outline, Colors.redAccent, isDark)),
            ]),
            const SizedBox(height: 16),
            Text('Quantity', style: TextStyle(color: textMuted, fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextField(
              controller: _qtyCtrl,
              keyboardType: TextInputType.number,
              style: TextStyle(color: inputText),
              decoration: InputDecoration(
                hintText: 'Enter quantity',
                hintStyle: TextStyle(color: hintColor, fontSize: 13),
                filled: true, fillColor: bgInput,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: isDark ? Colors.transparent : const Color(0xFFE5E7EB))),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 14),
            Text('Note (optional)', style: TextStyle(color: textMuted, fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextField(
              controller: _noteCtrl,
              maxLines: 2,
              style: TextStyle(color: inputText),
              decoration: InputDecoration(
                hintText: 'Reason for adjustment...',
                hintStyle: TextStyle(color: hintColor, fontSize: 13),
                filled: true, fillColor: bgInput,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: isDark ? Colors.transparent : const Color(0xFFE5E7EB))),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4B6BFB),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 46),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
              ),
              onPressed: _selected != null ? _apply : null,
              child: const Text('Apply Adjustment', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _actionBtn(String label, IconData icon, Color color, bool isDark) {
    final sel = _action == label;
    return GestureDetector(
      onTap: () => setState(() => _action = label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: sel ? color.withOpacity(0.2) : (isDark ? const Color(0xFF252840) : const Color(0xFFF3F4F6)),
          borderRadius: BorderRadius.circular(8),
          border: sel ? Border.all(color: color) : Border.all(color: isDark ? Colors.white12 : const Color(0xFFE5E7EB)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: sel ? color : (isDark ? Colors.white38 : Colors.black38), size: 18),
          const SizedBox(width: 6),
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis,
            style: TextStyle(color: sel ? color : (isDark ? Colors.white54 : const Color(0xFF6B7280)),
              fontWeight: FontWeight.w600))),
        ]),
      ),
    );
  }
}