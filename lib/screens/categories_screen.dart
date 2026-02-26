import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../widgets/page_header.dart';

// ─── Product Categories (under Products menu) ─────────────────────────────────
// Purpose: Overview of categories showing product counts and stats
class ProductCategoriesScreen extends StatelessWidget {
  final AppState appState;
  final VoidCallback onStateChanged;
  const ProductCategoriesScreen({super.key, required this.appState, required this.onStateChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1D2E);
    final textMuted = isDark ? Colors.white54 : const Color(0xFF6B7280);
    final bgCard = isDark ? const Color(0xFF1A1D2E) : Colors.white;
    final cardShadow = isDark
        ? <BoxShadow>[]
        : [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))];

    final cats = appState.categories;
    final totalProducts = appState.products.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const PageHeader(
          title: 'Product Categories',
          subtitle: 'Overview of your product catalog by category',
        ),
        const SizedBox(height: 20),

        // ── Summary bar ────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgCard,
            borderRadius: BorderRadius.circular(12),
            border: isDark ? null : Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: cardShadow,
          ),
          child: Row(children: [
            _summaryTile(
              icon: Icons.category_outlined,
              color: const Color(0xFF4B6BFB),
              label: 'Total Categories',
              value: '${cats.length}',
              isDark: isDark,
              textPrimary: textPrimary,
              textMuted: textMuted,
            ),
            _divider(isDark),
            _summaryTile(
              icon: Icons.inventory_2_outlined,
              color: const Color(0xFF22C88A),
              label: 'Total Products',
              value: '$totalProducts',
              isDark: isDark,
              textPrimary: textPrimary,
              textMuted: textMuted,
            ),
            _divider(isDark),
            _summaryTile(
              icon: Icons.warning_amber_outlined,
              color: const Color(0xFFF5C518),
              label: 'Low Stock Items',
              value: '${appState.lowStockProducts.length}',
              isDark: isDark,
              textPrimary: textPrimary,
              textMuted: textMuted,
            ),
          ]),
        ),
        const SizedBox(height: 20),

        // ── Category breakdown cards ───────────────────────────────────
        Text('Category Breakdown',
            style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),

        LayoutBuilder(builder: (context, c) {
          final cols = c.maxWidth < 500 ? 1 : c.maxWidth < 800 ? 2 : 3;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.6,
            ),
            itemCount: cats.length,
            itemBuilder: (_, i) {
              final cat = cats[i];
              final count = appState.productCountByCategory(cat.name);
              final products = appState.products.where((p) => p.category == cat.name).toList();
              final lowStockCount = products.where((p) => p.isLowStock).length;
              final pct = totalProducts == 0 ? 0.0 : count / totalProducts;

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: bgCard,
                  borderRadius: BorderRadius.circular(12),
                  border: isDark ? null : Border.all(color: const Color(0xFFE5E7EB)),
                  boxShadow: cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Text(cat.icon, style: const TextStyle(fontSize: 26)),
                      const SizedBox(width: 10),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(cat.name,
                            style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                            overflow: TextOverflow.ellipsis),
                        Text(cat.description,
                            style: TextStyle(color: textMuted, fontSize: 11),
                            overflow: TextOverflow.ellipsis, maxLines: 1),
                      ])),
                    ]),
                    const SizedBox(height: 8),
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 5,
                        backgroundColor: isDark ? Colors.white12 : const Color(0xFFE5E7EB),
                        valueColor: const AlwaysStoppedAnimation(Color(0xFF4B6BFB)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('$count product${count != 1 ? 's' : ''}',
                          style: const TextStyle(color: Color(0xFF4B6BFB), fontSize: 12, fontWeight: FontWeight.w600)),
                      if (lowStockCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5C518).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('$lowStockCount low stock',
                              style: const TextStyle(color: Color(0xFFF5C518), fontSize: 10, fontWeight: FontWeight.w600)),
                        )
                      else
                        Text('${(pct * 100).toStringAsFixed(0)}% of catalog',
                            style: TextStyle(color: textMuted, fontSize: 11)),
                    ]),
                  ],
                ),
              );
            },
          );
        }),
        const SizedBox(height: 20),

        // ── Products list per category ─────────────────────────────────
        Text('Products by Category',
            style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),

        ...cats.map((cat) {
          final products = appState.products.where((p) => p.category == cat.name).toList();
          if (products.isEmpty) return const SizedBox.shrink();
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: bgCard,
              borderRadius: BorderRadius.circular(12),
              border: isDark ? null : Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: cardShadow,
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(children: [
                  Text(cat.icon, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(cat.name,
                      style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4B6BFB).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('${products.length} items',
                        style: const TextStyle(color: Color(0xFF4B6BFB), fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ]),
              ),
              Divider(color: isDark ? Colors.white12 : const Color(0xFFE5E7EB), height: 1),
              ...products.map((p) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(p.imageUrl, width: 36, height: 36, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                            width: 36, height: 36,
                            color: isDark ? Colors.white12 : const Color(0xFFF3F4F6),
                            child: Icon(Icons.image, size: 16, color: isDark ? Colors.white38 : Colors.black26))),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(p.name,
                      style: TextStyle(color: textPrimary, fontSize: 13),
                      overflow: TextOverflow.ellipsis)),
                  const SizedBox(width: 8),
                  Text('₱${p.price.toStringAsFixed(2)}',
                      style: TextStyle(color: textMuted, fontSize: 12)),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (p.isLowStock ? const Color(0xFFF5C518) : const Color(0xFF22C88A)).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('${p.stock} units',
                        style: TextStyle(
                            color: p.isLowStock ? const Color(0xFFF5C518) : const Color(0xFF22C88A),
                            fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ]),
              )),
            ]),
          );
        }),
      ]),
    );
  }

  Widget _summaryTile({
    required IconData icon, required Color color, required String label, required String value,
    required bool isDark, required Color textPrimary, required Color textMuted,
  }) {
    return Expanded(child: Column(children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: color, size: 18),
      ),
      const SizedBox(height: 6),
      Text(value, style: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
      Text(label, style: TextStyle(color: textMuted, fontSize: 11), textAlign: TextAlign.center),
    ]));
  }

  Widget _divider(bool isDark) => Container(
    width: 1, height: 50,
    color: isDark ? Colors.white12 : const Color(0xFFE5E7EB),
    margin: const EdgeInsets.symmetric(horizontal: 8),
  );
}

