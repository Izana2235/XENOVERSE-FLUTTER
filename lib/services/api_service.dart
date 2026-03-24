import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/app_state.dart'; // Pointing to their Product model

class WebApiService {
  // 🌟 FIXED: Kept the correct IP address right here at the class level
  static const String baseUrl = 'http://192.168.1.16:3000';

  static Future<List<Product>> getProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products')).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        
        return data.map((json) => Product(
          id: json['id'].toString(),
          name: json['name'] ?? 'Unnamed',
          category: json['category'] ?? 'General',
          
          // 🌟 THE FIX: Bulletproof parsing exactly like your Android app!
          price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
          stock: int.tryParse(json['stock']?.toString() ?? '0') ?? 0,
          
          // 🌟 THE MAGIC SHIELD: Added ?? '' to stop the null errors!
          imageUrl: json['image_url'] ?? '', 
          description: json['description'] ?? '', 
        )).toList();
      } else {
        throw Exception("Failed to load products: ${response.statusCode}");
      }
    } catch (e) {
      print("Web Fetch Error: $e");
      return [];
    }
  }

  // --- DELETE A PRODUCT ---
  static Future<bool> deleteProduct(String id) async {
    try {
      // Tells your Node.js server to delete this specific ID
      final response = await http.delete(Uri.parse('$baseUrl/products/$id'));
      
      if (response.statusCode == 200) {
        print("🗑️ Successfully deleted from database!");
        return true;
      } else {
        print("❌ Failed to delete: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ Web Delete Error: $e");
      return false;
    }
  }

  // --- FETCH ORDERS (For Revenue) ---
  static Future<List<dynamic>> getOrders() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/orders')).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print("❌ Order Fetch Error: $e");
      return [];
    }
  }
  // --- ADD A PRODUCT FROM WEB ---
  static Future<bool> addProduct(Map<String, dynamic> productData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/products'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(productData),
      );
      // 200 or 201 means successful creation!
      return response.statusCode == 200 || response.statusCode == 201; 
    } catch (e) {
      print("❌ Add Error: $e");
      return false;
    }
  }

  // --- UPDATE A PRODUCT FROM WEB ---
  static Future<bool> updateProduct(String id, Map<String, dynamic> productData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/products/$id'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(productData),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("❌ Update Error: $e");
      return false;
    }
  }
}