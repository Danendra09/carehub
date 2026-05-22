import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../dashboard/dashboard_screen.dart';
import '../manajemen_anak/manajemen_anak_screen.dart';
import '../keuangan/keuangan_screen.dart';
import '../profil/profil_screen.dart';
import '../inventaris/inventaris_screen.dart';
import '../kunjungan_tamu/kunjungan_tamu_screen.dart';
import '../audit/audit_screen.dart';
import '../../services/auth_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _allScreens = const [
    DashboardScreen(),
    ManajemenAnakScreen(),
    KeuanganScreen(),
    KunjunganTamuScreen(),
    InventarisScreen(),
  ];

  List<Widget> _activeScreens = [];
  List<Map<String, dynamic>> _activeNavItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPermissions();
  }

  Future<void> _loadPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('user_role') ?? '';
    final isAdmin = role.toLowerCase() == 'admin' || role.toLowerCase() == 'superadmin';
    final hasAnak = await AuthService.hasPermission('view_anak');
    final hasKeuangan = await AuthService.hasPermission('view_keuangan');
    final hasTamu = await AuthService.hasPermission('view_kunjungan');
    final hasInventori = await AuthService.hasPermission('view_inventori');
    final hasSuratAtauAudit = await AuthService.hasPermission('view_audit') || await AuthService.hasPermission('view_surat');

    setState(() {
      _activeScreens.clear();
      _activeNavItems.clear();

      // 1. Selalu tambahkan Dashboard (Home)
      _activeScreens.add(const DashboardScreen());
      _activeNavItems.add({
        'icon': Icons.home_rounded,
        'iconOutlined': Icons.home_outlined,
        'label': 'Home',
      });

      // 2. Modul Anak
      if (isAdmin || hasAnak) {
        _activeScreens.add(const ManajemenAnakScreen());
        _activeNavItems.add({
          'icon': Icons.sentiment_satisfied_rounded,
          'iconOutlined': Icons.sentiment_satisfied_alt_outlined,
          'label': 'Anak',
        });
      }

      // 3. Modul Keuangan
      if (isAdmin || hasKeuangan) {
        _activeScreens.add(const KeuanganScreen());
        _activeNavItems.add({
          'icon': Icons.account_balance_wallet_rounded,
          'iconOutlined': Icons.account_balance_wallet_outlined,
          'label': 'Keuangan',
        });
      }

      // 4. Modul Tamu
      if (isAdmin || hasTamu) {
        _activeScreens.add(const KunjunganTamuScreen());
        _activeNavItems.add({
          'icon': Icons.groups_rounded,
          'iconOutlined': Icons.groups_outlined,
          'label': 'Tamu',
        });
      }

      // 5. Modul Inventaris
      // Khusus Kepala Panti (admin) disembunyikan karena sudah ada di menu aksi cepat
      if (!isAdmin && hasInventori) {
        _activeScreens.add(const InventarisScreen());
        _activeNavItems.add({
          'icon': Icons.inventory_2_rounded,
          'iconOutlined': Icons.inventory_2_outlined,
          'label': 'Inventaris',
        });
      }

      // 6. Modul Audit & Surat
      // Khusus Kepala Panti (admin) disembunyikan karena sudah ada di menu aksi cepat
      if (!isAdmin && hasSuratAtauAudit) {
        _activeScreens.add(const AuditScreen());
        _activeNavItems.add({
          'icon': Icons.folder_shared_rounded,
          'iconOutlined': Icons.folder_shared_outlined,
          'label': 'Audit',
        });
      }

      // 7. Profil (Akun)
      // Kepala Panti (admin) disembunyikan karena sudah ada di pojok kanan atas AppBar
      if (!isAdmin) {
        _activeScreens.add(const ProfilScreen());
        _activeNavItems.add({
          'icon': Icons.person_rounded,
          'iconOutlined': Icons.person_outline_rounded,
          'label': 'Akun',
        });
      }

      _isLoading = false;
    });
  }


  void _switchTab(int index) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _currentIndex = index);
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      body: _activeScreens[_currentIndex],
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
            children: List.generate(_activeNavItems.length, (index) {
              final item = _activeNavItems[index];
              return Expanded(
                child: _NavItem(
                  icon: item['icon'],
                  iconOutlined: item['iconOutlined'],
                  label: item['label'],
                  index: index,
                  currentIndex: _currentIndex,
                  onTap: () => _switchTab(index),
                ),
              );
            }),
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
      child: Container(
        color: Colors.transparent,
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
