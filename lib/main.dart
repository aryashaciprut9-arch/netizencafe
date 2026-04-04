import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Hilangkan status bar (fullscreen)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Lock portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const PuPesananBerhasil(),
    );
  }
}

class PuPesananBerhasil extends StatelessWidget {
  const PuPesananBerhasil({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const Spacer(),

          // ICON CHECK (DARI ASSETS)
          Image.asset(
            "assets/CHECK CIRCLE.png",
            width: 250,
            height: 250,
          ),

          const SizedBox(height: 20),

          // JUDUL
          const Text(
            'Pesanan Berhasil',
            style: TextStyle(
              color: Color(0xFF8A4607),
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          // DESKRIPSI
          const Text(
            'Terimakasih pesanan\nsegera di proses',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF8A4607),
              fontSize: 18,
              fontStyle: FontStyle.italic,
            ),
          ),

          const Spacer(),

          // BOTTOM NAVBAR
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5CC9E),
              borderRadius: BorderRadius.circular(30),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 4,
                  offset: Offset(0, 4),
                  color: Colors.black26,
                )
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(Icons.home),
                Icon(Icons.shopping_cart),
                Icon(Icons.receipt_long),
                Icon(Icons.person),
              ],
            ),
          ),
        ],
      ),
    );
  }
}