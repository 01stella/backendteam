import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // Replace this with your actual backend URL later (e.g., your GCP link or local IP)
  static const String baseUrl = 'http://localhost:3000/api';
  
  // 1. Fetch Menu Items
  static Future<List<dynamic>> fetchMenu() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/menu'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']; // Returns the array of menu items
      } else {
        throw Exception('Failed to load menu');
      }
    } catch (e) {
      print('Error fetching menu: $e');
      return [];
    }
  }

  // 2. Create the Order (Sending the Cart Array)
  static Future<Map<String, dynamic>?> createOrder({
    required int customerId,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'customer_id': customerId,
          'items': items, // e.g., [{"menu_id": 101, "quantity": 2}, ...]
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body); 
      } else {
        print('Failed to create order: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error creating order: $e');
      return null;
    }
  }

  // 3. Calculate Order
  static Future<Map<String, dynamic>?> calculateOrder(List<Map<String, dynamic>> items) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders/calculate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'items': items}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data']; // Returns {subtotal, pb1, vat, total}
      } else {
        print('Failed to calculate: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error calculating order: $e');
      return null;
    }
  }

  // 4. Upload Payment Receipt (Multipart Form Data)
  static Future<bool> uploadReceipt(String orderId, File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/orders/$orderId/receipt'),
      );

      // Attach the image file
      request.files.add(
        await http.MultipartFile.fromPath(
          'receipt_image',
          imageFile.path,
        ),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Receipt uploaded successfully!');
        return true;
      } else {
        print('Failed to upload receipt: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error uploading receipt: $e');
      return false;
    }
  }

  // ==========================================
  //         AUTHENTICATION METHODS
  // ==========================================

  // 5. REGISTER API CALL
  static Future<Map<String, dynamic>> registerCustomer({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String birthday,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/customers/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'full_name': fullName,
          'email': email,
          'password': password,
          'phone_number': phone,
          'birthday': birthday,
        }),
      );

      // We use jsonDecode here because your Node backend sends a JSON response 
      // (like { success: true, message: '...' })
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // 6. LOGIN API CALL
  static Future<Map<String, dynamic>> loginCustomer({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/customers/login'), 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}