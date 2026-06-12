import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _keyId = 'customer_id';
  static const String _keyName = 'customer_name';
  static const String _keyEmail = 'customer_email';

  // 1. Save user data to the phone's storage
  static Future<void> saveUser(int id, String name, {String? email}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyId, id);
    await prefs.setString(_keyName, name);
    if (email != null && email.isNotEmpty) {
      await prefs.setString(_keyEmail, email);
    }
  }

  // 2. Retrieve user data (Used by Profile and Checkout)
  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt(_keyId);
    final name = prefs.getString(_keyName);
    final email = prefs.getString(_keyEmail);

    if (id != null && name != null) {
      return {'id': id, 'full_name': name, 'email': email};
    }
    return null; // Null means they are logged out
  }

  // 3. Clear the storage (Logout)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyId);
    await prefs.remove(_keyName);
    await prefs.remove(_keyEmail);
  }
}
