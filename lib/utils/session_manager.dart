// lib/utils/session_manager.dart

import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class SessionManager {
  static const String _keyIsLoggedIn = "is_logged_in";
  static const String _keyUserId = "user_id";
  static const String _keyUserName = "user_name";
  static const String _keyUserEmail = "user_email";
  static const String _keyUserRole = "user_role";

  /// Simpan data session (FLEKSIBEL: menerima Map dari API atau UserModel)
  static Future<void> saveSession(dynamic user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);

    if (user is Map<String, dynamic>) {
      // Jika data dari API masih berupa Map
      await prefs.setString(_keyUserId, user['id']?.toString() ?? '0');
      // Menyesuaikan apakah key JSON-nya 'namaLengkap' atau 'nama_lengkap'
      await prefs.setString(_keyUserName, user['namaLengkap'] ?? user['nama_lengkap'] ?? '');
      await prefs.setString(_keyUserEmail, user['email'] ?? '');
      await prefs.setString(_keyUserRole, user['role'] ?? 'user');
    } else {
      // Fallback jika suatu saat data sudah berupa object UserModel
      await prefs.setString(_keyUserId, user.id.toString());
      await prefs.setString(_keyUserName, user.namaLengkap);
      await prefs.setString(_keyUserEmail, user.email);
      await prefs.setString(_keyUserRole, user.role);
    }
  }

  /// Cek apakah user sudah login
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  /// Ambil data user yang sedang login
  static Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;

    if (!isLoggedIn) return null;

    // Ambil string dulu, lalu parse ke int (aman dari error tipe data)
    final userIdStr = prefs.getString(_keyUserId) ?? '0';
    final userId = int.tryParse(userIdStr) ?? 0;

    return UserModel(
      id: userId, // Jika id di UserModel Anda String, ganti jadi: id: userIdStr,
      namaLengkap: prefs.getString(_keyUserName) ?? '',
      email: prefs.getString(_keyUserEmail) ?? '',
      role: prefs.getString(_keyUserRole) ?? 'user',
    );
  }

  /// Hapus session (logout)
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}