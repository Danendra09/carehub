import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/shared_widgets.dart';

class AnakScreen extends StatefulWidget {
  const AnakScreen({super.key});

  @override
  State<AnakScreen> createState() => _AnakScreenState();
}

class _AnakScreenState extends State<AnakScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  List<ChildModel> get _filtered => AppData.children
      .where((c) =>
          c.name.toLowerCase().contains(_query.toLowerCase()) ||
          c.tempatTglLahir.toLowerCase().contains(_query.toLowerCase()) ||
          c.riwayatKesehatan.toLowerCase().contains(_query.toLowerCase()))
      .toList();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showAddDialog(BuildContext context, {ChildModel? editData}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddChildSheet(
        editData: editData,
        onSaved: () => setState(() {}),
      ),
    );
  }

  void _hapusAnak(BuildContext ctx, ChildModel child) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Data Anak'),
        content: Text(
            'Apakah Anda yakin ingin menghapus data ${child.name} dari database CareHub?'),
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
              setState(() =>
                  AppData.children.removeWhere((c) => c.id == child.id));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(
                  content: Text('Data ${child.name} berhasil dihapus'),
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

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
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
                const Text('MANAJEMEN DATA', style: AppTextStyle.label),
                const SizedBox(height: 4),
                const Text('Daftar Anak Asuh', style: AppTextStyle.h2),

                const SizedBox(height: 20),

                // Search + add row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _searchCtrl,
                        onChanged: (v) => setState(() => _query = v),
                        style: AppTextStyle.body,
                        decoration: const InputDecoration(
                          hintText: 'Cari nama anak...',
                          hintStyle: TextStyle(
                              color: AppColors.textTertiary, fontSize: 14),
                          prefixIcon: Icon(Icons.search_rounded,
                              color: AppColors.textTertiary, size: 20),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 13),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => _showAddDialog(context),
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_rounded,
                                color: Colors.white, size: 20),
                            SizedBox(width: 6),
                            Text(
                              'Tambah',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Stats bar
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.people_alt_rounded,
                          color: AppColors.primary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Total: ${list.length} Anak Terdaftar',
                        style: AppTextStyle.body
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Child list
                if (list.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          const Icon(Icons.search_off_rounded,
                              size: 48, color: AppColors.textTertiary),
                          const SizedBox(height: 12),
                          const Text('Data tidak ditemukan',
                              style: AppTextStyle.bodySmall),
                          const SizedBox(height: 16),
                          if (_query.isEmpty)
                            ElevatedButton.icon(
                              onPressed: () => _showAddDialog(context),
                              icon: const Icon(Icons.add_rounded, size: 18),
                              label: const Text('Tambah Anak Pertama'),
                              style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(200, 44)),
                            ),
                        ],
                      ),
                    ),
                  )
                else
                  ...list.map((child) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ChildCard(
                          child: child,
                          onEdit: () =>
                              _showAddDialog(context, editData: child),
                          onHapus: () => _hapusAnak(context, child),
                        ),
                      )),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Child Card ───────────────────────────────────────────────────────────────
class _ChildCard extends StatelessWidget {
  final ChildModel child;
  final VoidCallback onEdit;
  final VoidCallback onHapus;

  const _ChildCard({
    required this.child,
    required this.onEdit,
    required this.onHapus,
  });

  StatusBadge _statusBadge() {
    switch (child.status) {
      case ChildStatus.sehat:
        return StatusBadge.sehat();
      case ChildStatus.pemulihan:
        return StatusBadge.pemulihan();
      case ChildStatus.perhatian:
        return StatusBadge.perhatian();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
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
                    Text(
                      child.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          child.gender == Gender.male
                              ? Icons.male_rounded
                              : Icons.female_rounded,
                          size: 15,
                          color: child.gender == Gender.male
                              ? AppColors.info
                              : AppColors.danger,
                        ),
                        const SizedBox(width: 4),
                        Text('${child.age} Tahun • ${child.grade}',
                            style: AppTextStyle.bodySmall),
                      ],
                    ),
                    if (child.tempatTglLahir.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(child.tempatTglLahir,
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textTertiary)),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _statusBadge(),
                  const SizedBox(height: 6),
                  StatusBadge(
                    label: child.riwayatKesehatan,
                    color: AppColors.textSecondary,
                    bgColor: AppColors.border,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 14),
          // Tombol aksi
          Row(
            children: [
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
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            )),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
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

// ─── Action Button ────────────────────────────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}

// ─── Add/Edit Child Sheet ─────────────────────────────────────────────────────
class _AddChildSheet extends StatefulWidget {
  final ChildModel? editData;
  final VoidCallback onSaved;

  const _AddChildSheet({this.editData, required this.onSaved});

  @override
  State<_AddChildSheet> createState() => _AddChildSheetState();
}

class _AddChildSheetState extends State<_AddChildSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _ageCtrl;
  late final TextEditingController _tempatCtrl;
  late final TextEditingController _riwayatCtrl;
  late String _selectedGender;
  late String _selectedStatus;
  late String _selectedGrade;

