
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Pastikan nama file sesuai. Jika filenya bernama beranda.dart, maka:
import 'beranda.dart'; 

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Konfigurasi sistem (diambil dari logika beranda kamu)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Figma to Code',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Geologica', // Pastikan font ini sudah terdaftar di pubspec.yaml
        useMaterial3: true,
      ),
      // Di sini kita memanggil class dari file beranda.dart
      home: const PuBeranda(), 
    );
  }
}