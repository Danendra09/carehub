import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/inventaris/inventaris_screen.dart';
import 'screens/kunjungan_tamu/kunjungan_tamu_screen.dart';
import 'screens/audit/audit_screen.dart';
import 'screens/struktur/struktur_screen.dart';

import 'screens/auth/forgot_password_screen.dart';
import 'screens/profil/profil_screen.dart';
import 'dart:io';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const CareHubApp());
}

/// Custom scroll behavior:
/// - Hilangkan efek lonjong/stretch saat overscroll (efek default Android 12+)
/// - Gunakan ClampingScrollPhysics: scroll berhenti clean di ujung
class _CareHubScrollBehavior extends ScrollBehavior {
  const _CareHubScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    // Hapus stretch/glow overscroll indicator
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    // Scroll langsung berhenti tanpa efek bounce/stretch
    return const ClampingScrollPhysics();
  }
}

class CareHubApp extends StatelessWidget {
  const CareHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CareHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Hilangkan efek lonjong/stretch saat overscroll (Android 12+)
      scrollBehavior: const _CareHubScrollBehavior(),
      home: const SplashScreen(),
      routes: {
        '/inventaris': (context) => const InventarisScreen(),
        '/kunjungan_tamu': (context) => const KunjunganTamuScreen(),
        '/audit': (context) => const AuditScreen(),
        '/struktur': (context) => const StrukturScreen(),

        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/profil': (context) => const ProfilScreen(),
      },
    );
  }
}