  bool get _isEdit => widget.editData != null;

  @override
  void initState() {
    super.initState();
    final d = widget.editData;
    _nameCtrl = TextEditingController(text: d?.name ?? '');
    _ageCtrl = TextEditingController(text: d != null ? '${d.age}' : '');
    _tempatCtrl = TextEditingController(text: d?.tempatTglLahir ?? '');
    _riwayatCtrl =
        TextEditingController(text: d?.riwayatKesehatan ?? 'Sehat');
    _selectedGender =
        d?.gender == Gender.female ? 'female' : 'male';
    _selectedStatus = d?.status.name ?? 'sehat';
    _selectedGrade = d?.grade ?? 'Kelas 1 SD';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _tempatCtrl.dispose();
    _riwayatCtrl.dispose();
    super.dispose();
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) return;

    final newChild = ChildModel(
      id: _isEdit
          ? widget.editData!.id
          : (AppData.children.length + 1).toString(),
      name: _nameCtrl.text.trim(),
      age: int.tryParse(_ageCtrl.text.trim()) ?? 0,
      gender:
          _selectedGender == 'female' ? Gender.female : Gender.male,
      status: ChildStatus.values.firstWhere((s) => s.name == _selectedStatus,
          orElse: () => ChildStatus.sehat),
      grade: _selectedGrade,
      avatarInitials: _nameCtrl.text.trim().split(' ').take(2).map((w) => w[0].toUpperCase()).join(),
      tempatTglLahir: _tempatCtrl.text.trim(),
      riwayatKesehatan: _riwayatCtrl.text.trim().isEmpty
          ? 'Sehat'
          : _riwayatCtrl.text.trim(),
    );

    if (_isEdit) {
      final idx = AppData.children
          .indexWhere((c) => c.id == widget.editData!.id);
      if (idx != -1) AppData.children[idx] = newChild;
    } else {
      AppData.children.add(newChild);
    }

    widget.onSaved();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEdit
            ? 'Data ${newChild.name} berhasil diperbarui!'
            : 'Data anak baru berhasil disimpan!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
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
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.88,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scrollCtrl) => SingleChildScrollView(
            controller: scrollCtrl,
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
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

                  Text(_isEdit ? 'Edit Data Anak' : 'Tambah Anak Asuh',
                      style: AppTextStyle.h3),
                  const SizedBox(height: 20),

                  // Nama
                  const _FieldLabel('Nama Lengkap *'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                        hintText: 'Masukkan nama anak'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),

                  // Usia + Gender
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _FieldLabel('Usia *'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _ageCtrl,
                              keyboardType: TextInputType.number,
                              decoration:
                                  const InputDecoration(hintText: '0'),
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
                            const _FieldLabel('Jenis Kelamin *'),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _selectedGender,
                              decoration: const InputDecoration(),
                              items: const [
                                DropdownMenuItem(
                                    value: 'male',
                                    child: Text('Laki-laki')),
                                DropdownMenuItem(
                                    value: 'female',
                                    child: Text('Perempuan')),
                              ],
                              onChanged: (v) =>
                                  setState(() => _selectedGender = v!),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tempat/Tgl Lahir
                  const _FieldLabel('Tempat / Tanggal Lahir *'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _tempatCtrl,
                    decoration: const InputDecoration(
                        hintText: 'Purwokerto, 12 Mei 2012'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),

                  // Status + Kelas
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _FieldLabel('Status'),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _selectedStatus,
                              decoration: const InputDecoration(),
                              items: const [
                                DropdownMenuItem(
                                    value: 'sehat', child: Text('Sehat')),
                                DropdownMenuItem(
                                    value: 'pemulihan',
                                    child: Text('Pemulihan')),
                                DropdownMenuItem(
                                    value: 'perhatian',
                                    child: Text('Perhatian')),
                              ],
                              onChanged: (v) =>
                                  setState(() => _selectedStatus = v!),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _FieldLabel('Kelas'),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _selectedGrade,
                              decoration: const InputDecoration(),
                              items: [
                                'Kelas 1 SD','Kelas 2 SD','Kelas 3 SD',
                                'Kelas 4 SD','Kelas 5 SD','Kelas 6 SD',
                                'Kelas 7 SMP','Kelas 8 SMP','Kelas 9 SMP',
                              ]
                                  .map((g) => DropdownMenuItem(
                                      value: g,
                                      child: Text(g,
                                          style: const TextStyle(
                                              fontSize: 11))))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedGrade = v!),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Riwayat Kesehatan
                  const _FieldLabel('Riwayat Kesehatan'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _riwayatCtrl,
                    decoration: const InputDecoration(
                        hintText: 'Sehat / Alergi debu / dll...'),
                  ),
                  const SizedBox(height: 24),

                  PrimaryButton(
                    text: _isEdit ? 'SIMPAN PERUBAHAN' : 'SIMPAN DATA',
                    icon: Icons.check_rounded,
                    onPressed: _simpan,
                  ),
                  const SizedBox(height: 16),
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

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) =>
      Text(text.toUpperCase(), style: AppTextStyle.label);
}
