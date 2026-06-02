import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 🌟 THE FIX: Added Firestore
import 'package:firebase_auth/firebase_auth.dart'; // 🌟 THE FIX: Added Auth to grab your email
import '../models/app_state.dart';
import '../widgets/page_header.dart';
import '../services/api_service.dart'; 

class AddProductScreen extends StatefulWidget {
  final AppState appState;
  final VoidCallback onStateChanged;
  const AddProductScreen({super.key, required this.appState, required this.onStateChanged});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // 🌟 Controllers
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _cost = TextEditingController();
  final _taxRate = TextEditingController();
  final _sku = TextEditingController();
  final _barcode = TextEditingController();
  final _stock = TextEditingController();
  final _imageUrl = TextEditingController();
  final _description = TextEditingController();
  
  String? _selectedCategory;
  bool _isLoading = false; 

  @override
  void initState() {
    super.initState();
    if (widget.appState.categoryNames.isNotEmpty) {
      _selectedCategory = widget.appState.categoryNames.first;
    }
  }

  @override
  void dispose() {
    _name.dispose(); 
    _price.dispose(); 
    _cost.dispose();
    _taxRate.dispose();
    _sku.dispose();
    _barcode.dispose();
    _stock.dispose();
    _imageUrl.dispose(); 
    _description.dispose();
    super.dispose();
  }

