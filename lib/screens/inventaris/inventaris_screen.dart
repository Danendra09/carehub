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
      resizeToAvoidBottomInset: false,
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
                        color: AppColors.primary.withValues(alpha: 0.3),
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
                          color: Colors.white.withValues(alpha: 0.12),
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
                      child: _InventoryListTile(
                        item: item,
                        onEdit: () => _showAddItemSheet(context, editData: item),
                        onHapus: () => _hapusItem(context, item),
                      ),
                    )),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_inventaris',
        onPressed: () => _showAddItemSheet(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
        label: const Text(
          'Tambah',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  void _showAddItemSheet(BuildContext context, {InventoryItem? editData}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddItemSheet(
        editData: editData,
        onSaved: () => setState(() {}),
      ),
    );
  }

  void _hapusItem(BuildContext ctx, InventoryItem item) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Item'),
        content: Text('Hapus "${item.name}" dari inventaris?'),
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
              setState(() => AppData.inventoryItems.removeWhere((x) => x.id == item.id));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(
                  content: Text('${item.name} berhasil dihapus'),
                  backgroundColor: AppColors.danger,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
  final VoidCallback onEdit;
  final VoidCallback onHapus;

  const _InventoryListTile({
    required this.item,
    required this.onEdit,
    required this.onHapus,
  });

  @override
  Widget build(BuildContext context) {
    final isLow = item.status == StockStatus.menipis;
    final progress = (item.currentStock / (item.minStock * 2)).clamp(0.0, 1.0);

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          Row(
            children: [
              // Edit button
              Expanded(
                child: GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit_rounded,
                            color: AppColors.primary, size: 16),
                        SizedBox(width: 6),
                        Text('Edit',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            )),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Hapus button
              Expanded(
                child: GestureDetector(
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
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddItemSheet extends StatefulWidget {
  final InventoryItem? editData;
  final VoidCallback onSaved;
  const _AddItemSheet({this.editData, required this.onSaved});

  @override
  State<_AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<_AddItemSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _stockCtrl;
  late final TextEditingController _minStockCtrl;
  late String _category;
  late String _unit;

  bool get _isEdit => widget.editData != null;

  @override
  void initState() {
    super.initState();
    final d = widget.editData;
    _nameCtrl = TextEditingController(text: d?.name ?? '');
    _stockCtrl = TextEditingController(text: d != null ? '${d.currentStock}' : '');
    _minStockCtrl = TextEditingController(text: d != null ? '${d.minStock}' : '');
    _category = d?.category ?? 'Obat-obatan';
    _unit = d?.unit ?? 'Pcs';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _stockCtrl.dispose();
    _minStockCtrl.dispose();
    super.dispose();
  }

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
                  Text(_isEdit ? 'Edit Item' : 'Tambah Item', style: AppTextStyle.h3),
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
                    text: _isEdit ? 'SIMPAN PERUBAHAN' : 'SIMPAN ITEM',
                    icon: Icons.check_rounded,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final stok = int.tryParse(_stockCtrl.text.trim()) ?? 0;
                        final minStok = int.tryParse(_minStockCtrl.text.trim()) ?? 0;
                        final newItem = InventoryItem(
                          id: _isEdit
                              ? widget.editData!.id
                              : (AppData.inventoryItems.length + 1).toString(),
                          name: _nameCtrl.text.trim(),
                          category: _category,
                          currentStock: stok,
                          minStock: minStok,
                          unit: _unit,
                          status: stok <= minStok
                              ? StockStatus.menipis
                              : StockStatus.aman,
                        );
                        if (_isEdit) {
                          final idx = AppData.inventoryItems
                              .indexWhere((x) => x.id == widget.editData!.id);
                          if (idx != -1) AppData.inventoryItems[idx] = newItem;
                        } else {
                          AppData.inventoryItems.add(newItem);
                        }
                        widget.onSaved();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_isEdit
                                ? '${newItem.name} berhasil diperbarui!'
                                : '${newItem.name} berhasil ditambahkan!'),
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
