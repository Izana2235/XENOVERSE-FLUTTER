import 'package:flutter/material.dart';
import '../models/app_state.dart';

class ProductFormDialog extends StatefulWidget {
  final Product? product;
  final List<String> categories;
  final String currencySymbol;
  final Function(Product) onSave;

  const ProductFormDialog({
    super.key,
    this.product,
    required this.categories,
    required this.currencySymbol,
    required this.onSave,
  });

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _costCtrl;
  late TextEditingController _taxCtrl;
  late TextEditingController _skuCtrl;
  late TextEditingController _barcodeCtrl;
  late TextEditingController _stockCtrl;
  late TextEditingController _imageCtrl;
  late TextEditingController _descCtrl;
  
  String? _category;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _priceCtrl = TextEditingController(text: p != null ? p.price.toStringAsFixed(2) : '');
    _costCtrl = TextEditingController(text: p != null ? p.cost.toStringAsFixed(2) : '');
    _taxCtrl = TextEditingController(text: p != null ? p.taxRate.toStringAsFixed(2) : '');
    _skuCtrl = TextEditingController(text: p?.sku ?? '');
    _barcodeCtrl = TextEditingController(text: p?.barcode ?? '');
    _stockCtrl = TextEditingController(text: p?.stock.toString() ?? '0');
    _imageCtrl = TextEditingController(text: p?.imageUrl ?? '');
    _descCtrl = TextEditingController(text: p?.description ?? '');

    if (widget.categories.isNotEmpty) {
      _category = p != null && widget.categories.contains(p.category)
          ? p.category
          : widget.categories.first;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _costCtrl.dispose();
    _taxCtrl.dispose();
    _skuCtrl.dispose();
    _barcodeCtrl.dispose();
    _stockCtrl.dispose();
    _imageCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final newProduct = Product(
        id: widget.product?.id ?? '', // ID assigned by backend if empty
        name: _nameCtrl.text.trim(),
        category: _category ?? 'Uncategorized',
        price: double.tryParse(_priceCtrl.text) ?? 0.0,
        cost: double.tryParse(_costCtrl.text) ?? 0.0,
        taxRate: double.tryParse(_taxCtrl.text) ?? 0.0,
        sku: _skuCtrl.text.trim(),
        barcode: _barcodeCtrl.text.trim(),
        stock: int.tryParse(_stockCtrl.text) ?? 0,
        imageUrl: _imageCtrl.text.trim(),
        description: _descCtrl.text.trim(),
      );
      Navigator.pop(context); // Close dialog
      widget.onSave(newProduct); // Pass data back to screen
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1D2E);
    final textMuted = isDark ? Colors.white54 : const Color(0xFF6B7280);
    final bgCard = isDark ? const Color(0xFF1A1D2E) : Colors.white;
    final bgInput = isDark ? const Color(0xFF252840) : const Color(0xFFF3F4F6);
    final border = isDark ? Colors.white12 : const Color(0xFFE5E7EB);

    return Dialog(
      backgroundColor: bgCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.product == null ? 'Create New Item' : 'Edit Item',
                    style: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: textMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: border),
            
            // Scrollable Form
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Info
                      _buildSectionTitle('Item Details', textPrimary),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildTextField('Item Name', _nameCtrl, bgInput, textPrimary, textMuted, border, isRequired: true),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 1,
                            child: _buildDropdown('Category', bgInput, textPrimary, textMuted, border),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField('Description (Optional)', _descCtrl, bgInput, textPrimary, textMuted, border, maxLines: 2),
                      const SizedBox(height: 24),

                      // Pricing
                      _buildSectionTitle('Pricing', textPrimary),
                      Row(
                        children: [
                          Expanded(child: _buildTextField('Price (${widget.currencySymbol})', _priceCtrl, bgInput, textPrimary, textMuted, border, isNumber: true, isRequired: true)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTextField('Cost (${widget.currencySymbol})', _costCtrl, bgInput, textPrimary, textMuted, border, isNumber: true)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTextField('Tax (%)', _taxCtrl, bgInput, textPrimary, textMuted, border, isNumber: true)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Inventory
                      _buildSectionTitle('Inventory & Barcode', textPrimary),
                      Row(
                        children: [
                          Expanded(child: _buildTextField('In Stock', _stockCtrl, bgInput, textPrimary, textMuted, border, isNumber: true)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTextField('SKU', _skuCtrl, bgInput, textPrimary, textMuted, border)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTextField('Barcode', _barcodeCtrl, bgInput, textPrimary, textMuted, border)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Image
                      _buildSectionTitle('Representation', textPrimary),
                      _buildTextField('Image URL', _imageCtrl, bgInput, textPrimary, textMuted, border),
                    ],
                  ),
                ),
              ),
            ),
            Divider(height: 1, color: border),
            
            // Footer Buttons
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(foregroundColor: textMuted),
                    child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22C88A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Save Item', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color textPrimary) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl, Color bg, Color text, Color muted, Color border, {bool isNumber = false, bool isRequired = false, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: muted, fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
          maxLines: maxLines,
          style: TextStyle(color: text, fontSize: 14),
          validator: isRequired ? (v) => v == null || v.isEmpty ? 'Required' : null : null,
          decoration: InputDecoration(
            filled: true, fillColor: bg,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF4B6BFB))),
            errorStyle: const TextStyle(height: 0.1),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, Color bg, Color text, Color muted, Color border) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: muted, fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: border)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _category,
              isExpanded: true,
              dropdownColor: bg,
              style: TextStyle(color: text, fontSize: 14),
              items: widget.categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _category = v),
            ),
          ),
        ),
      ],
    );
  }
}