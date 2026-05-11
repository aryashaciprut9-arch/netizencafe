import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyEmail = 'user_email';
  static const String _keyUsername = 'user_username';
  static const String _keyPhone = 'user_phone';
  static const String _keyAddress = 'user_address';
  static const String _keyRole = 'user_role';
  static const String _keyId = 'user_id';

  // ==================== SAVE DATA ====================

  static Future<void> saveUserData({
    required String email,
    required String username,
    String phone = '',
    String address = '',
    String role = 'user',
    String id = '',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyUsername, username);
    await prefs.setString(_keyPhone, phone);
    await prefs.setString(_keyAddress, address);
    await prefs.setString(_keyRole, role);
    await prefs.setString(_keyId, id);
  }

  // Ambil path gambar profil
  static Future<String> getProfileImage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('profile_image') ?? '';
  }

  // Simpan path gambar profil baru
  static Future<void> updateProfileImage(String path) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image', path);
  }

  static Future<void> updateUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUsername, username);
  }

  static Future<void> updatePhone(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPhone, phone);
  }

  static Future<void> updateAddress(String address) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAddress, address);
  }

  // ==================== GET DATA ====================

  static Future<String> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail) ?? '';
  }

  static Future<String> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername) ?? '';
  }

  static Future<String> getPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPhone) ?? '';
  }

  static Future<String> getAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAddress) ?? '';
  }

  static Future<String> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRole) ?? 'user';
  }

  static Future<String> getId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyId) ?? '';
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // ==================== CLEAR DATA ====================

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}