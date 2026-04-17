import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/shared_widgets.dart';

class KeuanganScreen extends StatefulWidget {
  const KeuanganScreen({super.key});

  @override
  State<KeuanganScreen> createState() => _KeuanganScreenState();
}

class _KeuanganScreenState extends State<KeuanganScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatRupiah(double amount) {
    if (amount >= 1000000) {
      final val = amount / 1000000;
      return 'Rp ${val % 1 == 0 ? val.toStringAsFixed(0) : val.toStringAsFixed(3)}.000';
    }
    return 'Rp ${amount.toStringAsFixed(0)}';
  }

  String _formatShort(double amount) {
    if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(3)}.000';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(0)}.000';
    }
    return 'Rp ${amount.toStringAsFixed(0)}';
  }

  List<TransactionModel> _getFiltered(int tabIndex) {
    if (tabIndex == 0) return AppData.transactions;
    if (tabIndex == 1) {
      return AppData.transactions
          .where((t) => t.type == TransactionType.income)
          .toList();
    }
    return AppData.transactions
        .where((t) => t.type == TransactionType.expense)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
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
                const Text('LAPORAN KEUANGAN', style: AppTextStyle.label),
                const SizedBox(height: 4),
                const Text('Ringkasan Saldo', style: AppTextStyle.h2),

                const SizedBox(height: 20),

                // Income card
                const _SummaryCard(
                  label: 'TOTAL PEMASUKAN',
                  amount: 'Rp 12.450.000',
                  trend: '↑ 12% dari bulan lalu',
                  trendPositive: true,
                  icon: Icons.trending_up_rounded,
                  iconBg: AppColors.successLight,
                  iconColor: AppColors.success,
                ),

                const SizedBox(height: 12),

                // Expense card
                const _SummaryCard(
                  label: 'TOTAL PENGELUARAN',
                  amount: 'Rp 4.120.000',
                  trend: '↓ 5% lebih hemat',
                  trendPositive: false,
                  icon: Icons.trending_down_rounded,
                  iconBg: AppColors.dangerLight,
                  iconColor: AppColors.danger,
                ),

                const SizedBox(height: 24),

                // Transactions header
                SectionHeader(
                  title: 'Riwayat Transaksi',
                  actionText: 'Lihat Semua',
                  onAction: () {},
                ),

                const SizedBox(height: 12),

                // Filter tabs
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    onTap: (i) => setState(() {}),
                    indicator: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.white,
                    unselectedLabelColor: AppColors.textSecondary,
                    labelStyle: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600),
                    dividerColor: Colors.transparent,
                    padding: const EdgeInsets.all(4),
                    tabs: const [
                      Tab(text: 'Semua'),
                      Tab(text: 'Pemasukan'),
                      Tab(text: 'Pengeluaran'),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Transaction list
                ..._getFiltered(_tabController.index)
                    .map((t) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _TransactionCard(
                            transaction: t,
                            onHapus: () => _hapusTransaksi(context, t),
                          ),
                        )),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_keuangan',
        onPressed: () => _showAddTransactionSheet(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'TAMBAH',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
        ),
      ),
    );
  }

  void _showAddTransactionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddTransactionSheet(onSaved: () => setState(() {})),
    );
  }

  void _hapusTransaksi(BuildContext ctx, TransactionModel t) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Transaksi'),
        content: Text('Hapus transaksi "${t.title}" dari riwayat keuangan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              minimumSize: const Size(80, 40),
            ),
            onPressed: () {
              setState(() => AppData.transactions.removeWhere((x) => x.id == t.id));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(
                  content: const Text('Transaksi berhasil dihapus'),
                  backgroundColor: AppColors.danger,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String amount;
  final String trend;
  final bool trendPositive;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.trend,
    required this.trendPositive,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: iconColor,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            trend,
            style: TextStyle(
              fontSize: 12,
              color: trendPositive ? AppColors.success : AppColors.danger,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback onHapus;

  const _TransactionCard({
    required this.transaction,
    required this.onHapus,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: isIncome ? AppColors.successLight : AppColors.dangerLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isIncome
                      ? Icons.volunteer_activism_rounded
                      : Icons.shopping_bag_outlined,
                  color: isIncome ? AppColors.success : AppColors.danger,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      style: AppTextStyle.body.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${transaction.date} • ${transaction.category}',
                      style: AppTextStyle.bodySmall,
                    ),
                  ],
                ),
              ),
              Text(
                '${isIncome ? '+' : '-'}${_formatRupiah(transaction.amount)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isIncome ? AppColors.success : AppColors.danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          // Tombol Hapus Full-Width
          GestureDetector(
            onTap: onHapus,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.dangerLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_outline_rounded,
                      color: AppColors.danger, size: 16),
                  SizedBox(width: 6),
                  Text('Hapus',
                      style: TextStyle(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatRupiah(double amount) {
    if (amount >= 1000000) {
      final parts = (amount / 1000000).toStringAsFixed(3).split('.');
      return 'Rp ${parts[0]}.${parts[1]}';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(0)}.000';
    }
    return 'Rp ${amount.toStringAsFixed(0)}';
  }
}

class _AddTransactionSheet extends StatefulWidget {
  final VoidCallback onSaved;
  const _AddTransactionSheet({required this.onSaved});

  @override
  State<_AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<_AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  String _type = 'income';
  String _category = 'Donasi';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
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
                const Text('Tambah Transaksi', style: AppTextStyle.h3),
                const SizedBox(height: 20),

                // Type selector
                Row(
                  children: [
                    Expanded(
                      child: _TypeButton(
                        label: 'Pemasukan',
                        icon: Icons.add_circle_outline,
                        isSelected: _type == 'income',
                        color: AppColors.success,
                        onTap: () => setState(() => _type = 'income'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TypeButton(
                        label: 'Pengeluaran',
                        icon: Icons.remove_circle_outline,
                        isSelected: _type == 'expense',
                        color: AppColors.danger,
                        onTap: () => setState(() => _type = 'expense'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Text('KETERANGAN', style: AppTextStyle.label),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleCtrl,
                  decoration:
                      const InputDecoration(hintText: 'Masukkan keterangan'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                const Text('JUMLAH', style: AppTextStyle.label),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(hintText: '0', prefixText: 'Rp '),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                const Text('KATEGORI', style: AppTextStyle.label),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: const InputDecoration(),
                  items: ['Donasi', 'Pembelian', 'Operasional', 'Lainnya']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _category = v!),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  text: 'SIMPAN TRANSAKSI',
                  icon: Icons.check_rounded,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final now = DateTime.now();
                      final bulan = ['','Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
                      final newT = TransactionModel(
                        id: (AppData.transactions.length + 1).toString(),
                        title: _titleCtrl.text.trim(),
                        subtitle: _category,
                        date: '${now.day} ${bulan[now.month]} ${now.year}',
                        amount: double.tryParse(_amountCtrl.text.trim().replaceAll('.', '').replaceAll(',', '')) ?? 0,
                        type: _type == 'income' ? TransactionType.income : TransactionType.expense,
                        category: _category,
                      );
                      AppData.transactions.insert(0, newT);
                      widget.onSaved();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Transaksi berhasil disimpan'),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    }
                  },
                ),
                ],
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.12) : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? color : AppColors.textTertiary,
                size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? color : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
