import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const FigmaToCodeApp());
}

class FigmaToCodeApp extends StatelessWidget {
  const FigmaToCodeApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
      ),
      home: Scaffold(
        body: ListView(children: [
          PuMenuJenisMakanan(),
        ]),
      ),
    );
  }
}

class PuMenuJenisMakanan extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 430,
          height: 961,
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            gradient: LinearGradient(
              begin: Alignment(0.50, -0.00),
              end: Alignment(0.50, 1.00),
              colors: [const Color(0xFF8A4607)],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(35),
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 80,
                top: 36,
                child: Text(
                  'Makanan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'Geologica',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Positioned(
                left: 333,
                top: 41,
                child: Text(
                  'Tambah',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'Geologica',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Positioned(
                left: 313,
                top: 36,
                child: Text(
                  '+',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'Geologica',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Positioned(
                left: 28,
                top: 75,
                child: Container(
                  width: 368,
                  height: 29,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF8A4607),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 1, color: Colors.white),
                      borderRadius: BorderRadius.circular(35),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 44,
                top: 81,
                child: Container(
                  width: 21,
                  height: 18,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://placehold.co/21x18"),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 80,
                top: 81,
                child: SizedBox(
                  width: 186.56,
                  height: 17.61,
                  child: Text(
                    'Cari Menu....',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 234,
                top: 715,
                child: Container(
                  width: 162,
                  height: 183,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    shadows: [
                      BoxShadow(
                        color: Color(0x3F000000),
                        blurRadius: 4,
                        offset: Offset(0, 4),
                        spreadRadius: 0,
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 242,
                top: 836,
                child: Text(
                  'Bakso',
                  style: TextStyle(
                    color: const Color(0xFFD4741B),
                    fontSize: 10,
                    fontFamily: 'Geologica',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Positioned(
                left: 355,
                top: 863,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF8A4607),
                    shape: OvalBorder(),
                  ),
                ),
              ),
              Positioned(
                left: 361,
                top: 863,
                child: Text(
                  '+',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'Geologica',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Positioned(
                left: 242,
                top: 850,
                child: Text(
                  'IDR 13.000',
                  style: TextStyle(
                    color: const Color(0xFF8A4607),
                    fontSize: 10,
                    fontFamily: 'Geologica',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Positioned(
                left: 242,
                top: 874,
                child: Text(
                  'Tersedia',
                  style: TextStyle(
                    color: const Color(0xFF767070),
                    fontSize: 7,
                    fontFamily: 'Instrument Sans',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 238,
                top: 720,
                child: Container(
                  width: 154,
                  height: 103,
                  decoration: ShapeDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://placehold.co/154x103"),
                      fit: BoxFit.fill,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 33,
                top: 715,
                child: Container(
                  width: 162,
                  height: 183,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    shadows: [
                      BoxShadow(
                        color: Color(0x3F000000),
                        blurRadius: 4,
                        offset: Offset(0, 4),
                        spreadRadius: 0,
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 37,
                top: 720,
                child: Container(
                  width: 154,
                  height: 103,
                  decoration: ShapeDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://placehold.co/154x103"),
                      fit: BoxFit.fill,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 41,
                top: 836,
                child: Text(
                  'Rice Mushroom',
                  style: TextStyle(
                    color: const Color(0xFFD4741B),
                    fontSize: 10,
                    fontFamily: 'Geologica',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Positioned(
                left: 41,
                top: 850,
                child: Text(
                  'IDR 15.000',
                  style: TextStyle(
                    color: const Color(0xFF8A4607),
                    fontSize: 10,
                    fontFamily: 'Geologica',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Positioned(
                left: 41,
                top: 876,
                child: Text(
                  'Tersedia',
                  style: TextStyle(
                    color: const Color(0xFF767070),
                    fontSize: 7,
                    fontFamily: 'Instrument Sans',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 156,
                top: 863,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF8A4607),
                    shape: OvalBorder(),
                  ),
                ),
              ),
              Positioned(
                left: 162,
                top: 863,
                child: Text(
                  '+',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'Geologica',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Positioned(
                left: 234,
                top: 519,
                child: Container(
                  width: 162,
                  height: 183,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    shadows: [
                      BoxShadow(
                        color: Color(0x3F000000),
                        blurRadius: 4,
                        offset: Offset(0, 4),
                        spreadRadius: 0,
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 242,
                top: 640,
                child: Text(
                  'Rice Chicken Blackpapper',
                  style: TextStyle(
                    color: const Color(0xFFD4741B),
                    fontSize: 10,
                    fontFamily: 'Geologica',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Positioned(
                left: 242,
                top: 654,
                child: Text(
                  'IDR 15.000',
                  style: TextStyle(
                    color: const Color(0xFF8A4607),
                    fontSize: 10,
                    fontFamily: 'Geologica',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Positioned(
                left: 242,
                top: 678,
                child: Text(
                  'Tersedia',
                  style: TextStyle(
                    color: const Color(0xFF767070),
                    fontSize: 7,
                    fontFamily: 'Instrument Sans',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 355,
                top: 667,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF8A4607),
                    shape: OvalBorder(),
                  ),
                ),
              ),
              Positioned(
                left: 361,
                top: 667,
                child: Text(
                  '+',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'Geologica',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Positioned(
                left: 238,
                top: 523,
                child: Container(
                  width: 154,
                  height: 101,
                  decoration: ShapeDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://placehold.co/154x101"),
                      fit: BoxFit.fill,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 33,
                top: 519,
                child: Container(
                  width: 162,
                  height: 183,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    shadows: [
                      BoxShadow(
                        color: Color(0x3F000000),
                        blurRadius: 4,
                        offset: Offset(0, 4),
                        spreadRadius: 0,
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 37,
                top: 523,
                child: Container(
                  width: 154,
                  height: 104,
                  decoration: ShapeDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://placehold.co/154x104"),
                      fit: BoxFit.fill,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 41,
                top: 640,
                child: Text(
                  'Bakso Special',
                  style: TextStyle(
                    color: const Color(0xFFD4741B),
                    fontSize: 10,
                    fontFamily: 'Geologica',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Positioned(
                left: 41,
                top: 654,
                child: Text(
                  'IDR 13.000',
                  style: TextStyle(
                    color: const Color(0xFF8A4607),
                    fontSize: 10,
                    fontFamily: 'Geologica',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Positioned(
                left: 156,
                top: 667,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF8A4607),
                    shape: OvalBorder(),
                  ),
                ),
              ),
              Positioned(
                left: 162,
                top: 667,
                child: Text(
                  '+',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'Geologica',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Positioned(
                left: 41,
                top: 680,
                child: Text(
                  'Tersedia',
                  style: TextStyle(
                    color: const Color(0xFF767070),
                    fontSize: 7,
                    fontFamily: 'Instrument Sans',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 234,
                top: 320,
                child: Container(
                  width: 162,
                  height: 183,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    shadows: [
                      BoxShadow(
                        color: Color(0x3F000000),
                        blurRadius: 4,
                        offset: Offset(0, 4),
                        spreadRadius: 0,
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 242,
                top: 441,
                child: Text(
                  'Chicken Teriyaki',
                  style: TextStyle(
                    color: const Color(0xFFD4741B),
                    fontSize: 10,
                    fontFamily: 'Geologica',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Positioned(
                left: 242,
                top: 455,
                child: Text(
                  'IDR  17.000',
                  style: TextStyle(
                    color: const Color(0xFF8A4607),
                    fontSize: 10,
                    fontFamily: 'Geologica',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Positioned(
                left: 242,
                top: 479,
                child: Text(
                  'Tersedia',
                  style: TextStyle(
                    color: const Color(0xFF767070),
                    fontSize: 7,
                    fontFamily: 'Instrument Sans',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 238,
                top: 324,
                child: Container(
                  width: 154,
                  height: 104,
                  decoration: ShapeDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://placehold.co/154x104"),
                      fit: BoxFit.fill,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 355,
                top: 468,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF8A4607),
                    shape: OvalBorder(),
                  ),
                ),
              ),
              Positioned(
                left: 361,
                top: 468,
                child: Text(
                  '+',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'Geologica',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Positioned(
                left: 33,
                top: 320,
                child: Container(
                  width: 162,
                  height: 183,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    shadows: [
                      BoxShadow(
                        color: Color(0x3F000000),
                        blurRadius: 4,
                        offset: Offset(0, 4),
                        spreadRadius: 0,
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 37,
                top: 324,
                child: Container(
                  width: 154,
                  height: 104,
                  decoration: ShapeDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://placehold.co/154x104"),
                      fit: BoxFit.cover,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 41,
                top: 441,
                child: Text(
                  'Rice Sambal Goreng Cumi',
                  style: TextStyle(
                    color: const Color(0xFFD4741B),
                    fontSize: 10,
                    fontFamily: 'Geologica',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Positioned(
                left: 41,
                top: 455,
                child: Text(
                  'IDR 18.000',
                  style: TextStyle(
                    color: const Color(0xFF8A4607),
                    fontSize: 10,
                    fontFamily: 'Geologica',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Positioned(
                left: 41,
                top: 481,
                child: Text(
                  'Tersedia',
                  style: TextStyle(
                    color: const Color(0xFF767070),
                    fontSize: 7,
                    fontFamily: 'Instrument Sans',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 156,
                top: 466,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF8A4607),
                    shape: OvalBorder(),
                  ),
                ),
              ),
              Positioned(
                left: 162,
                top: 466,
                child: Text(
                  '+',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'Geologica',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Positioned(
                left: 234,
                top: 121,
                child: Container(
                  width: 162,
                  height: 183,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    shadows: [
                      BoxShadow(
                        color: Color(0x3F000000),
                        blurRadius: 4,
                        offset: Offset(0, 4),
                        spreadRadius: 0,
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 357,
                top: 267,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFE58A37),
                    shape: OvalBorder(),
                  ),
                ),
              ),
              Positioned(
                left: 363,
                top: 267,
                child: Text(
                  '+',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'Geologica',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Positioned(
                left: 357,
                top: 267,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF8A4607),
                    shape: OvalBorder(),
                  ),
                ),
              ),
              Positioned(
                left: 363,
                top: 267,
                child: Text(
                  '+',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'Geologica',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Positioned(
                left: 242,
                top: 242,
                child: Text(
                  'Rice Chicken Blackpapper',
                  style: TextStyle(
                    color: const Color(0xFFD4741B),
                    fontSize: 10,
                    fontFamily: 'Geologica',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Positioned(
                left: 242,
                top: 256,
                child: Text(
                  'IDR 15.000',
                  style: TextStyle(
                    color: const Color(0xFF8A4607),
                    fontSize: 10,
                    fontFamily: 'Geologica',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Positioned(
                left: 242,
                top: 280,
                child: Text(
                  'Tersedia',
                  style: TextStyle(
                    color: const Color(0xFF767070),
                    fontSize: 7,
                    fontFamily: 'Instrument Sans',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 239,
                top: 126,
                child: Container(
                  width: 152,
                  height: 104,
                  decoration: ShapeDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://placehold.co/152x104"),
                      fit: BoxFit.fill,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 33,
                top: 121,
                child: Container(
                  width: 162,
                  height: 183,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    shadows: [
                      BoxShadow(
                        color: Color(0x3F000000),
                        blurRadius: 4,
                        offset: Offset(0, 4),
                        spreadRadius: 0,
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 37,
                top: 126,
                child: Container(
                  width: 154,
                  height: 104,
                  decoration: ShapeDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://placehold.co/154x104"),
                      fit: BoxFit.fill,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 41,
                top: 242,
                child: Text(
                  'Rice Chicken Mushroom',
                  style: TextStyle(
                    color: const Color(0xFFD4741B),
                    fontSize: 10,
                    fontFamily: 'Geologica',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Positioned(
                left: 41,
                top: 256,
                child: Text(
                  'IDR 15.000 ',
                  style: TextStyle(
                    color: const Color(0xFF8A4607),
                    fontSize: 10,
                    fontFamily: 'Geologica',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Positioned(
                left: 41,
                top: 282,
                child: Text(
                  'Tersedia',
                  style: TextStyle(
                    color: const Color(0xFF767070),
                    fontSize: 7,
                    fontFamily: 'Instrument Sans',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 156,
                top: 267,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF8A4607),
                    shape: OvalBorder(),
                  ),
                ),
              ),
              Positioned(
                left: 162,
                top: 267,
                child: Text(
                  '+',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'Geologica',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 115,
                child: Opacity(
                  opacity: 0.15,
                  child: Container(
                    width: 430,
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 1,
                          strokeAlign: BorderSide.strokeAlignCenter,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 40,
                top: 908,
                child: Container(
                  width: 355,
                  height: 45,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFF5CC9E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(35),
                    ),
                    shadows: [
                      BoxShadow(
                        color: Color(0x3F000000),
                        blurRadius: 4,
                        offset: Offset(0, 4),
                        spreadRadius: 0,
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 62,
                top: 915,
                child: Container(
                  width: 42,
                  height: 31,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://placehold.co/42x31"),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 150,
                top: 915,
                child: Container(
                  width: 41,
                  height: 31,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://placehold.co/41x31"),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 244,
                top: 915,
                child: Container(
                  width: 42,
                  height: 32,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://placehold.co/42x32"),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 332,
                top: 915,
                child: Container(
                  width: 42,
                  height: 32,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://placehold.co/42x32"),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 38,
                top: 36,
                child: Container(
                  width: 29,
                  height: 26,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://placehold.co/29x26"),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 19,
                top: 10,
                child: SizedBox(
                  width: 29,
                  height: 19,
                  child: Text(
                    '20.11',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                top: 10,
                child: Container(
                  width: 37,
                  height: 19,
                  decoration: BoxDecoration(color: Colors.white),
                ),
              ),
              Positioned(
                left: 406.14,
                top: 11,
                child: Container(
                  transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(1.57),
                  width: 19,
                  height: 20.36,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://placehold.co/19x20"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 384,
                top: 7,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(color: const Color(0xFFD9D9D9)),
                ),
              ),
              Positioned(
                left: 361.36,
                top: 11,
                child: Container(
                  width: 16.29,
                  height: 16.29,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://placehold.co/16x16"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 360,
                top: 10,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(color: Colors.white),
                ),
              ),
              Positioned(
                left: 339,
                top: 12,
                child: Container(
                  width: 14,
                  height: 15,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://placehold.co/14x15"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 332,
                top: 8,
                child: Container(
                  width: 24,
                  height: 21,
                  decoration: BoxDecoration(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}