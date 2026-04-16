import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../auth/login_screen.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: CareHubAppBar(titleText: 'CareHub'),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Profile header
                Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          const CircleAvatar(
                            radius: 52,
                            backgroundColor: AppColors.darkCard,
                            child: Icon(Icons.person_rounded,
                                color: Colors.white70, size: 54),
                          ),
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: GestureDetector(
                              onTap: () {},
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.edit_rounded,
                                    color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Admin Utama',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'FULL ACCESS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                const Text('INFORMASI KONTAK', style: AppTextStyle.label),
                const SizedBox(height: 12),

                AppCard(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.phone_rounded,
                            color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 14),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('TELEPON', style: AppTextStyle.label),
                          SizedBox(height: 4),
                          Text(
                            '+62 812 3456 7890',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                AppCard(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.email_rounded,
                            color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 14),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('EMAIL', style: AppTextStyle.label),
                          SizedBox(height: 4),
                          Text(
                            'admin.utama@carehub.id',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                const Text('PENGATURAN KEAMANAN', style: AppTextStyle.label),
                const SizedBox(height: 12),

                _SecurityItem(
                  icon: Icons.lock_rounded,
                  title: 'Ubah Password',
                  subtitle: 'Terakhir diubah 2 bulan lalu',
                  onTap: () => _showChangePasswordSheet(context),
                ),

                const SizedBox(height: 10),

                _SecurityItem(
                  icon: Icons.shield_rounded,
                  title: 'Autentikasi Dua Faktor',
                  subtitle: 'Aktif',
                  subtitleColor: AppColors.success,
                  onTap: () {},
                ),

                const SizedBox(height: 24),

                const Text('PENGATURAN APLIKASI', style: AppTextStyle.label),
                const SizedBox(height: 12),

                _SettingsItem(
                  icon: Icons.notifications_rounded,
                  label: 'Notifikasi',
                  iconColor: AppColors.warning,
                  iconBg: AppColors.warningLight,
                  trailing: Switch(
                    value: true,
                    onChanged: (_) {},
                    activeThumbColor: AppColors.primary,
                  ),
                ),

                const SizedBox(height: 10),

                _SettingsItem(
                  icon: Icons.dark_mode_rounded,
                  label: 'Mode Gelap',
                  iconColor: AppColors.textSecondary,
                  iconBg: AppColors.border,
                  trailing: Switch(
                    value: false,
                    onChanged: (_) {},
                    activeThumbColor: AppColors.primary,
                  ),
                ),

                const SizedBox(height: 10),

                const _SettingsItem(
                  icon: Icons.language_rounded,
                  label: 'Bahasa',
                  iconColor: AppColors.info,
                  iconBg: Color(0xFFE0F2FE),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Indonesia', style: AppTextStyle.bodySmall),
                      SizedBox(width: 4),
                      Icon(Icons.chevron_right_rounded,
                          color: AppColors.textTertiary, size: 18),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Logout button
                GestureDetector(
                  onTap: () => _showLogoutDialog(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout_rounded,
                            color: AppColors.danger, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Logout dari Sesi',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.danger,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Center(
                  child: Text(
                    'CareHub v2.4.0 • Made with compassion',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari sesi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              minimumSize: const Size(80, 36),
            ),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ChangePasswordSheet(),
    );
  }
}

class _SecurityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? subtitleColor;
  final VoidCallback onTap;

  const _SecurityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.subtitleColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyle.body
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: subtitleColor ?? AppColors.textSecondary,
                    fontWeight: subtitleColor != null
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.textTertiary, size: 20),
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color iconBg;
  final Widget trailing;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.iconBg,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: AppTextStyle.body.copyWith(fontWeight: FontWeight.w600)),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _ChangePasswordSheet extends StatelessWidget {
  const _ChangePasswordSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Ubah Password', style: AppTextStyle.h3),
              const SizedBox(height: 20),
              const Text('PASSWORD LAMA', style: AppTextStyle.label),
              const SizedBox(height: 8),
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(hintText: '••••••••',
                  prefixIcon: Icon(Icons.lock_outline, color: AppColors.textTertiary),
                ),
              ),
              const SizedBox(height: 16),
              const Text('PASSWORD BARU', style: AppTextStyle.label),
              const SizedBox(height: 8),
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(hintText: '••••••••',
                  prefixIcon: Icon(Icons.lock_outline, color: AppColors.textTertiary),
                ),
              ),
              const SizedBox(height: 16),
              const Text('KONFIRMASI PASSWORD', style: AppTextStyle.label),
              const SizedBox(height: 8),
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(hintText: '••••••••',
                  prefixIcon: Icon(Icons.lock_outline, color: AppColors.textTertiary),
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'SIMPAN PASSWORD',
                icon: Icons.check_rounded,
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Password berhasil diubah'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
