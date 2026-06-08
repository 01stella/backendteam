import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  static const String serverIp = String.fromEnvironment(
    'VM_IP',
    defaultValue: 'localhost', // Fallback just in case
  );

  // Stitched together dynamically
  static const String baseUrl = 'http://$serverIp:3000/api';

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
    String? paymentMethod,
    required List<Map<String, dynamic>> items,
    required String fulfillmentType,
    String? pickupTime,
    String? deliveryFloor,
    String? deliveryRoom,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "customer_id": customerId,
          "payment_method": paymentMethod ?? "cashier",
          "items": items,
          "fulfillment_type": fulfillmentType,
          "pickup_time": pickupTime,
          "delivery_floor": deliveryFloor,
          "delivery_room": deliveryRoom,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        debugPrint("Failed to create order: ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint("Error creating order: $e");
      return null;
    }
  }

  // Call this when the user submits their payment proof!
  static Future<bool> markPaymentPending(int orderId) async {
    try {
      // CHANGED THE URL HERE:
      final response = await http.put(
        Uri.parse('$baseUrl/orders/$orderId/verify-payment'),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint("Failed to update payment status: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("Error updating payment status: $e");
      return false;
    }
  }

  // 3. Calculate Order
  static Future<Map<String, dynamic>?> calculateOrder(
    List<Map<String, dynamic>> items,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders/calculate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'items': items}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(
          response.body,
        )['data']; // Returns {subtotal, pb1, vat, total}
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
        await http.MultipartFile.fromPath('receipt_image', imageFile.path),
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
        body: jsonEncode({'email': email, 'password': password}),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // 7. FETCH ORDER HISTORY
  static Future<List<dynamic>?> fetchOrderHistory(int customerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/customer/$customerId'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['data']; // Returns the list of orders
      } else {
        debugPrint("Failed to fetch history: ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint("Error fetching history: $e");
      return null;
    }
  }

  static Future<int> fetchCustomerStamps(int customerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/customers/$customerId/stamps'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return int.tryParse(data['total_stamps']?.toString() ?? '') ?? 0;
      } else {
        return 0;
      }
    } catch (e) {
      debugPrint("Error fetching stamps: $e");
      return 0;
    }
  }
}
