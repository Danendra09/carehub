import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/shared_widgets.dart';
import '../../services/inventaris_service.dart';
import '../../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InventarisScreen extends StatefulWidget {
  const InventarisScreen({super.key});

  @override
  State<InventarisScreen> createState() => _InventarisScreenState();
}

class _InventarisScreenState extends State<InventarisScreen> {
  List<InventoryItem> _items = [];
  bool _isLoading = true;
  bool _canCreate = false;
  bool _canEdit = false;
  bool _canDelete = false;

  @override
  void initState() {
    super.initState();
    _loadPermissions();
    _fetchInventaris();
  }

  Future<void> _loadPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('user_role') ?? '';
    final isAdmin = role.toLowerCase() == 'admin' || role.toLowerCase() == 'superadmin';
    
    final create = await AuthService.hasPermission('create_inventori');
    final edit = await AuthService.hasPermission('edit_inventori');
    final delete = await AuthService.hasPermission('delete_inventori');
    
    if (mounted) {
      setState(() {
        _canCreate = isAdmin || create;
        _canEdit = isAdmin || edit;
        _canDelete = isAdmin || delete;
      });
    }
  }

  Future<void> _fetchInventaris() async {
    setState(() => _isLoading = true);
    try {
      final data = await InventarisService.getInventaris();
      if (mounted) setState(() => _items = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Gagal memuat: $e'),
              backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<InventoryItem> get _lowStock =>
      _items.where((i) => i.status == StockStatus.menipis).toList();

  int get _totalItems => _items.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchInventaris,
              child: CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(
                    child: CareHubAppBar(),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const Text('PENGELOLAAN LOGISTIK',
                            style: AppTextStyle.label),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('STOK MENIPIS',
                                      style: AppTextStyle.label),
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

                        const SizedBox(height: 24),

                        SectionHeader(
                          title: 'Daftar Stok Menipis',
                        ),

                        const SizedBox(height: 14),

                        if (_lowStock.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 20),
                            child: Center(
                              child: Text('Tidak ada stok menipis.',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 14)),
                            ),
                          )
                        else
                          ..._lowStock.map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _InventoryCard(
                                  item: item,
                                  canEdit: _canEdit,
                                  canDelete: _canDelete,
                                  onEdit: () => _showAddItemSheet(context, editData: item),
                                  onHapus: () => _hapusItem(context, item),
                                ),
                              )),

                        const SizedBox(height: 14),

                        // All items section
                        SectionHeader(
                          title: 'Semua Item',
                        ),
                        const SizedBox(height: 14),

                        if (_items.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 40),
                            child: EmptyStateWidget(
                              icon: Icons.inventory_2_rounded,
                              title: 'Belum Ada Inventaris',
                              subtitle:
                                  'Belum ada data barang inventaris. Silakan tap tombol Tambah di bawah.',
                            ),
                          )
                        else
                          ..._items.map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _InventoryListTile(
                                  item: item,
                                  canEdit: _canEdit,
                                  canDelete: _canDelete,
                                  onEdit: () => _showAddItemSheet(context,
                                      editData: item),
                                  onHapus: () => _hapusItem(context, item),
                                ),
                              )),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: _canCreate ? FloatingActionButton.extended(
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
      ) : null,
    );
  }

  void _showAddItemSheet(BuildContext context, {InventoryItem? editData}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddItemSheet(
        editData: editData,
        onSaved: () => _fetchInventaris(),
      ),
    );
  }

  void _hapusItem(BuildContext ctx, InventoryItem item) {
    showDeleteConfirmDialog(
      context: ctx,
      title: 'Hapus Item',
      message: 'Hapus "${item.name}" dari inventaris?',
      onConfirm: () async {
        final success = await InventarisService.deleteInventaris(item.id);
        if (success) {
          _fetchInventaris();
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${item.name} berhasil dihapus'), backgroundColor: AppColors.danger, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
        } else {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menghapus item'), backgroundColor: AppColors.danger));
        }
      },
    );
  }
}

class _InventoryCard extends StatelessWidget {
  final InventoryItem item;
  final VoidCallback onEdit;
  final VoidCallback onHapus;
  final bool canEdit;
  final bool canDelete;

  const _InventoryCard({
    required this.item,
    required this.onEdit,
    required this.onHapus,
    required this.canEdit,
    required this.canDelete,
  });

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
  final bool canEdit;
  final bool canDelete;

