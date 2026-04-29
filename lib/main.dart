import 'package:flutter/material.dart';
import 'kelolamenuadmin.dart';
import 'kasiradmin.dart';
import 'snack.dart';
import 'katergorimakanan.dart' as makanan;
import 'kategoriminuman.dart';

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
    final List<Widget> _halaman = [
      const KasirPage(),
      const KelolaManuAdmin(),
      MenuPage(key: _currentIndex == 2 ? UniqueKey() : null),
      makanan.MenuPage(key: _currentIndex == 3 ? UniqueKey() : null),
      PaMenuJenisMinuman(key: _currentIndex == 4 ? UniqueKey() : null),
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
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.point_of_sale),
            label: 'Kasir',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings),
            label: 'Admin',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fastfood),
            label: 'Snack',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rice_bowl),
            label: 'Makanan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_drink),
            label: 'Minuman',
          ),
        ],
      ),
    );
  }
}