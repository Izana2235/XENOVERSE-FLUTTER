class Product {
  final int id;
  String name;
  String category;
  double price;
  int stock;
  String imageUrl;
  String description;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    required this.imageUrl,
    this.description = '',
  });

  bool get isLowStock => stock <= 20;
}

class Category {
  final int id;
  String name;
  String description;
  String icon;

  Category({required this.id, required this.name, this.description = '', this.icon = '📦'});
}

class StockRecord {
  final String productName;
  final String action; // 'Added', 'Removed', 'Adjusted'
  final int quantity;
  final DateTime date;

  StockRecord({required this.productName, required this.action, required this.quantity, required this.date});
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;

  ChatMessage({required this.text, required this.isUser, required this.time});
}
