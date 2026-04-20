import 'package:flutter/material.dart';
// 1. PASTIKAN FILE BERANDA SUDAH ADA. Jika nama filenya bukan beranda.dart, sesuaikan di bawah ini:
import 'beranda.dart'; 

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
        fontFamily: 'Poppins',
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
  bool _isPressed = false;
  bool _isRememberMe = false;


  // 🎨 WARNA UTAMA (SUDAH DIHALUSKAN)

  final Color primary = const Color(0xFFB86B2B);
  final Color textDark = const Color(0xFF6D4C41);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFFF8F2),
            Color(0xFFF3E5D8),
            Color(0xFFE8CBB0),
          ],
          stops: [0.2, 0.6, 1.0],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(

            padding:
                const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children:[
                // === LOGO ===
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: primary.withOpacity(0.2), width: 2),
                        color: Colors.white,
                      ),
                      child: const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.transparent,
                        backgroundImage:
                            AssetImage('assets/nettyzencafe.png'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Nettyzen Access',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Cafe & UMKM Solution',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 50),

                _buildCustomToggle(),
                const SizedBox(height: 30),


                const SizedBox(height: 50),
                _buildCustomToggle(),
                const SizedBox(height: 30),
                _buildInputField(
                  label: "Email",
                  hint: "ambarya@gmail.com",
                  icon: Icons.email_outlined,
                ),


                const SizedBox(height: 20),


                const SizedBox(height: 20),

                _buildInputField(
                  label: "User Name",
                  hint: "masukkan username",
                  icon: Icons.person_outline,
                ),

                _buildRememberAndForgot(),
                const SizedBox(height: 40),

                _buildLoginButton(),

                _buildRememberAndForgot(),
                const SizedBox(height: 40),
                // 2. Sekarang mengirimkan 'context' ke dalam fungsi button
                _buildLoginButton(context),

              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildLoginButton() {

  // === BUTTON LOGIN DENGAN NAVIGASI ===
  Widget _buildLoginButton(BuildContext context) {

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),


      onTap: () {
        // 3. Fungsi pindah ke halaman Beranda
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PuBeranda()),
        );
      },

      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: double.infinity,
          height: 55,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              colors: [
                primary.withOpacity(0.8),
                primary,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: primary.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              "LOGIN",
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
    );
  }

  Widget _buildRememberAndForgot() {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Checkbox(
                value: _isRememberMe,
                onChanged: (value) =>
                    setState(() => _isRememberMe = value ?? false),
                activeColor: primary,
              ),
              const SizedBox(width: 10),
              Text("Ingat Saya", style: TextStyle(color: textDark)),
            ],
          ),
          Text(
            "Lupa Password?",
            style: TextStyle(
              color: primary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isUserSelected = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: isUserSelected ? primary : Colors.transparent,
                  borderRadius:
                      const BorderRadius.horizontal(left: Radius.circular(30)),
                ),
                alignment: Alignment.center,
                child: Text(
                  "User",
                  style: TextStyle(
                    color: isUserSelected ? Colors.white : textDark,
                    fontWeight: FontWeight.w600,
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
                decoration: BoxDecoration(
                  color: !isUserSelected ? primary : Colors.transparent,
                  borderRadius:
                      const BorderRadius.horizontal(right: Radius.circular(30)),
                ),
                alignment: Alignment.center,
                child: Text(
                  "Admin",
                  style: TextStyle(
                    color: !isUserSelected ? Colors.white : textDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: textDark,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(
                icon,
                color: primary,
                size: 22,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}