  const _InventoryListTile({
    required this.item,
    required this.onEdit,
    required this.onHapus,
    required this.canEdit,
    required this.canDelete,
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
          if (canEdit || canDelete) ...[
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 12),
            Row(
              children: [
                // Edit button
                if (canEdit)
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
                if (canEdit && canDelete) const SizedBox(width: 10),
                // Hapus button
                if (canDelete)
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
                            Icon(Icons.delete_rounded,
                                color: AppColors.danger, size: 16),
                            SizedBox(width: 6),
                            Text('Hapus',
                                style: TextStyle(
                                  color: AppColors.danger,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ] else ...[
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                'HANYA BACA (READ ONLY)',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textTertiary,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
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
  late String _category;
  late String _kondisi;
  File? _gambar;

  bool get _isEdit => widget.editData != null;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final d = widget.editData;
    _nameCtrl = TextEditingController(text: d?.name ?? '');
    _stockCtrl = TextEditingController(text: d != null ? '${d.currentStock}' : '');
    _category = d?.category ?? 'Sembako';
    _kondisi = d?.kondisi ?? 'Baik';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() => _gambar = File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Align(
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
                    Text(_isEdit ? 'Edit Barang' : 'Tambah Barang', style: AppTextStyle.h3),
                    const SizedBox(height: 20),

                    // ── Nama Barang ─────────────────────────────────────
                    const Text('NAMA BARANG', style: AppTextStyle.label),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(hintText: 'Contoh: Beras Premium, Sabun Mandi...'),
                      validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),

                    // ── Jumlah Stok ─────────────────────────────────────
                    const Text('JUMLAH STOK', style: AppTextStyle.label),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _stockCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: '0'),
                      validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),

                    // ── Kondisi Barang ───────────────────────────────────
                    const Text('KONDISI BARANG', style: AppTextStyle.label),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _kondisi,
                      decoration: const InputDecoration(),
                      items: ['Baik', 'Cukup Baik', 'Rusak Ringan', 'Rusak Berat']
                          .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                          .toList(),
                      onChanged: (v) => setState(() => _kondisi = v!),
                    ),
                    const SizedBox(height: 16),

                    // ── Kategori ─────────────────────────────────────────
                    const Text('KATEGORI', style: AppTextStyle.label),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _category,
                      decoration: const InputDecoration(),
                      items: ['Sembako', 'Kebutuhan Mandi', 'Pakaian', 'Pendidikan', 'Kesehatan', 'Lainnya']
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(() => _category = v!),
                    ),
                    const SizedBox(height: 16),

                    // ── Foto Barang ──────────────────────────────────────
                    const Text('FOTO BARANG (OPSIONAL)', style: AppTextStyle.label),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: double.infinity,
                        height: _gambar != null ? 180 : 110,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.border,
                            width: 1.5,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: _gambar != null
                            ? Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Image.file(
                                      _gambar!,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () => setState(() => _gambar = null),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate_outlined,
                                      size: 36, color: AppColors.textSecondary),
                                  const SizedBox(height: 8),
                                  Text('Klik untuk upload foto barang',
                                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text('JPG, PNG • Opsional',
                                      style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Tombol Simpan ────────────────────────────────────
                    PrimaryButton(
                      text: _isEdit ? 'SIMPAN PERUBAHAN' : 'SIMPAN BARANG',
                      icon: Icons.check_rounded,
                      isLoading: _isLoading,
                      onPressed: _isLoading ? null : () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() => _isLoading = true);
                          final stok = int.tryParse(_stockCtrl.text.trim()) ?? 0;
                          final data = {
                            'nama_barang': _nameCtrl.text.trim(),
                            'stok': stok,
                            'kondisi': _kondisi,
                            'kategori': _category,
                          };
                          bool success = false;
                          if (_isEdit) {
                            success = await InventarisService.updateInventaris(
                              widget.editData!.id,
                              data,
                              gambar: _gambar,
                            );
                          } else {
                            success = await InventarisService.createInventaris(
                              data,
                              gambar: _gambar,
                            );
                          }
                          if (mounted) {
                            setState(() => _isLoading = false);
                            if (success) {
                              widget.onSaved();
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(_isEdit
                                      ? '${_nameCtrl.text} berhasil diperbarui!'
                                      : '${_nameCtrl.text} berhasil ditambahkan!'),
                                  backgroundColor: AppColors.success,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Gagal menyimpan ke server!'),
                                  backgroundColor: AppColors.danger,
                                ),
                              );
                            }
                          }
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
