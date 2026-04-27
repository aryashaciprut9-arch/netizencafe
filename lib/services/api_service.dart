import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class LoginResponse {
  final bool success;
  final String message;
  final UserModel? user;

  LoginResponse({required this.success, required this.message, this.user});
}

class ApiService {
  static const String _baseUrl = 'http://127.0.0.1/api/login.php';

  static Future<LoginResponse> login({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        final userData = data['user'];
        
        return LoginResponse(
          success: true,
          message: data['message'],
          user: UserModel(
            id: userData['id'],
            namaLengkap: userData['namaLengkap'],
            email: userData['email'],
            role: userData['role'],
          ),
        );
      } else {
        return LoginResponse(
          success: false,
          message: data['message'] ?? 'Login gagal',
        );
      }
    } catch (e) {
      return LoginResponse(
        success: false,
        message: 'Gagal terhubung ke server: ${e.toString()}',
      );
    }
  }
}