import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'utils/session_manager.dart';
import 'beranda.dart';
import 'login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool isUserSelected   = true;
  bool _isPressed       = false;
  bool _isRememberMe    = false;
  bool _isLoading       = false;
  bool _obscurePassword = true;
  bool _obscureConfirm  = true;

  final TextEditingController _namaCtrl    = TextEditingController();
  final TextEditingController _emailCtrl   = TextEditingController();
  final TextEditingController _passCtrl    = TextEditingController();
  final TextEditingController _confirmCtrl = TextEditingController();
  final GlobalKey<FormState> _formKey      = GlobalKey<FormState>();

  final Color primary  = const Color(0xFFB86B2B);
  final Color textDark = const Color(0xFF6D4C41);

  @override
  void dispose() {
    _namaCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    String role = isUserSelected ? 'user' : 'admin';

    final response = await ApiService.register(
      namaLengkap: _namaCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      role: role,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (response.success && response.user != null) {
      await SessionManager.saveSession(response.user!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Registrasi berhasil!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PuBeranda()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

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
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // === LOGO & TITLE ===
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: primary.withOpacity(0.2), width: 2),
                          color: Colors.white,
                        ),
                        child: const CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.transparent,
                          backgroundImage: AssetImage('assets/nettyzencafe.png'),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'PU- Register',
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
                  const SizedBox(height: 40),

                  // === TOGGLE USER / ADMIN ===
                  _buildCustomToggle(),
                  const SizedBox(height: 25),

                  // === FIELD NAMA LENGKAP ===
                  _buildInputField(
                    label: "Nama Lengkap",
                    hint: "Masukkan nama lengkap anda",
                    icon: Icons.person_outline,
                    controller: _namaCtrl,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nama tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // === FIELD EMAIL ===
                  _buildInputField(
                    label: "Email",
                    hint: "ambarya@gmail.com",
                    icon: Icons.email_outlined,
                    controller: _emailCtrl,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Email tidak boleh kosong';
                      if (!value.contains('@')) return 'Format email tidak valid';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // === FIELD PASSWORD ===
                  _buildInputField(
                    label: "Password",
                    hint: "Masukkan password anda",
                    icon: Icons.lock_outline,
                    controller: _passCtrl,
                    obscureText: _obscurePassword,
                    isPassword: true,
                    onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Password tidak boleh kosong';
                      if (value.length < 6) return 'Password minimal 6 karakter';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // === FIELD KONFIRMASI PASSWORD ===
                  _buildInputField(
                    label: "Konfirmasi Password",
                    hint: "Konfirmasi password",
                    icon: Icons.lock_outline,
                    controller: _confirmCtrl,
                    obscureText: _obscureConfirm,
                    isPassword: true,
                    onToggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Konfirmasi password tidak boleh kosong';
                      if (value != _passCtrl.text) return 'Password tidak cocok';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // === INGAT SAYA ===
                  _buildRememberMe(),
                  const SizedBox(height: 30),

                  // === TOMBOL DAFTAR ===
                  _buildRegisterButton(),
                  const SizedBox(height: 20),

                  // === SUDAH PUNYA AKUN ===
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Sudah punya akun? ', style: TextStyle(color: textDark, fontSize: 13)),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const Scaffold(body: LoginPage())),
                        ),
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: primary,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
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
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(30)),
                ),
                alignment: Alignment.center,
                child: Text('User',
                    style: TextStyle(
                        color: isUserSelected ? Colors.white : textDark,
                        fontWeight: FontWeight.w600)),
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
                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(30)),
                ),
                alignment: Alignment.center,
                child: Text('Admin',
                    style: TextStyle(
                        color: !isUserSelected ? Colors.white : textDark,
                        fontWeight: FontWeight.w600)),
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
    TextEditingController? controller,
    String? Function(String?)? validator,
    bool obscureText    = false,
    bool isPassword     = false,
    VoidCallback? onToggleObscure,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))],
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, color: primary, size: 22),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey, size: 20),
                      onPressed: onToggleObscure,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              errorStyle: const TextStyle(fontSize: 12, height: 0.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRememberMe() {
    return Row(
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: _isRememberMe,
            onChanged: (value) => setState(() => _isRememberMe = value ?? false),
            activeColor: primary,
          ),
        ),
        const SizedBox(width: 10),
        Text("Ingat Saya", style: TextStyle(color: textDark, fontSize: 13)),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return GestureDetector(
      onTapDown: _isLoading ? null : (_) => setState(() => _isPressed = true),
      onTapUp: _isLoading ? null : (_) => setState(() => _isPressed = false),
      onTapCancel: _isLoading ? null : () => setState(() => _isPressed = false),
      onTap: _isLoading ? null : _handleRegister,
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
                _isLoading ? primary.withOpacity(0.6) : primary.withOpacity(0.8),
                primary,
              ],
            ),
            boxShadow: [BoxShadow(color: primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
          ),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : const Text(
                    "DAFTAR",
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
}