// ─── All Categories (under Categories menu) ───────────────────────────────────
// Purpose: Full CRUD — add new categories inline, edit & delete existing
class AllCategoriesScreen extends StatefulWidget {
  final AppState appState;
  final VoidCallback onStateChanged;
  const AllCategoriesScreen({super.key, required this.appState, required this.onStateChanged});

  @override
  State<AllCategoriesScreen> createState() => _AllCategoriesScreenState();
}

class _AllCategoriesScreenState extends State<AllCategoriesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _icon = '📦';
  final _icons = ['📦', '☕', '🥐', '🥗', '🍕', '🍔', '🥤', '🍰', '🍜', '🧁', '🥩', '🍱',
                  '👗', '👟', '💄', '🏠', '🔧', '📱', '💻', '🎮', '📚', '🌿'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    widget.appState.addCategory(Category(
      id: 'C${DateTime.now().millisecondsSinceEpoch}',
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      icon: _icon,
    ));
    widget.onStateChanged();
    _nameCtrl.clear();
    _descCtrl.clear();
    setState(() => _icon = '📦');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Category added! ✅'),
      backgroundColor: const Color(0xFF22C88A),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ));
  }

  void _showEditDialog(Category cat) {
    final nameCtrl = TextEditingController(text: cat.name);
    final descCtrl = TextEditingController(text: cat.description);
    String icon = cat.icon;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgDialog = isDark ? const Color(0xFF1A1D2E) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1D2E);
    final textMuted = isDark ? Colors.white70 : const Color(0xFF6B7280);
    final bgInput = isDark ? const Color(0xFF252840) : const Color(0xFFF3F4F6);
    final inputText = isDark ? Colors.white : const Color(0xFF1A1D2E);
    final hintColor = isDark ? Colors.white38 : const Color(0xFF9CA3AF);

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: bgDialog,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Text('Edit Category', style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            _tfWidget('Name', nameCtrl, isDark: isDark, bgInput: bgInput, inputText: inputText, hintColor: hintColor, labelColor: textMuted),
            const SizedBox(height: 12),
            _tfWidget('Description', descCtrl, isDark: isDark, bgInput: bgInput, inputText: inputText, hintColor: hintColor, labelColor: textMuted),
            const SizedBox(height: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Icon', style: TextStyle(color: textMuted, fontSize: 12)),
              const SizedBox(height: 8),
              Wrap(spacing: 6, runSpacing: 6,
                children: _icons.map((e) => GestureDetector(
                  onTap: () => setS(() => icon = e),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: icon == e ? const Color(0xFF4B6BFB).withOpacity(0.25) : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: icon == e
                          ? Border.all(color: const Color(0xFF4B6BFB))
                          : Border.all(color: Colors.transparent),
                    ),
                    child: Text(e, style: const TextStyle(fontSize: 18)),
                  ),
                )).toList(),
              ),
            ]),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx),
                child: Text('Cancel', style: TextStyle(color: textMuted))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4B6BFB), foregroundColor: Colors.white),
              onPressed: () {
                widget.appState.updateCategory(cat.id,
                    Category(id: cat.id, name: nameCtrl.text.trim(), description: descCtrl.text.trim(), icon: icon));
                Navigator.pop(ctx);
                setState(() {});
                widget.onStateChanged();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(Category cat) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1D2E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text('Delete Category',
            style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1A1D2E), fontWeight: FontWeight.bold)),
        content: Text('Delete "${cat.name}"? Products in this category will remain.',
            style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF6B7280))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: isDark ? Colors.white54 : const Color(0xFF6B7280)))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              widget.appState.deleteCategory(cat.id);
              setState(() {});
              widget.onStateChanged();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
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
    final cardShadow = isDark
        ? <BoxShadow>[]
        : [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))];

    final cats = widget.appState.categories;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const PageHeader(title: 'All Categories', subtitle: 'Add, edit, and delete your categories'),
        const SizedBox(height: 20),

        // ── Add New Category form ─────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: bgCard,
            borderRadius: BorderRadius.circular(14),
            border: isDark ? null : Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: cardShadow,
          ),
          child: Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.add_circle_outline, color: Color(0xFF4B6BFB), size: 18),
                const SizedBox(width: 8),
                Text('Add New Category',
                    style: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 16),
              LayoutBuilder(builder: (context, c) {
                final isMobile = c.maxWidth < 500;
                if (isMobile) {
                  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _tf(label: 'Category Name *', ctrl: _nameCtrl, hint: 'e.g. Beverages',
                        isDark: isDark, bgInput: bgInput, inputText: inputText, hintColor: hintColor, labelColor: textMuted),
                    const SizedBox(height: 12),
                    _tf(label: 'Description', ctrl: _descCtrl, hint: 'Brief description', required: false, maxLines: 2,
                        isDark: isDark, bgInput: bgInput, inputText: inputText, hintColor: hintColor, labelColor: textMuted),
                  ]);
                }
                return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: _tf(label: 'Category Name *', ctrl: _nameCtrl, hint: 'e.g. Beverages',
                      isDark: isDark, bgInput: bgInput, inputText: inputText, hintColor: hintColor, labelColor: textMuted)),
                  const SizedBox(width: 14),
                  Expanded(child: _tf(label: 'Description', ctrl: _descCtrl, hint: 'Brief description', required: false, maxLines: 2,
                      isDark: isDark, bgInput: bgInput, inputText: inputText, hintColor: hintColor, labelColor: textMuted)),
                ]);
              }),
              const SizedBox(height: 14),
              Text('Choose Icon', style: TextStyle(color: textMuted, fontSize: 12, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: _icons.map((e) => GestureDetector(
                  onTap: () => setState(() => _icon = e),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _icon == e ? const Color(0xFF4B6BFB).withOpacity(0.2) : bgInput,
                      borderRadius: BorderRadius.circular(8),
                      border: _icon == e
                          ? Border.all(color: const Color(0xFF4B6BFB), width: 2)
                          : Border.all(color: isDark ? Colors.white12 : const Color(0xFFE5E7EB)),
                    ),
                    child: Text(e, style: const TextStyle(fontSize: 20)),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4B6BFB), foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Category', style: TextStyle(fontWeight: FontWeight.w600)),
                onPressed: _save,
              ),
            ]),
          ),
        ),
        const SizedBox(height: 24),

        // ── Existing categories list ───────────────────────────────────
        Row(children: [
          Text('Existing Categories',
              style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF4B6BFB).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('${cats.length}',
                style: const TextStyle(color: Color(0xFF4B6BFB), fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ]),
        const SizedBox(height: 12),

        cats.isEmpty
            ? Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: bgCard, borderRadius: BorderRadius.circular(12),
                  border: isDark ? null : Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Center(child: Column(children: [
                  Icon(Icons.category_outlined, color: textMuted, size: 40),
                  const SizedBox(height: 10),
                  Text('No categories yet. Add one above!', style: TextStyle(color: textMuted)),
                ])),
              )
            : Container(
                decoration: BoxDecoration(
                  color: bgCard, borderRadius: BorderRadius.circular(12),
                  border: isDark ? null : Border.all(color: const Color(0xFFE5E7EB)),
                  boxShadow: cardShadow,
                ),
                child: Column(
                  children: cats.asMap().entries.map((entry) {
                    final i = entry.key;
                    final cat = entry.value;
                    final count = widget.appState.productCountByCategory(cat.name);
                    final isLast = i == cats.length - 1;
                    return Column(children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(children: [
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4B6BFB).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(child: Text(cat.icon, style: const TextStyle(fontSize: 22))),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(cat.name,
                                style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                            Text(cat.description.isEmpty ? 'No description' : cat.description,
                                style: TextStyle(color: textMuted, fontSize: 12),
                                overflow: TextOverflow.ellipsis),
                          ])),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF22C88A).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text('$count products',
                                style: const TextStyle(color: Color(0xFF22C88A), fontSize: 11, fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: Color(0xFF4B6BFB), size: 18),
                            onPressed: () => _showEditDialog(cat),
                            tooltip: 'Edit',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                            onPressed: () => _confirmDelete(cat),
                            tooltip: 'Delete',
                          ),
                        ]),
                      ),
                      if (!isLast) Divider(color: isDark ? Colors.white12 : const Color(0xFFE5E7EB), height: 1),
                    ]);
                  }).toList(),
                ),
              ),
      ]),
    );
  }

  Widget _tf({
    required String label, required TextEditingController ctrl, required String hint,
    bool required = true, int maxLines = 1,
    required bool isDark, required Color bgInput, required Color inputText,
    required Color hintColor, required Color labelColor,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(color: labelColor, fontSize: 12, fontWeight: FontWeight.w500)),
      const SizedBox(height: 6),
      TextFormField(
        controller: ctrl, maxLines: maxLines,
        style: TextStyle(color: inputText, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint, hintStyle: TextStyle(color: hintColor, fontSize: 13),
          filled: true, fillColor: bgInput,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: isDark ? Colors.transparent : const Color(0xFFE5E7EB))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF4B6BFB))),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        validator: (v) => (required && (v == null || v.trim().isEmpty)) ? 'Required' : null,
      ),
    ]);
  }
}

