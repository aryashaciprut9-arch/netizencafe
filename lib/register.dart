import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/api_service.dart';
import 'utils/session_manager.dart';
import 'beranda.dart';
import 'login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with TickerProviderStateMixin {
  bool isUserSelected   = true;
  bool _isPressed       = false;
  bool _isRememberMe    = false;
  bool _isLoading       = false;
  bool _obscurePassword = true;
  bool _obscureConfirm  = true;

  // Focus state tracking
  bool _namaFocused     = false;
  bool _emailFocused    = false;
  bool _passFocused     = false;
  bool _confirmFocused  = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _namaCtrl    = TextEditingController();
  final TextEditingController _emailCtrl   = TextEditingController();
  final TextEditingController _passCtrl    = TextEditingController();
  final TextEditingController _confirmCtrl = TextEditingController();

  final FocusNode _namaFocusNode    = FocusNode();
  final FocusNode _emailFocusNode   = FocusNode();
  final FocusNode _passFocusNode    = FocusNode();
  final FocusNode _confirmFocusNode = FocusNode();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final Color primary   = const Color(0xFFB86B2B);
  final Color accent    = const Color(0xFF8D5524);
  final Color textDark  = const Color(0xFF6D4C41);
  final Color cardColor = const Color(0xFFFFFBF5);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack));

    // Focus listeners untuk setiap field
    _namaFocusNode.addListener(() => setState(() => _namaFocused = _namaFocusNode.hasFocus));
    _emailFocusNode.addListener(() => setState(() => _emailFocused = _emailFocusNode.hasFocus));
    _passFocusNode.addListener(() => setState(() => _passFocused = _passFocusNode.hasFocus));
    _confirmFocusNode.addListener(() => setState(() => _confirmFocused = _confirmFocusNode.hasFocus));

    _animationController.forward();
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _namaFocusNode.dispose();
    _emailFocusNode.dispose();
    _passFocusNode.dispose();
    _confirmFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // ✅ PERBAIKAN: Disesuaikan dengan Login agar aman dari error Type & Dead Code
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    String role = isUserSelected ? 'user' : 'admin';

    try {
      final response = await ApiService.register(
        namaLengkap: _namaCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        role: role,
      );

      setState(() => _isLoading = false);

      if (!mounted) return;

      if (response.success) {
        // ✅ Simpan data langsung dari controller (aman, tanpa bergantung pada response.user)
        await SessionManager.saveUserData(
          email: _emailCtrl.text.trim(),
          username: _namaCtrl.text.trim(),
          phone: '',
          address: '',
          role: role,
          id: '',
        );

        // Tampilkan snackbar sukses
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(child: Text('Registrasi berhasil!')),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              margin: const EdgeInsets.all(16),
            ),
          );

          // Navigasi ke Beranda
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const PuBeranda(),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        }
      } else {
        // Tampilkan snackbar error dari response API
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text(response.message)),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      // ✅ Tambahan: Menangkap error jika koneksi terputus atau API down
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.wifi_off, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Terjadi kesalahan: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFF8F2),
              Color(0xFFFDE8D7),
              Color(0xFFE8CBB0),
              Color(0xFFD4A57A),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 40),
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: primary.withOpacity(0.15),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildCustomToggle(),
                              const SizedBox(height: 28),
                              _buildInputField(
                                label: "Nama Lengkap",
                                hint: "Masukkan nama lengkap anda",
                                icon: Icons.person_outline_rounded,
                                controller: _namaCtrl,
                                focusNode: _namaFocusNode,
                                isFocused: _namaFocused,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Nama tidak boleh kosong';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              _buildInputField(
                                label: "Email",
                                hint: "ambarya@gmail.com",
                                icon: Icons.email_outlined,
                                controller: _emailCtrl,
                                focusNode: _emailFocusNode,
                                isFocused: _emailFocused,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) return 'Email tidak boleh kosong';
                                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                    return 'Format email tidak valid';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              _buildInputField(
                                label: "Password",
                                hint: "Minimal 6 karakter",
                                icon: Icons.lock_outline_rounded,
                                controller: _passCtrl,
                                focusNode: _passFocusNode,
                                isFocused: _passFocused,
                                obscureText: _obscurePassword,
                                isPassword: true,
                                onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Password tidak boleh kosong';
                                  if (value.length < 6) return 'Password minimal 6 karakter';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              _buildInputField(
                                label: "Konfirmasi Password",
                                hint: "Ulangi password anda",
                                icon: Icons.lock_outline_rounded,
                                controller: _confirmCtrl,
                                focusNode: _confirmFocusNode,
                                isFocused: _confirmFocused,
                                obscureText: _obscureConfirm,
                                isPassword: true,
                                onToggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm),
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Konfirmasi password tidak boleh kosong';
                                  if (value != _passCtrl.text) return 'Password tidak cocok';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              _buildRememberMe(),
                              const SizedBox(height: 32),
                              _buildRegisterButton(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildLoginLink(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Hero(
          tag: 'logo',
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [primary.withOpacity(0.2), Colors.transparent]),
              border: Border.all(color: primary.withOpacity(0.3), width: 3),
              boxShadow: [
                BoxShadow(color: primary.withOpacity(0.25), blurRadius: 25, offset: const Offset(0, 12)),
              ],
            ),
            child: CircleAvatar(
              radius: 55,
              backgroundColor: Colors.white,
              backgroundImage: const AssetImage('assets/nettyzencafe.png'),
            ),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'PU-Register',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: textDark,
            height: 1.1,
            shadows: [
              Shadow(color: Colors.black.withOpacity(0.1), offset: const Offset(0, 2), blurRadius: 4),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Cafe & UMKM Solution',
          textAlign: TextAlign.center,
          style: GoogleFonts.openSans(
            color: textDark.withOpacity(0.8),
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildCustomToggle() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeInOutBack,
      switchOutCurve: Curves.easeInOutBack,
      transitionBuilder: (child, animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(isUserSelected ? 1.0 : -1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: Container(
        key: ValueKey(isUserSelected),
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.white, cardColor]),
          borderRadius: BorderRadius.circular(35),
          border: Border.all(color: primary.withOpacity(0.2), width: 1.5),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 6)),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => isUserSelected = true),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    gradient: isUserSelected
                        ? LinearGradient(colors: [primary, accent])
                        : null,
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(35)),
                    boxShadow: isUserSelected
                        ? [BoxShadow(color: primary.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))]
                        : null,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  alignment: Alignment.center,
                  child: Text(
                    'User',
                    style: GoogleFonts.poppins(
                      color: isUserSelected ? Colors.white : textDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => isUserSelected = false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    gradient: !isUserSelected
                        ? LinearGradient(colors: [primary, accent])
                        : null,
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(35)),
                    boxShadow: !isUserSelected
                        ? [BoxShadow(color: primary.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))]
                        : null,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  alignment: Alignment.center,
                  child: Text(
                    'Admin',
                    style: GoogleFonts.poppins(
                      color: !isUserSelected ? Colors.white : textDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required IconData icon,
    TextEditingController? controller,
    FocusNode? focusNode,
    bool isFocused = false,
    String? Function(String?)? validator,
    bool obscureText = false,
    bool isPassword = false,
    VoidCallback? onToggleObscure,
    TextInputType? keyboardType,
  }) {
    final Color currentBorderColor = isFocused
        ? primary
        : primary.withOpacity(0.45);

    final double currentBorderWidth = isFocused ? 2.0 : 1.5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: textDark,
            fontWeight: FontWeight.w700,
            fontSize: 15,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isFocused
                  ? [Colors.white, Color(0xFFFFF5EB)]
                  : [Colors.white, cardColor],
            ),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: currentBorderColor,
              width: currentBorderWidth,
            ),
            boxShadow: [
              BoxShadow(
                color: isFocused
                    ? primary.withOpacity(0.15)
                    : Colors.black.withOpacity(0.05),
                blurRadius: isFocused ? 16 : 8,
                offset: isFocused
                    ? const Offset(0, 4)
                    : const Offset(0, 3),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            obscureText: obscureText,
            validator: validator,
            style: GoogleFonts.openSans(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: textDark,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.openSans(
                fontSize: 15,
                color: textDark.withOpacity(0.45),
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(16),
                child: Icon(
                  icon,
                  color: isFocused ? primary : primary.withOpacity(0.65),
                  size: 24,
                ),
              ),
              suffixIcon: isPassword
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: IconButton(
                        icon: Icon(
                          obscureText
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: isFocused
                              ? primary
                              : primary.withOpacity(0.55),
                          size: 22,
                        ),
                        onPressed: onToggleObscure,
                      ),
                    )
                  : null,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 8,
              ),
              errorStyle: GoogleFonts.openSans(
                fontSize: 13,
                height: 0.8,
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRememberMe() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => setState(() => _isRememberMe = !_isRememberMe),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 24,
            width: 24,
            decoration: BoxDecoration(
              color: _isRememberMe ? primary : Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _isRememberMe
                    ? primary
                    : primary.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: _isRememberMe
                ? const Icon(Icons.check, size: 18, color: Colors.white)
                : null,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          "Ingat Saya",
          style: GoogleFonts.openSans(
            color: textDark,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
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
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: double.infinity,
          height: 62,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(35),
            gradient: LinearGradient(
              colors: [
                _isLoading ? primary.withOpacity(0.5) : primary.withOpacity(0.95),
                accent,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: primary.withOpacity(0.4),
                blurRadius: 25,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Center(
            child: _isLoading
                ? SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                      backgroundColor: Colors.white.withOpacity(0.3),
                    ),
                  )
                : Text(
                    "DAFTAR SEKARANG",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Sudah punya akun? ',
          style: GoogleFonts.openSans(
            color: textDark.withOpacity(0.8),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const Scaffold(body: LoginPage()),
              transitionsBuilder: (_, animation, __, child) =>
                  FadeTransition(opacity: animation, child: child),
            ),
          ),
          child: Text(
            'Login disini',
            style: GoogleFonts.poppins(
              color: primary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              decoration: TextDecoration.underline,
              decorationColor: primary,
              decorationThickness: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}