  void _save(bool isDark) async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    try {
      // 🌟 THE FIX: Grab the currently logged-in user to stamp their email!
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception("User not logged in");

      // 🌟 THE FIX: Generate a strict NUMBER ID for Android's SQLite database!
      String newId = DateTime.now().millisecondsSinceEpoch.toString();

      final productData = {
        "id": int.parse(newId), 
        "name": _name.text.trim(),
        "category": _selectedCategory ?? 'Uncategorized',
        "price": double.tryParse(_price.text) ?? 0.0,
        "cost": double.tryParse(_cost.text) ?? 0.0,
        "taxRate": double.tryParse(_taxRate.text) ?? 0.0,
        "sku": _sku.text.trim(),
        "barcode": _barcode.text.trim(),
        "stock": int.tryParse(_stock.text) ?? 0,
        "imageUrl": _imageUrl.text.trim(),
        "description": _description.text.trim(),
        "user_id": currentUser.email, // 🌟 THE FIX: Stamped the email so it shows up!
        "createdAt": FieldValue.serverTimestamp(),
      };

      // 2. Send directly to Firebase!
      await FirebaseFirestore.instance.collection('products').doc(newId).set(productData);

      // 3. Add locally to update the "Recently Added" UI instantly
      widget.appState.addProduct(Product(
        id: newId, 
        name: productData["name"] as String,
        category: productData["category"] as String,
        price: productData["price"] as double,
        cost: productData["cost"] as double,
        taxRate: productData["taxRate"] as double,
        sku: productData["sku"] as String,
        barcode: productData["barcode"] as String,
        stock: productData["stock"] as int,
        imageUrl: (productData["imageUrl"] as String).isEmpty 
            ? 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=80&h=80&fit=crop' 
            : productData["imageUrl"] as String,
        description: productData["description"] as String,
      ));
      
      widget.onStateChanged();
      
      // Clear fields
      _name.clear(); _price.clear(); _cost.clear(); _taxRate.clear(); 
      _sku.clear(); _barcode.clear(); _stock.clear(); _imageUrl.clear(); _description.clear();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Product added successfully! ✅'),
          backgroundColor: const Color(0xFF22C88A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to save to database! $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
    final isMobile = MediaQuery.of(context).size.width < 700;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const PageHeader(title: 'Add Product', subtitle: 'Add a new product to your catalog'),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: bgCard,
            borderRadius: BorderRadius.circular(14),
            border: isDark ? null : Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (isMobile) ...[
                // 📱 MOBILE LAYOUT (Stacked)
                _field('Product Name *', _name, hint: 'e.g. Espresso', isDark: isDark, inputText: inputText, hintColor: hintColor, bgInput: bgInput, labelColor: textMuted),
                const SizedBox(height: 14),
                _catField(isDark: isDark, bgInput: bgInput, inputText: inputText, hintColor: hintColor, labelColor: textMuted),
                const SizedBox(height: 14),
                _field('Description', _description, hint: 'Short product description', maxLines: 3, required: false, isDark: isDark, inputText: inputText, hintColor: hintColor, bgInput: bgInput, labelColor: textMuted),
                const SizedBox(height: 14),
                _field('Price (${widget.appState.currencySymbol}) *', _price, hint: '0.00', type: TextInputType.number, isDark: isDark, inputText: inputText, hintColor: hintColor, bgInput: bgInput, labelColor: textMuted,
                    validator: (v) => double.tryParse(v ?? '') == null ? 'Enter valid price' : null),
                const SizedBox(height: 14),
                _field('Cost (${widget.appState.currencySymbol})', _cost, hint: '0.00', type: TextInputType.number, required: false, isDark: isDark, inputText: inputText, hintColor: hintColor, bgInput: bgInput, labelColor: textMuted),
                const SizedBox(height: 14),
                _field('Tax (%)', _taxRate, hint: '0.0', type: TextInputType.number, required: false, isDark: isDark, inputText: inputText, hintColor: hintColor, bgInput: bgInput, labelColor: textMuted),
                const SizedBox(height: 14),
                _field('Stock Quantity *', _stock, hint: '0', type: TextInputType.number, isDark: isDark, inputText: inputText, hintColor: hintColor, bgInput: bgInput, labelColor: textMuted,
                    validator: (v) => int.tryParse(v ?? '') == null ? 'Enter valid number' : null),
                const SizedBox(height: 14),
                _field('SKU (optional)', _sku, hint: 'e.g. BEV-001', required: false, isDark: isDark, inputText: inputText, hintColor: hintColor, bgInput: bgInput, labelColor: textMuted),
                const SizedBox(height: 14),
                _field('Barcode (optional)', _barcode, hint: 'Scan or type', required: false, isDark: isDark, inputText: inputText, hintColor: hintColor, bgInput: bgInput, labelColor: textMuted),
                const SizedBox(height: 14),
                _field('Image URL (optional)', _imageUrl, hint: 'https://...', required: false, isDark: isDark, inputText: inputText, hintColor: hintColor, bgInput: bgInput, labelColor: textMuted),
              ] else ...[
                // 💻 DESKTOP LAYOUT (Side-by-side)
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(flex: 2, child: _field('Product Name *', _name, hint: 'e.g. Espresso', isDark: isDark, inputText: inputText, hintColor: hintColor, bgInput: bgInput, labelColor: textMuted)),
                  const SizedBox(width: 16),
                  Expanded(flex: 1, child: _catField(isDark: isDark, bgInput: bgInput, inputText: inputText, hintColor: hintColor, labelColor: textMuted)),
                ]),
                const SizedBox(height: 16),
                _field('Description', _description, hint: 'Short product description', maxLines: 2, required: false, isDark: isDark, inputText: inputText, hintColor: hintColor, bgInput: bgInput, labelColor: textMuted),
                const SizedBox(height: 16),
                
                // Pricing Row
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: _field('Price (${widget.appState.currencySymbol}) *', _price, hint: '0.00', type: TextInputType.number, isDark: isDark, inputText: inputText, hintColor: hintColor, bgInput: bgInput, labelColor: textMuted,
                      validator: (v) => double.tryParse(v ?? '') == null ? 'Enter valid price' : null)),
                  const SizedBox(width: 16),
                  Expanded(child: _field('Cost (${widget.appState.currencySymbol})', _cost, hint: '0.00', type: TextInputType.number, required: false, isDark: isDark, inputText: inputText, hintColor: hintColor, bgInput: bgInput, labelColor: textMuted)),
                  const SizedBox(width: 16),
                  Expanded(child: _field('Tax (%)', _taxRate, hint: '0.0', type: TextInputType.number, required: false, isDark: isDark, inputText: inputText, hintColor: hintColor, bgInput: bgInput, labelColor: textMuted)),
                ]),
                const SizedBox(height: 16),
                
                // Inventory Row
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: _field('Stock Quantity *', _stock, hint: '0', type: TextInputType.number, isDark: isDark, inputText: inputText, hintColor: hintColor, bgInput: bgInput, labelColor: textMuted,
                      validator: (v) => int.tryParse(v ?? '') == null ? 'Enter valid number' : null)),
                  const SizedBox(width: 16),
                  Expanded(child: _field('SKU (optional)', _sku, hint: 'e.g. BEV-001', required: false, isDark: isDark, inputText: inputText, hintColor: hintColor, bgInput: bgInput, labelColor: textMuted)),
                  const SizedBox(width: 16),
                  Expanded(child: _field('Barcode (optional)', _barcode, hint: 'Scan or type', required: false, isDark: isDark, inputText: inputText, hintColor: hintColor, bgInput: bgInput, labelColor: textMuted)),
                ]),
                const SizedBox(height: 16),
                
                _field('Image URL (optional)', _imageUrl, hint: 'https://images.unsplash.com/...', required: false, isDark: isDark, inputText: inputText, hintColor: hintColor, bgInput: bgInput, labelColor: textMuted),
              ],
              const SizedBox(height: 24),
              if (_imageUrl.text.isNotEmpty) ...[
                Text('Image Preview', style: TextStyle(color: textMuted, fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                ClipRRect(borderRadius: BorderRadius.circular(8),
                  child: Image.network(_imageUrl.text, width: 80, height: 80, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(width: 80, height: 80,
                      color: isDark ? Colors.white12 : const Color(0xFFF3F4F6),
                      child: Icon(Icons.broken_image, color: isDark ? Colors.white38 : Colors.black26)))),
                const SizedBox(height: 20),
              ],
              Row(children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4B6BFB), foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9))),
                  icon: _isLoading 
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                      : const Icon(Icons.add, size: 18),
                  label: Text(_isLoading ? 'Saving...' : 'Add Product', style: const TextStyle(fontWeight: FontWeight.w600)),
                  onPressed: _isLoading ? null : () => _save(isDark),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () { 
                    _name.clear(); _price.clear(); _cost.clear(); _taxRate.clear(); 
                    _sku.clear(); _barcode.clear(); _stock.clear(); _imageUrl.clear(); _description.clear(); 
                    setState(() {}); 
                  },
                  child: Text('Clear', style: TextStyle(color: textMuted)),
                ),
              ]),
            ]),
          ),
        ),
        const SizedBox(height: 24),
        Text('Recently Added', style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ...widget.appState.products.reversed.take(3).map((p) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: bgCard,
            borderRadius: BorderRadius.circular(10),
            border: isDark ? null : Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(children: [
            ClipRRect(borderRadius: BorderRadius.circular(7),
              child: Image.network(p.imageUrl, width: 40, height: 40, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(width: 40, height: 40,
                  color: isDark ? Colors.white12 : const Color(0xFFF3F4F6),
                  child: Icon(Icons.image, color: isDark ? Colors.white38 : Colors.black26, size: 18)))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.name, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w500)),
              Text('${p.category} • ${widget.appState.currencySymbol}${p.price.toStringAsFixed(2)} • ${p.stock} units',
                style: TextStyle(color: textMuted, fontSize: 11)),
            ])),
          ]),
        )),
      ]),
    );
  }

  Widget _catField({required bool isDark, required Color bgInput, required Color inputText, required Color hintColor, required Color labelColor}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Category *', style: TextStyle(color: labelColor, fontSize: 12, fontWeight: FontWeight.w500)),
      const SizedBox(height: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: bgInput, borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE5E7EB)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedCategory,
            isExpanded: true,
            dropdownColor: isDark ? const Color(0xFF252840) : Colors.white,
            style: TextStyle(color: inputText, fontSize: 14),
            hint: Text('Select category', style: TextStyle(color: hintColor)),
            items: widget.appState.categoryNames.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => setState(() => _selectedCategory = v),
          ),
        ),
      ),
    ]);
  }

  Widget _field(String label, TextEditingController ctrl, {
    String hint = '', int maxLines = 1, TextInputType type = TextInputType.text,
    String? Function(String?)? validator, bool required = true,
    required bool isDark, required Color inputText, required Color hintColor,
    required Color bgInput, required Color labelColor,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(color: labelColor, fontSize: 12, fontWeight: FontWeight.w500)),
      const SizedBox(height: 6),
      TextFormField(
        controller: ctrl, maxLines: maxLines, keyboardType: type,
        onChanged: (_) => setState(() {}), 
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
        validator: validator ?? (v) => (required && (v == null || v.trim().isEmpty)) ? 'Required' : null,
      ),
    ]);
  }
}

