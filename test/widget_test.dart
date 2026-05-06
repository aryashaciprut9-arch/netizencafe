import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netizencafe/main.dart'; // Import main.dart Anda

void main() {
  testWidgets('Halaman Login berhasil ditampilkan', (WidgetTester tester) async {
    // 1. Bangun widget FigmaToCodeApp (bukan MyApp)
    await tester.pumpWidget(const FigmaToCodeApp());

    // 2. Beri waktu agar widget selesai dirender
    await tester.pumpAndSettle();

    // 3. Pastikan elemen-elemen yang ada di halaman Login muncul dengan benar
    
    // Cek judul aplikasi
    expect(find.text('Nettyzen Access'), findsOneWidget);
    
    // Cek subtitle
    expect(find.text('Cafe & UMKM Solution'), findsOneWidget);

    // Cek toggle User & Admin
    expect(find.text('User'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);

    // Cek label field
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);

    // Cek tombol Login
    expect(find.text('LOGIN'), findsOneWidget);

    // Cek teks "Ingat Saya" dan "Lupa Password?"
    expect(find.text('Ingat Saya'), findsOneWidget);
    expect(find.text('Lupa Password?'), findsOneWidget);
  });
}