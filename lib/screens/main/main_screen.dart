import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../home/home_screen.dart';
import '../anak/anak_screen.dart';
import '../keuangan/keuangan_screen.dart';
import '../inventaris/inventaris_screen.dart';
import '../artikel/artikel_screen.dart';
import '../profil/profil_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    AnakScreen(),
    KeuanganScreen(),
    InventarisScreen(),
    ArtikelScreen(),
  ];

  void _switchTab(int index) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _currentIndex = index);
  }

  void _goToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfilScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 0.8),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 62,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                iconOutlined: Icons.home_outlined,
                label: 'Home',
                index: 0,
                currentIndex: _currentIndex,
                onTap: () => _switchTab(0),
              ),
              _NavItem(
                icon: Icons.sentiment_satisfied_rounded,
                iconOutlined: Icons.sentiment_satisfied_alt_outlined,
                label: 'Anak',
                index: 1,
                currentIndex: _currentIndex,
                onTap: () => _switchTab(1),
              ),
              _NavItem(
                icon: Icons.account_balance_wallet_rounded,
                iconOutlined: Icons.account_balance_wallet_outlined,
                label: 'Keuangan',
                index: 2,
                currentIndex: _currentIndex,
                onTap: () => _switchTab(2),
              ),
              _NavItem(
                icon: Icons.inventory_2_rounded,
                iconOutlined: Icons.inventory_2_outlined,
                label: 'Inventaris',
                index: 3,
                currentIndex: _currentIndex,
                onTap: () => _switchTab(3),
              ),
              _NavItem(
                icon: Icons.newspaper_rounded,
                iconOutlined: Icons.newspaper_outlined,
                label: 'Artikel',
                index: 4,
                currentIndex: _currentIndex,
                onTap: () => _switchTab(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData iconOutlined;
  final String label;
  final int index;
  final int currentIndex;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.iconOutlined,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == currentIndex;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? icon : iconOutlined,
                color: isSelected ? AppColors.primary : AppColors.textTertiary,
                size: 22,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.primary : AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isSelected ? 18 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
