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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins', // Pastikan font Poppins sudah ditambahkan
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: LoginPage(),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isUserSelected = true;
  bool isPasswordVisible = false;
  bool _isPressed = false;
  
  // Variabel baru untuk status "Ingat Saya"
  bool _isRememberMe = false; 

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      height: size.height,
      width: size.width,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A0B06),
            Color(0xFF3E1F14),
            Color(0xFF2C1108),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Dekorasi Background
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF8A4607).withOpacity(0.15),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -30,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD97B29).withOpacity(0.08),
              ),
            ),
          ),

          // Konten Utama
          Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 450),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 30,
                            spreadRadius: 5,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF8A4607).withOpacity(0.1), width: 2),
                              color: const Color(0xFFFFF8F0),
                            ),
                            child: const CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.transparent,
                              backgroundImage: NetworkImage("https://placehold.co/80x80"),
                            ),
                          ),
                          const SizedBox(height: 20),

                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFF8A4607), Color(0xFFD97B29)],
                            ).createShader(bounds),
                            child: const Text(
                              'Nettyzen Access',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          Text(
                            'Cafe & UMKM Solution',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          
                          const SizedBox(height: 35),

                          // --- Toggle User / Admin ---
                          _buildCustomToggle(),
                          
                          const SizedBox(height: 30),

                          // Input Fields
                          _buildInputField(label: "Email", hint: "ambarya@gmail.com", icon: Icons.email_outlined, isPassword: false),
                          
                          const SizedBox(height: 20),
                          
                          _buildInputField(label: "Password", hint: "••••••••", icon: Icons.lock_outline, isPassword: true),

                          // --- Ingat Saya & Lupa Password (LOGIKA BARU) ---
                          Padding(
                            padding: const EdgeInsets.only(top: 15.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: Checkbox(
                                        // Menggunakan state _isRememberMe
                                        value: _isRememberMe,
                                        // Fungsi untuk mengubah nilai
                                        onChanged: (value) {
                                          setState(() {
                                            _isRememberMe = value ?? false;
                                          });
                                        },
                                        activeColor: const Color(0xFF8A4607),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text("Ingat Saya", style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500)),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {},
                                  child: Text(
                                    "Lupa Password?",
                                    style: TextStyle(
                                      color: Colors.brown[700],
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 35),

                          // Tombol Masuk
                          GestureDetector(
                            onTapDown: (_) => setState(() => _isPressed = true),
                            onTapUp: (_) => setState(() => _isPressed = false),
                            onTapCancel: () => setState(() => _isPressed = false),
                            child: AnimatedScale(
                              scale: _isPressed ? 0.96 : 1.0,
                              duration: const Duration(milliseconds: 150),
                              curve: Curves.easeInOut,
                              child: Container(
                                width: double.infinity,
                                height: 55,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFD97B29), Color(0xFF8A4607)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF8A4607).withOpacity(0.4),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Text(
                                    "MASUK",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomToggle() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        color: Colors.grey[200], 
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isUserSelected = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: isUserSelected 
                      ? const Color(0xFF8A4607) 
                      : Colors.transparent,
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(30)),
                ),
                alignment: Alignment.center,
                child: Text(
                  "User",
                  style: TextStyle(
                    color: isUserSelected 
                        ? Colors.white 
                        : Colors.grey[700],
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isUserSelected = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: !isUserSelected 
                      ? Colors.white 
                      : Colors.transparent,
                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(30)),
                  boxShadow: !isUserSelected 
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ] 
                      : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  "Admin",
                  style: TextStyle(
                    color: !isUserSelected 
                        ? const Color(0xFF804D1E) 
                        : Colors.grey[700],
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({required String label, required String hint, required IconData icon, required bool isPassword}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8A4607),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8F8F8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withOpacity(0.15)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
                offset: Offset(0, 2),
              )
            ],
          ),
          child: TextField(
            obscureText: isPassword ? !isPasswordVisible : false,
            style: const TextStyle(color: Colors.black87, fontFamily: 'Poppins'),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14, fontFamily: 'Poppins'),
              prefixIcon: Icon(icon, color: const Color(0xFF8A4607), size: 20),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey[500],
                        size: 20,
                      ),
                      onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
            ),
          ),
        ),
      ],
    );
  }
}