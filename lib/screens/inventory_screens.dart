import 'package:flutter/material.dart';
import '../models/app_state.dart';

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
          child: Image.network(p.imageUrl, width: 38, height: 38, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(width: 38, height: 38,
              color: isDark ? Colors.white12 : const Color(0xFFF3F4F6),
              child: Icon(Icons.image, color: isDark ? Colors.white38 : Colors.black26, size: 16))),
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

  void _apply() {
    if (_selected == null || _qtyCtrl.text.isEmpty) return;
    final qty = int.tryParse(_qtyCtrl.text) ?? 0;
    if (qty <= 0) return;
    final newStock = _action == 'Add' ? _selected!.stock + qty : (_selected!.stock - qty).clamp(0, 9999);
    widget.appState.updateProduct(_selected!.id, Product(
      id: _selected!.id, name: _selected!.name, category: _selected!.category,
      price: _selected!.price, stock: newStock, imageUrl: _selected!.imageUrl, description: _selected!.description,
    ));
    widget.onStateChanged();
    _qtyCtrl.clear(); _noteCtrl.clear();
    setState(() => _selected = null);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Stock adjusted! New qty: $newStock'),
      backgroundColor: const Color(0xFF22C88A),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ));
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
                    child: Image.network(_selected!.imageUrl, width: 40, height: 40, fit: BoxFit.cover,
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
