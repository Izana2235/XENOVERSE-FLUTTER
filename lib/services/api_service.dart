import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 🌟 THE FIX: Imported Auth to grab your email!
import '../models/app_state.dart'; 

class WebApiService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🌟 Helper to get the current user's email securely
  static String get _currentUserEmail {
    return FirebaseAuth.instance.currentUser?.email ?? 'admin';
  }

  // --- FETCH PRODUCTS ---
  static Future<List<Product>> getProducts() async {
    try {
      // 🌟 THE FIX: Only fetch products that belong to YOU
      final snapshot = await _db.collection('products')
          .where('user_id', isEqualTo: _currentUserEmail)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Product(
          id: doc.id,
          name: data['name'] ?? 'Unnamed',
          category: data['category'] ?? 'General',
          price: double.tryParse(data['price']?.toString() ?? '0') ?? 0.0,
          stock: int.tryParse(data['stock']?.toString() ?? '0') ?? 0,
          imageUrl: data['image_path'] ?? data['image_url'] ?? '', 
          description: data['description'] ?? '', 
        );
      }).toList();
    } catch (e) {
      print("❌ Firebase Fetch Error: $e");
      return [];
    }
  }

  // --- DELETE A PRODUCT ---
  static Future<bool> deleteProduct(String id) async {
    try {
      await _db.collection('products').doc(id).delete();
      print("🗑️ Successfully deleted from Firebase!");
      return true;
    } catch (e) {
      print("❌ Firebase Delete Error: $e");
      return false;
    }
  }

  // --- FETCH ORDERS (For Revenue) ---
  static Future<List<dynamic>> getOrders() async {
    try {
      final snapshot = await _db.collection('orders')
          .where('user_id', isEqualTo: _currentUserEmail)
          .get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print("❌ Order Fetch Error: $e");
      return [];
    }
  }

  // --- ADD A PRODUCT FROM WEB ---
  static Future<bool> addProduct(Map<String, dynamic> productData) async {
    try {
      String docId = DateTime.now().millisecondsSinceEpoch.toString();
      
      await _db.collection('products').doc(docId).set({
        'id': int.parse(docId), 
        'name': productData['name'],
        'category': productData['category'],
        'price': productData['price'],
        'cost': productData['cost'] ?? 0.0,
        'taxRate': productData['taxRate'] ?? 0.0,
        'sku': productData['sku'] ?? '',
        'barcode': productData['barcode'] ?? '',
        'stock': productData['stock'],
        'image_path': productData['imageUrl'] ?? '', 
        'description': productData['description'] ?? '',
        'is_synced': 1,
        'user_id': _currentUserEmail, // 🌟 THE FIX: Stamp your email so Android sees it!
      });
      return true;
    } catch (e) {
      print("❌ Firebase Add Error: $e");
      return false;
    }
  }

  // --- UPDATE A PRODUCT FROM WEB ---
  static Future<bool> updateProduct(String id, Map<String, dynamic> productData) async {
    try {
      await _db.collection('products').doc(id).update({
        'name': productData['name'],
        'category': productData['category'],
        'price': productData['price'],
        'cost': productData['cost'],
        'taxRate': productData['taxRate'],
        'sku': productData['sku'],
        'barcode': productData['barcode'],
        'stock': productData['stock'],
        'image_path': productData['imageUrl'], 
        'description': productData['description'],
      });
      return true;
    } catch (e) {
      print("❌ Update Error: $e");
      return false;
    }
  }

  // ─── CATEGORY API METHODS ──────────────────────────────────────────

  static Future<List<Category>> getCategories() async {
    try {
      // 🌟 THE FIX: Only fetch categories that belong to YOU
      final snapshot = await _db.collection('categories')
          .where('user_id', isEqualTo: _currentUserEmail)
          .get();
          
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Category(
          id: doc.id, // Safely use the Firebase Document ID as a String
          name: data['name'] ?? '',
          description: data['description'] ?? '',
          icon: data['icon'] ?? '',
        );
      }).toList();
    } catch (e) {
      print("❌ Firebase Category Fetch Error: $e");
      return [];
    }
  }

  static Future<bool> addCategory(Map<String, dynamic> data) async {
    try {
      int uniqueId = DateTime.now().millisecondsSinceEpoch;
      
      // 🌟 THE FIX: Stamp your email so Firebase accepts it and Android downloads it!
      data['id'] = uniqueId.toString(); 
      data['user_id'] = _currentUserEmail; 
      
      await _db.collection('categories').doc(uniqueId.toString()).set(data);
      return true;
    } catch (e) {
      print("❌ Firebase Category Add Error: $e");
      return false;
    }
  }

  static Future<bool> updateCategory(String id, Map<String, dynamic> data) async {
    try {
      await _db.collection('categories').doc(id).update(data);
      return true;
    } catch (e) {
      print("❌ Firebase Category Update Error: $e");
      return false;
    }
  }

  static Future<bool> deleteCategory(String id) async {
    try {
      await _db.collection('categories').doc(id).delete();
      return true;
    } catch (e) {
      print("❌ Firebase Category Delete Error: $e");
      return false;
    }
  }
}