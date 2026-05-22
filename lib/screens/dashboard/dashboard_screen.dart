import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/shared_widgets.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../utils/api_endpoints.dart';
import '../../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../inventaris/inventaris_screen.dart';
import '../audit/audit_screen.dart';
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  String _userName = 'Admin';
  String? _userFoto;

  // Data State
  double _totalSaldo = 0;
  double _totalPemasukan = 0;
  double _totalPengeluaran = 0;
  int _totalAnak = 0;
  int _totalBarang = 0;
  List<dynamic> _recentTrx = [];

  // Permissions
  bool _hasAnak = false;
  bool _hasKeuangan = false;
  bool _hasInventori = false;
  bool _hasAudit = false;
  bool _hasSuratAtauAudit = false;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      final token = await AuthService.getToken();
      final prefs = await SharedPreferences.getInstance();

      // Ambil data user terbaru dari backend
      try {
        final userResponse = await http.get(
          Uri.parse(ApiEndpoints.user),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
        if (userResponse.statusCode == 200) {
          final userData = json.decode(userResponse.body);
          await prefs.setString('user_name', userData['name'] ?? 'Admin');
          await prefs.setString('user_email', userData['email'] ?? '');
          await prefs.setString('user_role', userData['role'] ?? '');
          await prefs.setString('user_foto', userData['foto'] ?? '');
        }
      } catch (e) {
        debugPrint('Gagal mengambil data user terbaru: $e');
      }

      // Load permissions
      final hasAnak = await AuthService.hasPermission('view_anak');
      final hasKeuangan = await AuthService.hasPermission('view_keuangan');
      final hasInventori = await AuthService.hasPermission('view_inventori');
      final hasAudit = await AuthService.hasPermission('view_audit');
      final hasSuratAtauAudit = hasAudit || await AuthService.hasPermission('view_surat');

      // Fallback: jika admin atau semua permission kosong, tampilkan semua
      final role = prefs.getString('user_role') ?? '';
      final isAdmin = role.toLowerCase() == 'admin' || role.toLowerCase() == 'superadmin';

      setState(() {
        _hasAnak = isAdmin || hasAnak;
        _hasKeuangan = isAdmin || hasKeuangan;
        _hasInventori = isAdmin || hasInventori;
        _hasAudit = isAdmin || hasAudit;
        _hasSuratAtauAudit = isAdmin || hasSuratAtauAudit;
        
        _userName = prefs.getString('user_name') ?? 'Admin';

        String? rawFoto = prefs.getString('user_foto');
        if (rawFoto != null && rawFoto.isNotEmpty) {
          if (rawFoto.startsWith('http')) {
            _userFoto = rawFoto;
          } else {
            if (rawFoto.startsWith('/')) rawFoto = rawFoto.substring(1);
            _userFoto = '${ApiEndpoints.baseStorageUrl}/$rawFoto';
          }
        } else {
          _userFoto = null;
        }
      });

      final response = await http.get(
        Uri.parse(ApiEndpoints.dashboard),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _totalAnak = int.tryParse(data['total_anak']?.toString() ?? '0') ?? 0;
          _totalBarang =
              int.tryParse(data['total_barang']?.toString() ?? '0') ?? 0;
          _totalSaldo =
              double.tryParse(data['total_saldo']?.toString() ?? '0') ?? 0;
          _totalPemasukan =
              double.tryParse(data['pemasukan']?.toString() ?? '0') ?? 0;
          _totalPengeluaran =
              double.tryParse(data['pengeluaran']?.toString() ?? '0') ?? 0;

          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error fetching dashboard: $e');
    }
  }

  String _formatRupiah(double amount) {
    String res = amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    return 'Rp $res';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      body: RefreshIndicator(
        onRefresh: _fetchDashboardData,
        child: CustomScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(), // Memastikan bisa di-scroll & di-refresh
          slivers: [
            SliverToBoxAdapter(
              child: CareHubAppBar(
                avatarUrl: _userFoto,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                  20, 10, 20, 30), // Padding bawah dikurangi
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── HEADER TEKS (Tanpa Background) ──────────────────────────
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SELAMAT DATANG',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Halo, $_userName',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── KONTEN BAWAH ──────────────────────────────────────────
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── SALDO CARD ───────────────────────────────────────
                      if (_hasKeuangan) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF1D4ED8), Color(0xFF2563EB)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('TOTAL SALDO KAS',
                                  style: TextStyle(
                                      color: Colors.white, // Putih penuh
                                      fontSize: 14, // Diperbesar
                                      letterSpacing: 1.2,
                                      fontWeight: FontWeight.w800)), // Dipertebal
                              const SizedBox(height: 8),
                              Text(
                                _formatRupiah(_totalSaldo),
                                style: const TextStyle(
                                    fontSize: 40, // Diperbesar
                                    fontWeight: FontWeight.w900, // Dipertebal
                                    color: Colors.white,
                                    letterSpacing: -0.5),
                              ),
                              const SizedBox(height: 6),
                              const Text('Saldo bersih kas yayasan',
                                  style: TextStyle(
                                      color: Colors.white, // Putih penuh
                                      fontWeight: FontWeight.w600, // Dipertebal
                                      fontSize: 14)), // Diperbesar
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // ── PEMASUKAN & PENGELUARAN (full-width, 1 per baris) ─
                      if (_hasKeuangan) ...[
                        _StatCard(
                          icon: Icons.trending_up_rounded,
                          iconColor: AppColors.success,
                          iconBg: AppColors.successLight,
                          label: 'Pemasukan',
                          value: _formatRupiah(_totalPemasukan),
                          badge: 'In',
                        ),
                        const SizedBox(height: 12),
                        _StatCard(
                          icon: Icons.trending_down_rounded,
                          iconColor: AppColors.danger,
                          iconBg: AppColors.dangerLight,
                          label: 'Pengeluaran',
                          value: _formatRupiah(_totalPengeluaran),
                          badge: 'Out',
                        ),
                        const SizedBox(height: 12),
                      ],

                      // ── ANAK ASUH & TOTAL BARANG (2 kolom) ────────────────
                      if (_hasAnak || _hasInventori) ...[
                        Row(
                          children: [
                            if (_hasAnak)
                              Expanded(
                                child: _SmallStatCard(
                                  icon: Icons.people_alt_rounded,
                                  iconColor: AppColors.primary,
                                  iconBg: AppColors.primaryLight,
                                  label: 'Anak Asuh',
                                  value: '$_totalAnak Anak',
                                ),
                              ),
                            if (_hasAnak && _hasInventori) const SizedBox(width: 12),
                            if (_hasInventori)
                              Expanded(
                                child: _SmallStatCard(
                                  icon: Icons.inventory_2_rounded,
                                  iconColor: AppColors.warning,
                                  iconBg: AppColors.warningLight,
                                  label: 'Total Barang',
                                  value: '$_totalBarang Item',
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],

                      if (_hasInventori || _hasSuratAtauAudit) ...[
                        const Text(
                          'Aksi Cepat',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            if (_hasInventori)
                              Expanded(
                                child: _QuickActionCard(
                                  icon: Icons.inventory_2_rounded,
                                  label: 'Inventaris',
                                  color: AppColors.warning,
                                  bgColor: AppColors.warningLight,
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InventarisScreen())),
                                ),
                              ),
                            if (_hasInventori && _hasSuratAtauAudit) const SizedBox(width: 16),
                            if (_hasSuratAtauAudit)
                              Expanded(
                                child: _QuickActionCard(
                                  icon: Icons.shield_rounded,
                                  label: 'Audit',
                                  color: AppColors.danger,
                                  bgColor: AppColors.dangerLight,
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AuditScreen())),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;
  final String badge;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(label,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textSecondary,
                      )),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(badge,
                    style: TextStyle(
                        fontSize: 13,
                        color: iconColor,
                        fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(value,
              style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

// ── Stat Card Compact (2 kolom) ───────────────────────────────────────────────
class _SmallStatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;

  const _SmallStatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      onTap: onTap,
      child: Column(
        children: [
          IconBox(
            icon: icon,
            color: color,
            bgColor: bgColor,
            size: 56,
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
