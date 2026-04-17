import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/shared_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _formatRupiah(double amount) {
    String res = amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    return 'Rp $res';
  }

  double get _totalPemasukan => AppData.transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0, (sum, t) => sum + t.amount);

  double get _totalPengeluaran => AppData.transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (sum, t) => sum + t.amount);

  @override
  Widget build(BuildContext context) {
    final saldo = _totalPemasukan - _totalPengeluaran;
    final recentTrx = AppData.transactions.take(5).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: CareHubAppBar(),
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

                // ── SALDO CARD (total saldo terpisah) ──────────────────────
                Container(
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
                              color: Colors.white60,
                              fontSize: 11,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text(
                        _formatRupiah(saldo),
                        style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5),
                      ),
                      const SizedBox(height: 6),
                      const Text('Saldo bersih kas yayasan',
                          style: TextStyle(
                              color: Colors.white38,
                              fontSize: 12)),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ── PEMASUKAN & PENGELUARAN (2 card terpisah) ─────────────
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppColors.success
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  child: const Icon(
                                      Icons.trending_up_rounded,
                                      color: AppColors.success,
                                      size: 18),
                                ),
                                const SizedBox(width: 8),
                                const Text('Pemasukan',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.success)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _formatRupiah(_totalPemasukan),
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.success),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.dangerLight,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppColors.danger
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  child: const Icon(
                                      Icons.trending_down_rounded,
                                      color: AppColors.danger,
                                      size: 18),
                                ),
                                const SizedBox(width: 8),
                                const Text('Pengeluaran',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.danger)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _formatRupiah(_totalPengeluaran),
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.danger),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ── STAT CARDS ANAK & INVENTARIS ───────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.people_alt_rounded,
                        iconColor: AppColors.primary,
                        iconBg: AppColors.primaryLight,
                        label: 'Anak Asuh',
                        value: '${AppData.children.length}',
                        badge: 'Aktif',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.inventory_2_rounded,
                        iconColor: AppColors.warning,
                        iconBg: AppColors.warningLight,
                        label: 'Total Barang',
                        value: '${AppData.inventoryItems.length}',
                        badge: 'Item',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ── AKTIVITAS KEUANGAN TERBARU (card list) ─────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('AKTIVITAS KEUANGAN TERBARU',
                        style: AppTextStyle.label),
                    Text(
                      '${recentTrx.length} transaksi',
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (recentTrx.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text('Belum ada transaksi',
                          style: AppTextStyle.bodySmall),
                    ),
                  )
                else
                  ...recentTrx.map((t) {
                    final isIncome = t.type == TransactionType.income;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            // Icon indikator
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isIncome
                                    ? AppColors.successLight
                                    : AppColors.dangerLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                isIncome
                                    ? Icons.add_circle_outline_rounded
                                    : Icons.remove_circle_outline_rounded,
                                color: isIncome
                                    ? AppColors.success
                                    : AppColors.danger,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: AppColors.textPrimary),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    t.category,
                                    style: AppTextStyle.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Nominal
                            Text(
                              '${isIncome ? '+' : '-'}${_formatRupiah(t.amount)}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isIncome
                                    ? AppColors.success
                                    : AppColors.danger,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                const SizedBox(height: 4),
                const Center(
                  child: Text(
                    'Lihat semua di menu Keuangan',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600),
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(badge,
                    style: TextStyle(
                        fontSize: 9,
                        color: iconColor,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(value,
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
          Text(label, style: AppTextStyle.bodySmall),
        ],
      ),
    );
  }
}