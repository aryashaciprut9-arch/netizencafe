// lib/models/user_model.dart

class UserModel {
  final int id;
  final String namaLengkap;
  final String email;
  final String role;

  UserModel({
    required this.id,
    required this.namaLengkap,
    required this.email,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      namaLengkap: json['nama_lengkap'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_lengkap': namaLengkap,
      'email': email,
      'role': role,
    };
  }
}