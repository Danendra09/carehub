import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/shared_widgets.dart';

class InventarisScreen extends StatefulWidget {
  const InventarisScreen({super.key});

  @override
  State<InventarisScreen> createState() => _InventarisScreenState();
}

class _InventarisScreenState extends State<InventarisScreen> {
  bool _autoRestock = false;

  List<InventoryItem> get _lowStock => AppData.inventoryItems
      .where((i) => i.status == StockStatus.menipis)
      .toList();

  int get _totalItems => AppData.inventoryItems.length * 20 + 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: CareHubAppBar()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const Text('PENGELOLAAN LOGISTIK', style: AppTextStyle.label),
                const SizedBox(height: 4),
                const Text(
                  'Inventaris &\nKebutuhan Logistik',
                  style: AppTextStyle.h2,
                ),

                const SizedBox(height: 20),

                // Total items card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'TOTAL ITEM',
                              style: TextStyle(
                                fontSize: 11,
                                letterSpacing: 1.0,
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$_totalItems',
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -1,
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Kategori: Medis & Pangan',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.inventory_2_rounded,
                            color: Colors.white54, size: 40),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Stok menipis summary
                AppCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('STOK MENIPIS', style: AppTextStyle.label),
                          StatusBadge.prioritas(),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _lowStock.length.toString().padLeft(2, '0'),
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Membutuhkan pengadaan segera dalam 48 jam.',
                        style: AppTextStyle.bodySmall,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Estimasi biaya
                const AppCard(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ESTIMASI BIAYA', style: AppTextStyle.label),
                      SizedBox(height: 8),
                      Text(
                        'Rp 4.250.000',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.trending_up_rounded,
                              color: AppColors.success, size: 16),
                          SizedBox(width: 4),
                          Text(
                            '+12% dari bulan lalu',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.success,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                SectionHeader(
                  title: 'Daftar Stok Menipis',
                  actionText: 'Lihat Semua',
                  onAction: () {},
                ),

                const SizedBox(height: 14),

                ..._lowStock.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _InventoryCard(item: item),
                    )),

                const SizedBox(height: 14),

                // All items section
                SectionHeader(
                  title: 'Semua Item',
                  actionText: 'Tambah',
                  onAction: () => _showAddItemSheet(context),
                ),
                const SizedBox(height: 14),

                ...AppData.inventoryItems.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _InventoryListTile(item: item),
                    )),

                const SizedBox(height: 20),

                // Automasi card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.darkCard,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Automasi Pengadaan',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Aktifkan pemesanan otomatis ke distributor pilihan untuk item yang berada di bawah stok minimum.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white60,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () =>
                              setState(() => _autoRestock = !_autoRestock),
                          child: Text(
                            _autoRestock
                                ? 'NONAKTIFKAN'
                                : 'AKTIFKAN SEKARANG',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemSheet(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
      ),
    );
  }

  void _showAddItemSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddItemSheet(),
    );
  }
}

class _InventoryCard extends StatelessWidget {
  final InventoryItem item;

  const _InventoryCard({required this.item});

  IconData _categoryIcon() {
    switch (item.category) {
      case 'Obat-obatan':
        return Icons.medical_services_rounded;
      case 'Kebersihan':
        return Icons.clean_hands_rounded;
      case 'Pangan':
        return Icons.restaurant_rounded;
      default:
        return Icons.inventory_2_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_categoryIcon(), color: AppColors.primary, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AppTextStyle.body
                      .copyWith(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                const SizedBox(height: 3),
                Text('Kategori: ${item.category}',
                    style: AppTextStyle.bodySmall),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '${item.currentStock.toString().padLeft(2, '0')} ${item.unit}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.danger,
                      ),
                    ),
                    const Spacer(),
                    StatusBadge.perluRestock(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InventoryListTile extends StatelessWidget {
  final InventoryItem item;

  const _InventoryListTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final isLow = item.status == StockStatus.menipis;
    final progress = (item.currentStock / (item.minStock * 2)).clamp(0.0, 1.0);

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: AppTextStyle.body
                            .copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${item.currentStock}/${item.minStock * 2} ${item.unit}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isLow ? AppColors.danger : AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        isLow ? AppColors.danger : AppColors.success),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 6),
                Text(item.category, style: AppTextStyle.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 10),
          isLow ? StatusBadge.perluRestock() : StatusBadge.aman(),
        ],
      ),
    );
  }
}

class _AddItemSheet extends StatefulWidget {
  const _AddItemSheet();

  @override
  State<_AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<_AddItemSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _minStockCtrl = TextEditingController();
  String _category = 'Obat-obatan';
  String _unit = 'Pcs';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
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
                const Text('Tambah Item', style: AppTextStyle.h3),
                const SizedBox(height: 20),
                const Text('NAMA ITEM', style: AppTextStyle.label),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameCtrl,
                  decoration:
                      const InputDecoration(hintText: 'Nama item'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('KATEGORI', style: AppTextStyle.label),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: _category,
                            decoration: const InputDecoration(),
                            items: ['Obat-obatan', 'Kebersihan', 'Pangan']
                                .map((c) => DropdownMenuItem(
                                    value: c, child: Text(c)))
                                .toList(),
                            onChanged: (v) => setState(() => _category = v!),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('SATUAN', style: AppTextStyle.label),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: _unit,
                            decoration: const InputDecoration(),
                            items: ['Pcs', 'Box', 'Kg', 'Liter', 'Botol', 'Strip']
                                .map((u) => DropdownMenuItem(
                                    value: u, child: Text(u)))
                                .toList(),
                            onChanged: (v) => setState(() => _unit = v!),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('STOK SAAT INI', style: AppTextStyle.label),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _stockCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(hintText: '0'),
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Wajib diisi' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('STOK MINIMUM', style: AppTextStyle.label),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _minStockCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(hintText: '0'),
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Wajib diisi' : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  text: 'SIMPAN ITEM',
                  icon: Icons.check_rounded,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
