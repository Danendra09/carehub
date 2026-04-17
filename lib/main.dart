import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/splash/splash_screen.dart';

void main() {
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
    );
  }
}