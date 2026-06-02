import 'dart:async'; 
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; 

import '../models/app_state.dart';
import '../widgets/product_form_dialog.dart';
import '../widgets/page_header.dart';

String _currencySymbol(String currency) {
  final match = RegExp(r'\((.+?)\)').firstMatch(currency);
  return match != null ? match.group(1)! : '₱';
}

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
  bool _isLoading = true;
  StreamSubscription? _productSubscription; 

  @override
  void initState() {
    super.initState();
    _listenToLiveProducts();
  }

  @override
  void dispose() {
    _productSubscription?.cancel(); 
    super.dispose();
  }

  void _listenToLiveProducts() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    _productSubscription = FirebaseFirestore.instance
        .collection('products')
        .where('user_id', isEqualTo: currentUser.email) 
        .snapshots()
        .listen((snapshot) {
      
      final List<Product> freshProducts = [];
      
      for (var doc in snapshot.docs) {
        final data = Map<String, dynamic>.from(doc.data());
        
        // 🌟 THE FIX: Hides the product if it was soft-deleted!
        if (data['is_deleted'] == true) continue;

        freshProducts.add(Product(
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
          widget.appState.products.clear();
          widget.appState.products.addAll(freshProducts);
          _isLoading = false;
        });
        widget.onStateChanged(); 
      }
    }, onError: (error) {
      print("🔥 Firebase Listen Error: $error");
      if (mounted) setState(() => _isLoading = false);
    });
  }

  // 👇 THESE ARE THE FUNCTIONS THAT ACCIDENTALLY GOT DELETED
  List<String> get cats => ['All', ...widget.appState.categoryNames];
  
  List<Product> get filtered => widget.appState.products.where((p) {
    final ok1 = _cat == 'All' || p.category == _cat;
    final ok2 = p.name.toLowerCase().contains(_search.toLowerCase());
    return ok1 && ok2;
  }).toList();

  void _openAddDialog() {
    showDialog(context: context, builder: (_) => ProductFormDialog(
      categories: widget.appState.categoryNames,
      currencySymbol: widget.appState.currencySymbol,
      onSave: (p) async { 
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) return;

        setState(() => _isLoading = true); 
        
        try {
          // 🌟 THE FIX: Generate a strict NUMBER ID so Android's SQLite database can read it perfectly!
          String newId = DateTime.now().millisecondsSinceEpoch.toString();
          
          await FirebaseFirestore.instance.collection('products').doc(newId).set({
            "id": int.parse(newId), // We explicitly hand Android the number format!
            "name": p.name,
            "category": p.category,
            "price": p.price,
            "cost": p.cost,
            "taxRate": p.taxRate,
            "sku": p.sku,
            "barcode": p.barcode,
            "stock": p.stock,
            "imageUrl": p.imageUrl,
            "description": p.description,
            "user_id": currentUser.email, 
            "createdAt": FieldValue.serverTimestamp(),
          });
        } catch (e) {
          print("Error adding product: $e");
        } finally {
          if (mounted) setState(() => _isLoading = false);
        }
      },
    ));
  }

  void _openEditDialog(Product p) {
    showDialog(context: context, builder: (_) => ProductFormDialog(
      product: p, 
      categories: widget.appState.categoryNames,
      currencySymbol: widget.appState.currencySymbol,
      onSave: (updated) async { 
        setState(() => _isLoading = true);
        
        try {
          await FirebaseFirestore.instance.collection('products').doc(p.id).update({
            "name": updated.name,
            "category": updated.category,
            "price": updated.price,
            "cost": updated.cost,
            "taxRate": updated.taxRate,
            "sku": updated.sku,
            "barcode": updated.barcode,
            "stock": updated.stock,
            "imageUrl": updated.imageUrl,
            "description": updated.description,
          });
        } catch (e) {
           print("Error updating product: $e");
        } finally {
           if (mounted) setState(() => _isLoading = false);
        }
      },
    ));
  }
  // 👆 

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
          onPressed: () async { 
            Navigator.pop(context); 
            
            try {
              // 🌟 THE HARD DELETE FIX: Completely vaporize the item from Firebase!
              await FirebaseFirestore.instance.collection('products').doc(p.id).delete();
              
            } catch (e) {
               if (mounted) {
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text('Failed to delete product from server.')),
                 );
               }
            }
          },
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

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF4B6BFB)));
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        PageHeader(
          title: 'All Products',
          subtitle: 'Manage your product catalog',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4B6BFB), foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9))),
                icon: const Icon(Icons.add, size: 18),
                label: Text(isMobile ? 'Add' : 'Add Product', style: const TextStyle(fontWeight: FontWeight.w600)),
                onPressed: _openAddDialog,
              ),
            ],
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
        const SizedBox(height: 16),
        
        Expanded(
          child: filtered.isEmpty
            ? Center(child: Text('No products found', style: TextStyle(color: textMuted)))
            : LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = 2;
                  if (constraints.maxWidth > 1200) {
                    crossAxisCount = 5;
                  } else if (constraints.maxWidth > 900) crossAxisCount = 4;
                  else if (constraints.maxWidth > 600) crossAxisCount = 3;

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 0.75, 
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      return _buildProductCard(filtered[index], isDark, textPrimary, textMuted, bgCard);
                    },
                  );
                },
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

  Widget _buildProductCard(Product p, bool isDark, Color textPrimary, Color textMuted, Color bgCard) {
    final isLow = p.isLowStock;
    final currency = _currencySymbol(widget.appState.currency);
    
    final displayImage = p.imageUrl.isNotEmpty 
        ? p.imageUrl 
        : 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=80&h=80&fit=crop';

    return Container(
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: Colors.white12) : Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Container(
                    width: double.infinity,
                    color: isDark ? const Color(0xFF252840) : const Color(0xFFF3F4F6),
                    child: Image.network(
                      displayImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.fastfood_outlined, 
                        size: 40, 
                        color: isDark ? Colors.white24 : Colors.black12,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black54 : Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(6),
                          icon: const Icon(Icons.edit_outlined, color: Color(0xFF4B6BFB), size: 16),
                          onPressed: () => _openEditDialog(p),
                        ),
                        IconButton(
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(6),
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 16),
                          onPressed: () => _confirmDelete(p),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        p.category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$currency${p.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Color(0xFF4B6BFB),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (isLow ? const Color(0xFFF5C518) : const Color(0xFF22C88A)).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${p.stock} left',
                          style: TextStyle(
                            color: isLow ? const Color(0xFFF5C518) : const Color(0xFF22C88A),
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
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