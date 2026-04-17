import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../main/main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

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
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const MainScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
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
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 32),

                          // ── LOGIN CARD ─────────────────────────────────────
                          Form(
                            key: _formKey,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.08),
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
                                  // ── HEADER: icon + brand di dalam card ──
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.fromLTRB(
                                        28, 32, 28, 24),
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0xFF1D4ED8),
                                          Color(0xFF2563EB),
                                          Color(0xFF4F46E5),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(28),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        // Icon PNG
                                        Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            color: Colors.white
                                                .withValues(alpha: 0.15),
                                            borderRadius:
                                                BorderRadius.circular(22),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(18),
                                            child: Image.asset(
                                              'assets/images/icon.png',
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.contain,
                                              errorBuilder: (_, __, ___) =>
                                                  const Icon(
                                                      Icons.home_rounded,
                                                      color: Colors.white,
                                                      size: 40),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 14),
                                        // CareHub teks (Care putih, Hub putih terang)
                                        RichText(
                                          text: const TextSpan(
                                            children: [
                                              TextSpan(
                                                text: 'Care',
                                                style: TextStyle(
                                                  fontSize: 28,
                                                  fontWeight: FontWeight.w800,
                                                  color: Colors.white,
                                                  letterSpacing: -0.5,
                                                ),
                                              ),
                                              TextSpan(
                                                text: 'Hub',
                                                style: TextStyle(
                                                  fontSize: 28,
                                                  fontWeight: FontWeight.w800,
                                                  color: Color(0xFFBFDBFE),
                                                  letterSpacing: -0.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          'Cahaya Asuhan Ruang Empati',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.white60,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // ── FORM FIELDS ──
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        28, 28, 28, 28),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Selamat Datang 👋',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          'Masuk dengan akun admin Anda',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 24),

                                        // Email
                                        const Text('EMAIL / USERNAME',
                                            style: AppTextStyle.label),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          controller: _emailCtrl,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          style: AppTextStyle.body,
                                          decoration: const InputDecoration(
                                            hintText: 'name@carehub.id',
                                            hintStyle: TextStyle(
                                                color: AppColors.textTertiary),
                                            prefixIcon: Icon(
                                                Icons.person_outline,
                                                color: AppColors.textTertiary),
                                          ),
                                          validator: (v) => v == null ||
                                                  v.isEmpty
                                              ? 'Email tidak boleh kosong'
                                              : null,
                                        ),
                                        const SizedBox(height: 18),

                                        // Password
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('PASSWORD',
                                                style: AppTextStyle.label),
                                            GestureDetector(
                                              onTap: () {},
                                              child: const Text(
                                                'LUPA PASSWORD?',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.primary,
                                                  letterSpacing: 0.3,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          controller: _passCtrl,
                                          obscureText: _obscurePassword,
                                          style: AppTextStyle.body,
                                          decoration: InputDecoration(
                                            hintText: '••••••••',
                                            hintStyle: const TextStyle(
                                                color: AppColors.textTertiary),
                                            prefixIcon: const Icon(
                                                Icons.lock_outline,
                                                color: AppColors.textTertiary),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _obscurePassword
                                                    ? Icons.visibility_outlined
                                                    : Icons
                                                        .visibility_off_outlined,
                                                color: AppColors.textTertiary,
                                                size: 20,
                                              ),
                                              onPressed: () => setState(() =>
                                                  _obscurePassword =
                                                      !_obscurePassword),
                                            ),
                                          ),
                                          validator: (v) => v == null ||
                                                  v.isEmpty
                                              ? 'Password tidak boleh kosong'
                                              : null,
                                        ),
                                        const SizedBox(height: 28),

                                        // Login button
                                        PrimaryButton(
                                          text: 'MASUK KE DASHBOARD',
                                          isLoading: _isLoading,
                                          onPressed: _handleLogin,
                                        ),
                                        const SizedBox(height: 20),

                                        // Security badge
                                        const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.verified_user_outlined,
                                                size: 14,
                                                color: AppColors.textTertiary),
                                            SizedBox(width: 4),
                                            Text(
                                              'SECURITY VERIFIED',
                                              style: TextStyle(
                                                fontSize: 10,
                                                letterSpacing: 1.0,
                                                color: AppColors.textTertiary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),
                          const Text(
                            'CareHub © 2026',
                            style: TextStyle(
                              fontSize: 11,
                              letterSpacing: 1.5,
                              color: AppColors.textTertiary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 32),
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
