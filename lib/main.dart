import 'package:flutter/material.dart';
import 'login.dart';
import 'beranda.dart';
import 'detailkeranjang.dart';
import 'kategoriminuman.dart';
import 'katergorimakanan.dart';
import 'pesananberhasil.dart';
import 'profil_pelanggan.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),

      home: const Scaffold(
        body: LoginPage(),
      ),
      routes: {
        '/beranda':          (context) => const PuBeranda(),
        '/detailkeranjang':  (context) => const PuDetailKeranjang(),
        '/kategoriminuman':  (context) => const PaMenuJenisMinuman(),
        '/katergorimakanan': (context) => const MenuPage(),
        '/pesananberhasil':  (context) => const PuPesananBerhasil(),
        '/profil':           (context) => const ProfilPelanggan(),
      },
    );
  }
}