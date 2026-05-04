import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../models/menu_models.dart';

class ApiService {
 static const String baseUrl = 'http://127.0.0.1/kasir_api';

  static Future<List<MenuModel>> getMenu() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/menu/get_menu.php'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          final List list = data['data'] ?? [];
          return list.map((item) => MenuModel.fromJson(item)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error getMenu: $e');
      return [];
    }
  }

  // --- DIFIX: File? foto → fotoBytes + fotoFileName ---
  static Future<bool> tambahMenu({
    required String nama,
    required String kategori,
    required int harga,
    required String deskripsi,
    required String tampil,
    Uint8List? fotoBytes,    // DIFIX
    String? fotoFileName,    // DIFIX
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse("$baseUrl/menu/tambah_menu.php"));

      request.fields['nama'] = nama;
      request.fields['kategori'] = kategori;
      request.fields['harga'] = harga.toString();
      request.fields['deskripsi'] = deskripsi;
      request.fields['tampil'] = tampil;

      // DIFIX: langsung pakai bytes, works di Web & Mobile
      if (fotoBytes != null && fotoFileName != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'foto',
          fotoBytes,
          filename: fotoFileName,
        ));
      }

      var response = await request.send();
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Error Tambah: $e");
      return false;
    }
  }

  // --- DIFIX: File? foto → fotoBytes + fotoFileName ---
  static Future<bool> editMenu({
    required String id,
    required String nama,
    required String kategori,
    required int harga,
    required String deskripsi,
    required String tampil,
    required String fotoLama,
    Uint8List? fotoBytes,    // DIFIX
    String? fotoFileName,    // DIFIX
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/menu/edit_menu.php'));

      request.fields['id'] = id;
      request.fields['nama'] = nama;
      request.fields['kategori'] = kategori;
      request.fields['harga'] = harga.toString();
      request.fields['deskripsi'] = deskripsi;
      request.fields['tampil'] = tampil;
      request.fields['foto_lama'] = fotoLama;

      // DIFIX: langsung pakai bytes, works di Web & Mobile
      if (fotoBytes != null && fotoFileName != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'foto',
          fotoBytes,
          filename: fotoFileName,
        ));
      }

      var response = await request.send();
      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final data = jsonDecode(respStr);
        return data['status'] == 'success';
      }
      return false;
    } catch (e) {
      debugPrint('Error editMenu: $e');
      return false;
    }
  }

  static Future<bool> hapusMenu(String id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/menu/hapus_menu.php'),
        body: {'id': id},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'success';
      }
      return false;
    } catch (e) {
      debugPrint('Error hapusMenu: $e');
      return false;
    }
  }
}