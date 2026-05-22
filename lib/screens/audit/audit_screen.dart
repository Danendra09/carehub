import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'audit_keuangan_screen.dart';
import 'audit_surat_screen.dart';

class AuditScreen extends StatefulWidget {
  const AuditScreen({super.key});

  @override
  State<AuditScreen> createState() => _AuditScreenState();
}

class _AuditScreenState extends State<AuditScreen> {
  bool _hasSurat = false;
  bool _hasAudit = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPermissions();
  }

  Future<void> _loadPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('user_role') ?? '';
    final allPerms = await AuthService.getPermissions();

    final isAdmin = role.toLowerCase() == 'admin' || role.toLowerCase() == 'superadmin';
    final hasSurat = await AuthService.hasPermission('view_surat');
    final hasAudit = await AuthService.hasPermission('view_audit');

    setState(() {
      _hasSurat = isAdmin || hasSurat;
      _hasAudit = isAdmin || hasAudit;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: CareHubAppBar(),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const Text('MANAJEMEN SEKRETARIAT & AUDIT', style: AppTextStyle.label),
                const SizedBox(height: 4),
                const Text('Modul Audit', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 24),
                
                // KARTU AUDIT SEKRETARIAT
                if (_hasSurat) ...[
                  _buildAuditCard(
                    context,
                    title: 'Audit\nSekretariat',
                    subtitle: 'REKAP KESEKRETARIATAN',
                    description: 'Pengelolaan administrasi surat masuk dan surat keluar. Dokumentasi referensi nomor surat, perihal, dan instansi pengirim atau tujuan.',
                    icon: Icons.folder_open_rounded,
                    color: const Color(0xFFF97316),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AuditSuratScreen()),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                
                // KARTU AUDIT KEUANGAN
                if (_hasAudit) ...[
                  _buildAuditCard(
                    context,
                    title: 'Audit\nKeuangan',
                    subtitle: 'VERIFIKASI TRANSAKSI',
                    description: 'Menghubungkan surat resmi dengan pencatatan keuangan. Referensi dan verifikasi dokumen pengeluaran untuk dasar pertanggungjawaban.',
                    icon: Icons.monetization_on_rounded,
                    color: const Color(0xFF2563EB),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AuditKeuanganScreen()),
                    ),
                  ),
                ],

                if (!_hasSurat && !_hasAudit)
                   const Center(
                     child: Padding(
                       padding: EdgeInsets.all(32.0),
                       child: Text('Anda tidak memiliki akses ke modul ini.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                     )
                   )
              ]),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAuditCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Color Section
            Container(
              height: 120,
              width: double.infinity,
              color: color,
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Body Section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: color,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Buka Modul',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 16, color: color),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

