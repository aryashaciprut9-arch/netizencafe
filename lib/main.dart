import 'package:flutter/material.dart';
import 'kelolamenuadmin.dart'; 
import 'kasiradmin.dart'; 
import 'snack.dart'; 

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
        fontFamily: 'Geologica', 
        useMaterial3: true,
      ),
      home: const BerandaUtama(),
    );
  }
}

class BerandaUtama extends StatefulWidget {
  const BerandaUtama({super.key});

  @override
  State<BerandaUtama> createState() => _BerandaUtamaState();
}

class _BerandaUtamaState extends State<BerandaUtama> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // List halaman ditaruh di dalam build supaya Key-nya bisa berubah-ubah
    final List<Widget> _halaman = [
      const KasirPage(),       
      const KelolaManuAdmin(),  
      // Trik UniqueKey: Memaksa halaman Snack refresh data setiap kali dibuka
      MenuPage(key: _currentIndex == 2 ? UniqueKey() : null), 
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _halaman,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed, 
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFF8A4607),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.point_of_sale), label: 'Kasir'),
          BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings), label: 'Admin'),
          BottomNavigationBarItem(icon: Icon(Icons.fastfood), label: 'User Snack'),
        ],
      ),
    );
  }
}