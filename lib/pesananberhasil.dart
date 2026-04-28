import 'package:flutter/material.dart';

class FigmaToCodeApp extends StatelessWidget {
  const FigmaToCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      body: SafeArea(
        child: Column(
          children: [

            const Spacer(),

            // ICON SUCCESS
            Image.network(
              "assets/Escoklat.png",
              width: 143,
            ),

            const SizedBox(height: 20),

            // TITLE
            const Text(
              'Pesanan Berhasil',
              style: TextStyle(
                color: Color(0xFF8A4607),
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // SUBTITLE
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
                children: const [
                  Icon(Icons.home),
                  Icon(Icons.shopping_cart),
                  Icon(Icons.receipt),
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