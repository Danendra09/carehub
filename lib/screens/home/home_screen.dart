import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/shared_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _formatRupiah(double amount) {
    if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)} Jt';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(0)} rb';
    }
    return 'Rp ${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: CareHubAppBar(showAvatar: true),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const Text('SELAMAT DATANG', style: AppTextStyle.label),
                const SizedBox(height: 4),
                const Text('Halo, Admin Budi', style: AppTextStyle.h2),
                const SizedBox(height: 4),
                const Text(
                  'Ini ringkasan aktivitas yayasan hari ini.',
                  style: AppTextStyle.bodySmall,
                ),

                const SizedBox(height: 20),

                // SALDO CARD
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TOTAL SALDO KAS',
                          style: TextStyle(color: Colors.white70)),
                      SizedBox(height: 10),
                      Text('Rp 2.320.000',
                          style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // QUICK ACTION FIX
                const Text('AKSI CEPAT', style: AppTextStyle.label),
                const SizedBox(height: 12),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: const [
                      _QuickAction(
                        icon: Icons.add_card_rounded,
                        label: 'Input Kas',
                        color: AppColors.success,
                        bgColor: AppColors.successLight,
                      ),
                      SizedBox(width: 12),
                      _QuickAction(
                        icon: Icons.person_add_rounded,
                        label: 'Tambah Anak',
                        color: AppColors.primary,
                        bgColor: AppColors.primaryLight,
                      ),
                      SizedBox(width: 12),
                      _QuickAction(
                        icon: Icons.add_box_rounded,
                        label: 'Tambah Item',
                        color: AppColors.warning,
                        bgColor: AppColors.warningLight,
                      ),
                      SizedBox(width: 12),
                      _QuickAction(
                        icon: Icons.bar_chart_rounded,
                        label: 'Laporan',
                        color: AppColors.info,
                        bgColor: Color(0xFFE0F2FE),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    final data = AppData.cashflowData.take(5).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              data.length,
              (i) => FlSpot(i.toDouble(), data[i] / 1000000),
            ),
            isCurved: true,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: SizedBox(
        width: 80, // FIX BIAR GA MULUR
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}