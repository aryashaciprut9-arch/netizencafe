import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netizencafe/main.dart';

void main() {
  testWidgets('Halaman Detail Pesanan tampil dengan benar',
      (WidgetTester tester) async {
    // Bangun widget FigmaToCodeApp
    await tester.pumpWidget(const FigmaToCodeApp());
    await tester.pumpAndSettle();

    // Pastikan app berhasil dirender
    expect(find.byType(FigmaToCodeApp), findsOneWidget);

    // Pastikan halaman Detail Pesanan muncul
    expect(find.text('Detail Pesanan'), findsOneWidget);

    // Pastikan item makanan tampil
    expect(find.text('Chicken Teriyaki'), findsOneWidget);
    expect(find.text('Bakso Special'), findsOneWidget);

    // Pastikan tombol Pesan Sekarang tersedia
    expect(find.text('Pesan Sekarang'), findsOneWidget);

    // Pastikan tombol '+' tersedia
    expect(find.byIcon(Icons.add_rounded), findsWidgets);

    // Tekan salah satu tombol '+' dan tunggu animasi selesai
    await tester.tap(find.byIcon(Icons.add_rounded).first);
    await tester.pumpAndSettle();

    // Pastikan halaman masih tampil setelah tap
    expect(find.text('Detail Pesanan'), findsOneWidget);
  });
}