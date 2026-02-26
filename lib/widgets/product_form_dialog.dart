import 'package:flutter/material.dart';
import '../models/app_state.dart';

class ProductFormDialog extends StatefulWidget {
  final Product? product;
  final List<String> categories;
  final void Function(Product) onSave;

  const ProductFormDialog({super.key, this.product, required this.categories, required this.onSave});

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name, _price, _stock, _imageUrl, _description;
  late String _selectedCategory;

  bool get isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.product?.name ?? '');
    _price = TextEditingController(text: widget.product?.price.toStringAsFixed(2) ?? '');
    _stock = TextEditingController(text: widget.product?.stock.toString() ?? '');
    _imageUrl = TextEditingController(text: widget.product?.imageUrl ?? '');
    _description = TextEditingController(text: widget.product?.description ?? '');
    _selectedCategory = widget.product?.category ?? (widget.categories.isNotEmpty ? widget.categories.first : '');
  }

  @override
  void dispose() {
    _name.dispose(); _price.dispose(); _stock.dispose(); _imageUrl.dispose(); _description.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSave(Product(
      id: widget.product?.id ?? 'P${DateTime.now().millisecondsSinceEpoch}',
      name: _name.text.trim(), category: _selectedCategory,
      price: double.tryParse(_price.text) ?? 0,
      stock: int.tryParse(_stock.text) ?? 0,
      imageUrl: _imageUrl.text.trim().isEmpty
          ? 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=80&h=80&fit=crop'
          : _imageUrl.text.trim(),
      description: _description.text.trim(),
    ));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1D2E);
    final textMuted = isDark ? Colors.white54 : const Color(0xFF6B7280);
    final bgDialog = isDark ? const Color(0xFF1A1D2E) : Colors.white;
    final bgInput = isDark ? const Color(0xFF252840) : const Color(0xFFF3F4F6);
    final hintColor = isDark ? Colors.white38 : const Color(0xFF9CA3AF);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Dialog(
      backgroundColor: bgDialog,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: isMobile ? double.infinity : 520,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(isEditing ? 'Edit Product' : 'Add New Product',
                  style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(icon: Icon(Icons.close, color: textMuted), onPressed: () => Navigator.pop(context)),
              ]),
              const SizedBox(height: 20),
              _field('Product Name', _name, hint: 'e.g. Espresso', isDark: isDark, textPrimary: textPrimary, textMuted: textMuted, bgInput: bgInput, hintColor: hintColor),
              const SizedBox(height: 14),
              _field('Description', _description, hint: 'Short product description', maxLines: 2, isDark: isDark, textPrimary: textPrimary, textMuted: textMuted, bgInput: bgInput, hintColor: hintColor),
              const SizedBox(height: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Category', style: TextStyle(color: textMuted, fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: bgInput, borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE5E7EB)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: widget.categories.contains(_selectedCategory) ? _selectedCategory : (widget.categories.isNotEmpty ? widget.categories.first : null),
                      dropdownColor: isDark ? const Color(0xFF252840) : Colors.white,
                      style: TextStyle(color: textPrimary),
                      isExpanded: true,
                      items: widget.categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => setState(() => _selectedCategory = v!),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: _field('Price (₱)', _price, hint: '0.00', keyboardType: TextInputType.number, isDark: isDark, textPrimary: textPrimary, textMuted: textMuted, bgInput: bgInput, hintColor: hintColor,
                    validator: (v) => double.tryParse(v ?? '') == null ? 'Enter valid price' : null)),
                const SizedBox(width: 12),
                Expanded(child: _field('Stock Quantity', _stock, hint: '0', keyboardType: TextInputType.number, isDark: isDark, textPrimary: textPrimary, textMuted: textMuted, bgInput: bgInput, hintColor: hintColor,
                    validator: (v) => int.tryParse(v ?? '') == null ? 'Enter valid number' : null)),
              ]),
              const SizedBox(height: 14),
              _field('Image URL (optional)', _imageUrl, hint: 'https://...', isDark: isDark, textPrimary: textPrimary, textMuted: textMuted, bgInput: bgInput, hintColor: hintColor),
              const SizedBox(height: 24),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                TextButton(onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: textMuted))),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4B6BFB), foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _save,
                  child: Text(isEditing ? 'Save Changes' : 'Add Product'),
                ),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {
    String hint = '', int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    required bool isDark, required Color textPrimary, required Color textMuted,
    required Color bgInput, required Color hintColor,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(color: textMuted, fontSize: 12, fontWeight: FontWeight.w500)),
      const SizedBox(height: 6),
      TextFormField(
        controller: ctrl, maxLines: maxLines, keyboardType: keyboardType,
        style: TextStyle(color: textPrimary, fontSize: 14),
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
        validator: validator ?? (v) => (v == null || v.trim().isEmpty) ? 'This field is required' : null,
      ),
    ]);
  }
}
