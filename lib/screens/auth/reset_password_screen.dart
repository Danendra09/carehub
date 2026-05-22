import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../../utils/api_endpoints.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String? cookie;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.cookie,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _otpCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _isLoading = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _otpCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final headers = <String, String>{
        'Accept': 'application/json',
      };
      // Inject session cookie agar backend mengenali sesi OTP
      if (widget.cookie != null) {
        headers['Cookie'] = widget.cookie!;
      }

      final response = await http.post(
        Uri.parse(ApiEndpoints.resetPassword),
        headers: headers,
        body: {
          'otp': _otpCtrl.text.trim(),
          'password': _passCtrl.text,
          // 'password_confirmation': _confirmCtrl.text, // Laravel auth reset tidak menggunakan _confirmation secara default di metode kita
        },
      );

      final data = json.decode(response.body);
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password berhasil diubah! Silakan login.'),
            backgroundColor: AppColors.success,
          ),
        );

        // Kembali ke layar login
        Navigator.pushAndRemoveUntil(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const LoginScreen(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 400),
          ),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Gagal mereset password'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan koneksi. Coba lagi.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE8EEFF), Color(0xFFF5F8FF), Color(0xFFEEF2FF)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: screenH -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom -
                        kToolbarHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // ── CARD ─────────────────────────────────────
                          Form(
                            key: _formKey,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.08),
                                    blurRadius: 40,
                                    offset: const Offset(0, 12),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 12,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // HEADER
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0xFF10B981), // Emerald gradient
                                          Color(0xFF059669),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(28),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 70,
                                          height: 70,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: const Icon(
                                            Icons.verified_user_rounded,
                                            color: Colors.white,
                                            size: 36,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Verifikasi OTP',
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // FORM FIELDS
                                  Padding(
                                    padding: const EdgeInsets.all(28),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Kode 6-digit telah dikirim ke WA untuk akun:\n${widget.email}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.textSecondary,
                                            height: 1.5,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 24),

                                        // OTP
                                        const Text('KODE OTP', style: AppTextStyle.label),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          controller: _otpCtrl,
                                          keyboardType: TextInputType.number,
                                          maxLength: 6,
                                          style: AppTextStyle.body.copyWith(
                                            letterSpacing: 4.0,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                          textAlign: TextAlign.center,
                                          decoration: const InputDecoration(
                                            counterText: '',
                                            hintText: '123456',
                                            hintStyle: TextStyle(
                                                color: AppColors.textTertiary,
                                                letterSpacing: 4.0),
                                          ),
                                          validator: (v) =>
                                              v == null || v.isEmpty ? 'Isi kode OTP' : null,
                                        ),
                                        const SizedBox(height: 18),

                                        // Password Baru
                                        const Text('PASSWORD BARU', style: AppTextStyle.label),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          controller: _passCtrl,
                                          obscureText: _obscurePass,
                                          style: AppTextStyle.body,
                                          decoration: InputDecoration(
                                            hintText: 'Min. 6 karakter',
                                            hintStyle: const TextStyle(
                                                color: AppColors.textTertiary),
                                            prefixIcon: const Icon(Icons.lock_outline,
                                                color: AppColors.textTertiary),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _obscurePass
                                                    ? Icons.visibility_outlined
                                                    : Icons.visibility_off_outlined,
                                                color: AppColors.textTertiary,
                                                size: 20,
                                              ),
                                              onPressed: () => setState(
                                                  () => _obscurePass = !_obscurePass),
                                            ),
                                          ),
                                          validator: (v) {
                                            if (v == null || v.isEmpty) return 'Wajib diisi';
                                            if (v.length < 6) return 'Minimal 6 karakter';
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 18),

                                        // Konfirmasi
                                        const Text('KONFIRMASI PASSWORD',
                                            style: AppTextStyle.label),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          controller: _confirmCtrl,
                                          obscureText: _obscureConfirm,
                                          style: AppTextStyle.body,
                                          decoration: InputDecoration(
                                            hintText: 'Ulangi password baru',
                                            hintStyle: const TextStyle(
                                                color: AppColors.textTertiary),
                                            prefixIcon: const Icon(Icons.lock_outline,
                                                color: AppColors.textTertiary),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _obscureConfirm
                                                    ? Icons.visibility_outlined
                                                    : Icons.visibility_off_outlined,
                                                color: AppColors.textTertiary,
                                                size: 20,
                                              ),
                                              onPressed: () => setState(() =>
                                                  _obscureConfirm = !_obscureConfirm),
                                            ),
                                          ),
                                          validator: (v) {
                                            if (v == null || v.isEmpty) return 'Wajib diisi';
                                            if (v != _passCtrl.text) {
                                              return 'Password tidak cocok';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 28),

                                        PrimaryButton(
                                          text: 'UBAH PASSWORD SEKARANG',
                                          isLoading: _isLoading,
                                          onPressed: _resetPassword,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
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
}
