import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../widgets/product_form_dialog.dart';
import '../widgets/page_header.dart';

class AllProductsScreen extends StatefulWidget {
  final AppState appState;
  final VoidCallback onStateChanged;
  const AllProductsScreen({super.key, required this.appState, required this.onStateChanged});

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  String _cat = 'All';
  String _search = '';

  List<String> get cats => ['All', ...widget.appState.categoryNames];
  List<Product> get filtered => widget.appState.products.where((p) {
    final ok1 = _cat == 'All' || p.category == _cat;
    final ok2 = p.name.toLowerCase().contains(_search.toLowerCase());
    return ok1 && ok2;
  }).toList();

  void _openAddDialog() {
    showDialog(context: context, builder: (_) => ProductFormDialog(
      categories: widget.appState.categoryNames,
      onSave: (p) { widget.appState.addProduct(p); setState(() {}); widget.onStateChanged(); },
    ));
  }

  void _openEditDialog(Product p) {
    showDialog(context: context, builder: (_) => ProductFormDialog(
      product: p, categories: widget.appState.categoryNames,
      onSave: (updated) { widget.appState.updateProduct(p.id, updated); setState(() {}); widget.onStateChanged(); },
    ));
  }

  void _confirmDelete(Product p) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1A1D2E) : Colors.white,
      title: Text('Delete Product', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1A1D2E))),
      content: Text('Delete "${p.name}"? This cannot be undone.',
        style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF6B7280))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
          onPressed: () { Navigator.pop(context); widget.appState.deleteProduct(p.id); setState(() {}); widget.onStateChanged(); },
          child: const Text('Delete'),
        ),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1D2E);
    final textMuted = isDark ? Colors.white54 : const Color(0xFF6B7280);
    final bgCard = isDark ? const Color(0xFF1A1D2E) : Colors.white;
    final bgSearch = isDark ? const Color(0xFF252840) : const Color(0xFFF3F4F6);
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        PageHeader(
          title: 'All Products',
          subtitle: 'Manage your product catalog',
          trailing: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4B6BFB), foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9))),
            icon: const Icon(Icons.add, size: 18),
            label: Text(isMobile ? 'Add' : 'Add Product', style: const TextStyle(fontWeight: FontWeight.w600)),
            onPressed: _openAddDialog,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: bgCard, borderRadius: BorderRadius.circular(12),
            border: isDark ? null : Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(children: [
            TextField(
              onChanged: (v) => setState(() => _search = v),
              style: TextStyle(color: textPrimary, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search products...',
                hintStyle: TextStyle(color: textMuted, fontSize: 13),
                prefixIcon: Icon(Icons.search, color: textMuted, size: 18),
                filled: true, fillColor: bgSearch,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: cats.map((c) => _chip(c, isDark, textMuted)).toList()),
            ),
          ]),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: bgCard, borderRadius: BorderRadius.circular(12),
              border: isDark ? null : Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(children: [
              if (!isMobile) _header(textMuted),
              Divider(color: isDark ? Colors.white12 : const Color(0xFFE5E7EB), height: 1),
              Expanded(
                child: filtered.isEmpty
                    ? Center(child: Text('No products found', style: TextStyle(color: textMuted)))
                    : ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => Divider(color: isDark ? Colors.white12 : const Color(0xFFE5E7EB), height: 1),
                        itemBuilder: (_, i) => isMobile
                            ? _mobileTile(filtered[i], isDark, textPrimary, textMuted)
                            : _desktopRow(filtered[i], isDark, textPrimary, textMuted),
                      ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _chip(String c, bool isDark, Color textMuted) {
    final sel = _cat == c;
    return GestureDetector(
      onTap: () => setState(() => _cat = c),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: sel ? const Color(0xFF4B6BFB) : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          border: sel ? null : Border.all(color: isDark ? Colors.white24 : const Color(0xFFD1D5DB)),
        ),
        child: Text(c, style: TextStyle(
          color: sel ? Colors.white : textMuted,
          fontSize: 12, fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _header(Color textMuted) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(children: [
        Expanded(flex: 4, child: Text('Product', style: TextStyle(color: textMuted, fontWeight: FontWeight.w600, fontSize: 12))),
        Expanded(flex: 2, child: Text('Category', style: TextStyle(color: textMuted, fontWeight: FontWeight.w600, fontSize: 12))),
        Expanded(flex: 2, child: Text('Price', style: TextStyle(color: textMuted, fontWeight: FontWeight.w600, fontSize: 12))),
        Expanded(flex: 2, child: Text('Stock', style: TextStyle(color: textMuted, fontWeight: FontWeight.w600, fontSize: 12))),
        Expanded(flex: 2, child: Text('Actions', style: TextStyle(color: textMuted, fontWeight: FontWeight.w600, fontSize: 12))),
      ]),
    );
  }

  Widget _desktopRow(Product p, bool isDark, Color textPrimary, Color textMuted) {
    final isLow = p.isLowStock;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Row(children: [
        Expanded(flex: 4, child: Row(children: [
          ClipRRect(borderRadius: BorderRadius.circular(7),
            child: Image.network(p.imageUrl, width: 40, height: 40, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(width: 40, height: 40,
                color: isDark ? Colors.white12 : const Color(0xFFF3F4F6),
                child: Icon(Icons.image, color: isDark ? Colors.white38 : Colors.black26, size: 18)))),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.name, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w500, fontSize: 13)),
            Text('ID: ${p.id}', style: TextStyle(color: textMuted, fontSize: 11)),
          ]),
        ])),
        Expanded(flex: 2, child: Text(p.category, style: TextStyle(color: textMuted, fontSize: 13))),
        Expanded(flex: 2, child: Text('₱${p.price.toStringAsFixed(2)}',
          style: TextStyle(color: textPrimary, fontWeight: FontWeight.w500, fontSize: 13))),
        Expanded(flex: 2, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: (isLow ? const Color(0xFFF5C518) : const Color(0xFF22C88A)).withOpacity(0.2),
            borderRadius: BorderRadius.circular(20)),
          child: Text('${p.stock} units', style: TextStyle(
            color: isLow ? const Color(0xFFF5C518) : const Color(0xFF22C88A),
            fontWeight: FontWeight.w600, fontSize: 12)))),
        Expanded(flex: 2, child: Row(children: [
          IconButton(icon: const Icon(Icons.edit_outlined, color: Color(0xFF4B6BFB), size: 18), onPressed: () => _openEditDialog(p)),
          IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18), onPressed: () => _confirmDelete(p)),
        ])),
      ]),
    );
  }

  Widget _mobileTile(Product p, bool isDark, Color textPrimary, Color textMuted) {
    final isLow = p.isLowStock;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(children: [
        ClipRRect(borderRadius: BorderRadius.circular(8),
          child: Image.network(p.imageUrl, width: 44, height: 44, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(width: 44, height: 44,
              color: isDark ? Colors.white12 : const Color(0xFFF3F4F6),
              child: Icon(Icons.image, color: isDark ? Colors.white38 : Colors.black26)))),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(p.name, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w500, fontSize: 13)),
          Text('${p.category} • ₱${p.price.toStringAsFixed(2)}', style: TextStyle(color: textMuted, fontSize: 11)),
          const SizedBox(height: 3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: (isLow ? const Color(0xFFF5C518) : const Color(0xFF22C88A)).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10)),
            child: Text('${p.stock} units', style: TextStyle(
              color: isLow ? const Color(0xFFF5C518) : const Color(0xFF22C88A),
              fontSize: 11, fontWeight: FontWeight.w600))),
        ])),
        Row(children: [
          IconButton(icon: const Icon(Icons.edit_outlined, color: Color(0xFF4B6BFB), size: 18), onPressed: () => _openEditDialog(p)),
          IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18), onPressed: () => _confirmDelete(p)),
        ]),
      ]),
    );
  }
}
