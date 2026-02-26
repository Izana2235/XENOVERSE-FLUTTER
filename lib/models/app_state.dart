// ─── Theme Preference Enum ─────────────────────────────────────────────────────
enum ThemePreference { light, dark, system }

// ─── Product Model ─────────────────────────────────────────────────────────────
class Product {
  final String id;
  String name;
  String category;
  double price;
  int stock;
  String imageUrl;
  String description;
  static const int lowStockThreshold = 20;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
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
    this.icon = '📦',
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
      name: 'Wireless Headphones',
      category: 'Electronics',
      price: 2999.00,
      stock: 15,
      imageUrl: 'https://via.placeholder.com/40',
    ),
    Product(
      id: 'P002',
      name: 'Mechanical Keyboard',
      category: 'Electronics',
      price: 4500.00,
      stock: 8,
      imageUrl: 'https://via.placeholder.com/40',
    ),
    Product(
      id: 'P003',
      name: 'USB-C Hub',
      category: 'Electronics',
      price: 1200.00,
      stock: 42,
      imageUrl: 'https://via.placeholder.com/40',
    ),
    Product(
      id: 'P004',
      name: 'Office Chair',
      category: 'Furniture',
      price: 8500.00,
      stock: 5,
      imageUrl: 'https://via.placeholder.com/40',
    ),
    Product(
      id: 'P005',
      name: 'Standing Desk',
      category: 'Furniture',
      price: 12000.00,
      stock: 3,
      imageUrl: 'https://via.placeholder.com/40',
    ),
    Product(
      id: 'P006',
      name: 'Webcam HD',
      category: 'Electronics',
      price: 1800.00,
      stock: 22,
      imageUrl: 'https://via.placeholder.com/40',
    ),
    Product(
      id: 'P007',
      name: 'Laptop Stand',
      category: 'Accessories',
      price: 950.00,
      stock: 18,
      imageUrl: 'https://via.placeholder.com/40',
    ),
    Product(
      id: 'P008',
      name: 'Mouse Pad XL',
      category: 'Accessories',
      price: 450.00,
      stock: 60,
      imageUrl: 'https://via.placeholder.com/40',
    ),
    Product(
      id: 'P009',
      name: 'Cable Organizer',
      category: 'Accessories',
      price: 250.00,
      stock: 10,
      imageUrl: 'https://via.placeholder.com/40',
    ),
  ];

  // ── Sample categories ─────────────────────────────────────────────────────
  List<Category> categories = [
    Category(id: 'C001', name: 'Electronics', description: 'Gadgets and devices'),
    Category(id: 'C002', name: 'Furniture', description: 'Office and home furniture'),
    Category(id: 'C003', name: 'Accessories', description: 'Desk and peripheral accessories'),
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
