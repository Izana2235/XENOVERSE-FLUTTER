import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ─── Theme Preference Enum ─────────────────────────────────────────────────────
enum ThemePreference { light, dark, system }

// ─── Product Model ─────────────────────────────────────────────────────────────
class Product {
  final String id;
  String name;
  String category;
  double price;
  
  double cost;
  double taxRate;
  String sku;
  String barcode;
  
  int stock;
  String imageUrl;    
  String description; 
  static const int lowStockThreshold = 20;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    
    this.cost = 0.0,
    this.taxRate = 0.0,
    this.sku = '',
    this.barcode = '',
    
    required this.stock,
    this.imageUrl = '',    
    this.description = '', 
  });

  bool get isLowStock => stock <= lowStockThreshold;
}

// ─── Category Model ────────────────────────────────────────────────────────────
class Category {
  final String id;
  String name;
  String description;
  String icon;

  Category({
    required this.id,
    required this.name,
    this.description = '',
    this.icon = '',
  });
}

// ─── App State ─────────────────────────────────────────────────────────────────
class AppState {
  String currentRoute = 'dashboard';
  ThemePreference themePreference = ThemePreference.light;

  bool get isDarkTheme => themePreference == ThemePreference.dark;

  set isDarkTheme(bool value) {
    themePreference = value ? ThemePreference.dark : ThemePreference.light;
  }

  bool isSidebarCollapsed = false;

  // ── Store settings ────────────────────────────────────────────────────────
  String storeName = 'STORE';
  String adminName = 'Admin';
  String country = 'Philippines';
  String currency = 'PHP (₱) — Philippine Peso';
  String language = 'English';
  int lowStockThresholdSetting = 20;

  String get currencySymbol {
    final match = RegExp(r'\((.+?)\)').firstMatch(currency);
    return match != null ? match.group(1)! : '₱';
  }

  List<Product> products = [];
  List<Category> categories = [];

  List<Product> get lowStockProducts =>
      products.where((p) => p.stock <= lowStockThresholdSetting).toList();

  // 🌟 THE FIX: Dynamically scan products and instantly build the Category Chips!
  List<String> get categoryNames {
    final Set<String> names = {};
    
    // 1. Grab categories directly from the products you are selling
    for (var p in products) {
      if (p.category.trim().isNotEmpty && p.category != 'Uncategorized') {
        names.add(p.category.trim());
      }
    }
    
    // 2. Also grab any official categories you manually built in the Categories tab
    for (var c in categories) {
      if (c.name.trim().isNotEmpty) {
        names.add(c.name.trim());
      }
    }
    
    final sortedList = names.toList();
    sortedList.sort(); // Alphabetizes the chips perfectly
    return sortedList;
  }

  // ── Methods for product management ─────────────────────────────────────────
  void addProduct(Product product) {
    products.add(product);
  }

  void updateProduct(String id, Product updatedProduct) {
    final index = products.indexWhere((p) => p.id == id);
    if (index != -1) {
      products[index] = updatedProduct;
    }
  }

  void deleteProduct(String id) {
    products.removeWhere((p) => p.id == id);
  }

  // ── Methods for category management ────────────────────────────────────────
  void addCategory(Category category) {
    categories.add(category);
  }

  void updateCategory(String id, Category updatedCategory) {
    final index = categories.indexWhere((c) => c.id == id);
    if (index != -1) {
      categories[index] = updatedCategory;
    }
  }

  void deleteCategory(String id) {
    categories.removeWhere((c) => c.id == id);
  }

  int productCountByCategory(String categoryName) {
    return products.where((p) => p.category == categoryName).length;
  }

  // ── FIREBASE STOCK HISTORY TRACKING ────────────────────────────────
  final List<Map<String, dynamic>> _stockHistory = [];

  List<Map<String, dynamic>> get stockHistory => _stockHistory;

  AppState() {
    fetchStockHistoryFromFirebase();
  }

  Future<void> fetchStockHistoryFromFirebase() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('stock_history')
          .where('user_id', isEqualTo: currentUser.email)
          .get();

      _stockHistory.clear();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        _stockHistory.add({
          'productName': data['productName'] ?? 'Unknown',
          'action': data['action'] ?? 'Updated',
          'quantity': data['quantity'] ?? 0,
          'timestamp': data['timestamp'] != null 
              ? (data['timestamp'] as Timestamp).toDate() 
              : DateTime.now(),
        });
      }

      _stockHistory.sort((a, b) => (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));

    } catch (e) {
      print("🚨 Error fetching stock history: $e");
    }
  }

  void recordStockChange(String productId, int quantity, String action) {
    _stockHistory.insert(0, {
      'productId': productId,
      'quantity': quantity,
      'action': action,
      'timestamp': DateTime.now(),
    });
  }
}