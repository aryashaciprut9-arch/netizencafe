import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netizencafe/main.dart'; // sesuaikan dengan nama project Anda

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Bangun widget MyApp
    await tester.pumpWidget(const MyApp());

    // Pastikan counter dimulai dari 0
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tekan tombol '+' (ikon add) dan proses frame
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Pastikan counter bertambah menjadi 1
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}