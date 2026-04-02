import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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
      title: 'Pesanan Berhasil',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Geologica',
        useMaterial3: true,
      ),
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
      body: SafeArea(
        child: Column(
          children: [
            // STATUS BAR SIMULASI
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "20.11",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(Icons.signal_cellular_alt, size: 18),
                ],
              ),
            ),

            const Spacer(),

            // ICON / GAMBAR SUCCESS
            Image.network(
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
                fontWeight: FontWeight.w700,
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
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  Icon(Icons.home),
                  Icon(Icons.shopping_cart),
                  Icon(Icons.receipt_long),
                  Icon(Icons.person),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}