// ─── Manage Categories (under Categories menu) ────────────────────────────────
// Purpose: Reorder via drag-and-drop, bulk delete, search/filter
class ManageCategoriesScreen extends StatefulWidget {
  final AppState appState;
  final VoidCallback onStateChanged;
  const ManageCategoriesScreen({super.key, required this.appState, required this.onStateChanged});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  final Set<String> _selected = {};
  String _search = '';
  bool _selectionMode = false;

  List<Category> get _filtered => widget.appState.categories
      .where((c) => c.name.toLowerCase().contains(_search.toLowerCase()))
      .toList();

  void _toggleSelect(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
      _selectionMode = _selected.isNotEmpty;
    });
  }

  void _selectAll() {
    setState(() {
      if (_selected.length == _filtered.length) {
        _selected.clear();
        _selectionMode = false;
      } else {
        _selected.addAll(_filtered.map((c) => c.id));
        _selectionMode = true;
      }
    });
  }

  void _bulkDelete() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1D2E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text('Delete ${_selected.length} Categories',
            style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1A1D2E), fontWeight: FontWeight.bold)),
        content: Text('This will permanently delete the selected categories. Products will remain.',
            style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF6B7280))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: isDark ? Colors.white54 : const Color(0xFF6B7280)))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              for (final id in _selected) {
                widget.appState.deleteCategory(id);
              }
              setState(() { _selected.clear(); _selectionMode = false; });
              widget.onStateChanged();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Categories deleted'),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
              ));
            },
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1D2E);
    final textMuted = isDark ? Colors.white54 : const Color(0xFF6B7280);
    final bgCard = isDark ? const Color(0xFF1A1D2E) : Colors.white;
    final bgSearch = isDark ? const Color(0xFF252840) : const Color(0xFFF3F4F6);
    final cardShadow = isDark
        ? <BoxShadow>[]
        : [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))];

    final cats = _filtered;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        PageHeader(
          title: 'Manage Categories',
          subtitle: 'Reorder and bulk manage your categories',
          trailing: _selectionMode
              ? Row(mainAxisSize: MainAxisSize.min, children: [
                  TextButton(
                    onPressed: () => setState(() { _selected.clear(); _selectionMode = false; }),
                    child: Text('Cancel', style: TextStyle(color: textMuted)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent, foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                    ),
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: Text('Delete (${_selected.length})'),
                    onPressed: _bulkDelete,
                  ),
                ])
              : null,
        ),
        const SizedBox(height: 20),

        // ── Info banner ────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF4B6BFB).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF4B6BFB).withOpacity(0.3)),
          ),
          child: Row(children: [
            const Icon(Icons.info_outline, color: Color(0xFF4B6BFB), size: 16),
            const SizedBox(width: 8),
            Expanded(child: Text(
              'Drag the ⠿ handle to reorder categories. Tap a row to select for bulk delete.',
              style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF1A1D2E), fontSize: 12),
            )),
          ]),
        ),
        const SizedBox(height: 16),

        // ── Search + select all ────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: bgCard, borderRadius: BorderRadius.circular(12),
            border: isDark ? null : Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: cardShadow,
          ),
          child: Row(children: [
            Expanded(
              child: TextField(
                onChanged: (v) => setState(() => _search = v),
                style: TextStyle(color: textPrimary, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Search categories...',
                  hintStyle: TextStyle(color: textMuted, fontSize: 13),
                  prefixIcon: Icon(Icons.search, color: textMuted, size: 18),
                  filled: true, fillColor: bgSearch,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 10),
            TextButton.icon(
              onPressed: _selectAll,
              icon: Icon(
                _selected.length == cats.length && cats.isNotEmpty
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
                size: 18,
                color: const Color(0xFF4B6BFB),
              ),
              label: Text('Select All', style: TextStyle(color: const Color(0xFF4B6BFB), fontSize: 12)),
            ),
          ]),
        ),
        const SizedBox(height: 14),

        // ── Drag-and-drop reorder list ─────────────────────────────────
        cats.isEmpty
            ? Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: bgCard, borderRadius: BorderRadius.circular(12),
                  border: isDark ? null : Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Center(child: Text('No categories found', style: TextStyle(color: textMuted))),
              )
            : Container(
                decoration: BoxDecoration(
                  color: bgCard, borderRadius: BorderRadius.circular(12),
                  border: isDark ? null : Border.all(color: const Color(0xFFE5E7EB)),
                  boxShadow: cardShadow,
                ),
                child: ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  buildDefaultDragHandles: false,
                  itemCount: cats.length,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) newIndex--;
                      final allCats = widget.appState.categories;
                      final oldInAll = allCats.indexOf(cats[oldIndex]);
                      final newInAll = allCats.indexOf(cats[newIndex]);
                      final item = allCats.removeAt(oldInAll);
                      allCats.insert(newInAll, item);
                    });
                    widget.onStateChanged();
                  },
                  itemBuilder: (_, i) {
                    final cat = cats[i];
                    final count = widget.appState.productCountByCategory(cat.name);
                    final isSelected = _selected.contains(cat.id);
                    final isLast = i == cats.length - 1;

                    return Column(
                      key: ValueKey(cat.id),
                      children: [
                        InkWell(
                          onTap: () => _toggleSelect(cat.id),
                          borderRadius: i == 0
                              ? const BorderRadius.vertical(top: Radius.circular(12))
                              : (isLast ? const BorderRadius.vertical(bottom: Radius.circular(12)) : BorderRadius.zero),
                          child: Container(
                            color: isSelected
                                ? const Color(0xFF4B6BFB).withOpacity(isDark ? 0.2 : 0.08)
                                : Colors.transparent,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(children: [
                              // Checkbox
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                width: isSelected || _selectionMode ? 28 : 0,
                                child: isSelected || _selectionMode
                                    ? Icon(
                                        isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                                        color: const Color(0xFF4B6BFB), size: 20)
                                    : null,
                              ),
                              // Icon
                              Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4B6BFB).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(child: Text(cat.icon, style: const TextStyle(fontSize: 20))),
                              ),
                              const SizedBox(width: 12),
                              // Name + description
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(cat.name,
                                    style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                                Text(cat.description.isEmpty ? 'No description' : cat.description,
                                    style: TextStyle(color: textMuted, fontSize: 12),
                                    overflow: TextOverflow.ellipsis),
                              ])),
                              // Product count badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF22C88A).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text('$count products',
                                    style: const TextStyle(color: Color(0xFF22C88A), fontSize: 11, fontWeight: FontWeight.w600)),
                              ),
                              const SizedBox(width: 8),
                              // Drag handle
                              ReorderableDragStartListener(
                                index: i,
                                child: Icon(
                                  Icons.drag_indicator,
                                  color: isDark ? Colors.white38 : const Color(0xFFB0B7C3),
                                  size: 20,
                                ),
                              ),
                            ]),
                          ),
                        ),
                        if (!isLast) Divider(color: isDark ? Colors.white12 : const Color(0xFFE5E7EB), height: 1),
                      ],
                    );
                  },
                ),
              ),

        const SizedBox(height: 12),
        // ── Footer hint ────────────────────────────────────────────────
        if (cats.isNotEmpty)
          Center(
            child: Text(
              '${cats.length} categor${cats.length != 1 ? 'ies' : 'y'} • ${_selected.length} selected',
              style: TextStyle(color: textMuted, fontSize: 12),
            ),
          ),
      ]),
    );
  }
}

// ─── Add Category Screen (standalone route) ───────────────────────────────────
class AddCategoryScreen extends StatelessWidget {
  final AppState appState;
  final VoidCallback onStateChanged;
  const AddCategoryScreen({super.key, required this.appState, required this.onStateChanged});

  @override
  Widget build(BuildContext context) {
    return AllCategoriesScreen(appState: appState, onStateChanged: onStateChanged);
  }
}

// ─── Shared text field helper ─────────────────────────────────────────────────
Widget _tfWidget(String label, TextEditingController ctrl, {
  required bool isDark, required Color bgInput, required Color inputText,
  required Color hintColor, required Color labelColor,
}) {
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: TextStyle(color: labelColor, fontSize: 12)),
    const SizedBox(height: 5),
    TextField(
      controller: ctrl,
      style: TextStyle(color: inputText, fontSize: 13),
      decoration: InputDecoration(
        filled: true, fillColor: bgInput,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(7), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(7),
            borderSide: BorderSide(color: isDark ? Colors.transparent : const Color(0xFFE5E7EB))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(7),
            borderSide: const BorderSide(color: Color(0xFF4B6BFB))),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    ),
  ]);
}
