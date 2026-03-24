// ─── Theme Preference Enum ─────────────────────────────────────────────────────
enum ThemePreference { light, dark, system }

// ─── Product Model ─────────────────────────────────────────────────────────────
// ─── Product Model (Fixed for UI) ──────────────────────────────────────────
class Product {
  final String id;
  String name;
  String category;
  double price;
  int stock;
  String imageUrl;    // 🌟 Removed the '?'
  String description; // 🌟 Removed the '?'
  static const int lowStockThreshold = 20;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    this.imageUrl = '',    // 🌟 Put default back
    this.description = '', // 🌟 Put default back
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

  // Theme: light / dark / system (replaces the old isDarkTheme bool)
  ThemePreference themePreference = ThemePreference.light;

  // Convenience getter kept for any widgets that still reference isDarkTheme
  bool get isDarkTheme => themePreference == ThemePreference.dark;

  // Convenience setter — maps old bool usage to new enum
  set isDarkTheme(bool value) {
    themePreference = value ? ThemePreference.dark : ThemePreference.light;
  }

  bool isSidebarCollapsed = false;

  // ── Store settings ────────────────────────────────────────────────────────
  String storeName = 'STORE';
  String adminName = 'Admin';
  String country = 'Philippines';
  String currency = 'PHP (₱)';
  String language = 'English';
  int lowStockThresholdSetting = 20;

  // ── Sample products ───────────────────────────────────────────────────────
  List<Product> products = [
    Product(
      id: 'P001',
      name: 'Coffee',
      category: 'Beverages',
      price: 50.00,
      stock: 100,
      imageUrl: 'https://via.placeholder.com/40',
    ),
    Product(
      id: 'P002',
      name: 'Tea',
      category: 'Beverages',
      price: 40.00,
      stock: 80,
      imageUrl: 'https://via.placeholder.com/40',
    ),
    Product(
      id: 'P003',
      name: 'Orange Juice',
      category: 'Beverages',
      price: 60.00,
      stock: 50,
      imageUrl: 'https://via.placeholder.com/40',
    ),
    Product(
      id: 'P004',
      name: 'Burger',
      category: 'Main Dish',
      price: 150.00,
      stock: 20,
      imageUrl: 'https://via.placeholder.com/40',
    ),
    Product(
      id: 'P005',
      name: 'Pizza',
      category: 'Main Dish',
      price: 200.00,
      stock: 15,
      imageUrl: 'https://via.placeholder.com/40',
    ),
    Product(
      id: 'P006',
      name: 'Pasta',
      category: 'Main Dish',
      price: 120.00,
      stock: 25,
      imageUrl: 'https://via.placeholder.com/40',
    ),
    Product(
      id: 'P007',
      name: 'Soda',
      category: 'Drinks',
      price: 30.00,
      stock: 200,
      imageUrl: 'https://via.placeholder.com/40',
    ),
    Product(
      id: 'P008',
      name: 'Mineral Water',
      category: 'Drinks',
      price: 20.00,
      stock: 150,
      imageUrl: 'https://via.placeholder.com/40',
    ),
    Product(
      id: 'P009',
      name: 'Milk',
      category: 'Drinks',
      price: 45.00,
      stock: 30,
      imageUrl: 'https://via.placeholder.com/40',
    ),
    Product(
      id: 'P010',
      name: 'French Fries',
      category: 'Appetizer',
      price: 80.00,
      stock: 40,
      imageUrl: 'https://via.placeholder.com/40',
    ),
    Product(
      id: 'P011',
      name: 'Caesar Salad',
      category: 'Appetizer',
      price: 90.00,
      stock: 35,
      imageUrl: 'https://via.placeholder.com/40',
    ),
    Product(
      id: 'P012',
      name: 'Chicken Wings',
      category: 'Appetizer',
      price: 100.00,
      stock: 30,
      imageUrl: 'https://via.placeholder.com/40',
    ),
    Product(
      id: 'P013',
      name: 'Chocolate Cake',
      category: 'Dessert',
      price: 70.00,
      stock: 10,
      imageUrl: 'https://via.placeholder.com/40',
    ),
    Product(
      id: 'P014',
      name: 'Ice Cream',
      category: 'Dessert',
      price: 50.00,
      stock: 60,
      imageUrl: 'https://via.placeholder.com/40',
    ),
    Product(
      id: 'P015',
      name: 'Apple Pie',
      category: 'Dessert',
      price: 65.00,
      stock: 15,
      imageUrl: 'https://via.placeholder.com/40',
    ),
  ];

  // ── Sample categories ─────────────────────────────────────────────────────
  List<Category> categories = [
    Category(id: 'C001', name: 'Beverages', description: 'Drinks and beverages', icon: '☕'),
    Category(id: 'C002', name: 'Main Dish', description: 'Main course meals', icon: '🍽️'),
    Category(id: 'C003', name: 'Drinks', description: 'Beverages and drinks', icon: '🥤'),
    Category(id: 'C004', name: 'Appetizer', description: 'Starters and appetizers', icon: '🥗'),
    Category(id: 'C005', name: 'Dessert', description: 'Sweet dishes and desserts', icon: '🍰'),
  ];

  // ── Derived getters ───────────────────────────────────────────────────────
  List<Product> get lowStockProducts =>
      products.where((p) => p.stock <= lowStockThresholdSetting).toList();

  List<String> get categoryNames => categories.map((c) => c.name).toList();

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

  // ── Stock history tracking ─────────────────────────────────────────────────
  final List<Map<String, dynamic>> _stockHistory = [];

  List<Map<String, dynamic>> get stockHistory => _stockHistory;

  void recordStockChange(String productId, int quantity, String action) {
    _stockHistory.add({
      'productId': productId,
      'quantity': quantity,
      'action': action,
      'timestamp': DateTime.now(),
    });
  }
}
