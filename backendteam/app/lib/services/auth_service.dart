import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _keyId = 'customer_id';
  static const String _keyName = 'customer_name';

  // 1. Save user data to the phone's storage
  static Future<void> saveUser(int id, String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyId, id);
    await prefs.setString(_keyName, name);
  }

  // 2. Retrieve user data (Used by Profile and Checkout)
  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt(_keyId);
    final name = prefs.getString(_keyName);

    if (id != null && name != null) {
      return {'id': id, 'full_name': name};
    }
    return null; // Null means they are logged out
  }

  // 3. Clear the storage (Logout)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyId);
    await prefs.remove(_keyName);
  }
}