import 'package:flutter/material.dart';
import 'beranda.dart';
import 'profil_pelanggan.dart';

class FigmaToCodeApp extends StatelessWidget {
  const FigmaToCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PuPesananBerhasil(),
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
            const Spacer(),

            Image.asset(
              "assets/Escoklat.png",
              width: 143,
            ),

            const SizedBox(height: 20),

            const Text(
              'Pesanan Berhasil',
              style: TextStyle(
                color: Color(0xFF8A4607),
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

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

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: const EdgeInsets.symmetric(vertical: 10),
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
                children: [
                  IconButton(
                    icon: const Icon(Icons.home),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PuBeranda(),
                        ),
                      );
                    },
                  ),

                  // Cart → kembali ke beranda saja
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PuBeranda(),
                        ),
                      );
                    },
                  ),

                  IconButton(
                    icon: const Icon(Icons.receipt),
                    onPressed: () {
                      // Tambahkan navigasi riwayat pesanan di sini jika sudah ada
                    },
                  ),

                  IconButton(
                    icon: const Icon(Icons.person),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilePage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}