import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/shared_widgets.dart';
import '../../services/anak_service.dart';
import '../../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ManajemenAnakScreen extends StatefulWidget {
  const ManajemenAnakScreen({super.key});

  @override
  State<ManajemenAnakScreen> createState() => _ManajemenAnakScreenState();
}

class _ManajemenAnakScreenState extends State<ManajemenAnakScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  List<ChildModel> _anakList = [];
  bool _isLoading = true;
  bool _canCreate = false;
  bool _canEdit = false;
  bool _canDelete = false;

  @override
  void initState() {
    super.initState();
    _loadPermissions();
    _fetchAnak();
  }

  Future<void> _loadPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('user_role') ?? '';
    final isAdmin = role.toLowerCase() == 'admin' || role.toLowerCase() == 'superadmin';
    
    final create = await AuthService.hasPermission('create_anak');
    final edit = await AuthService.hasPermission('edit_anak');
    final delete = await AuthService.hasPermission('delete_anak');
    
    if (mounted) {
      setState(() {
        _canCreate = isAdmin || create;
        _canEdit = isAdmin || edit;
        _canDelete = isAdmin || delete;
      });
    }
  }

  Future<void> _fetchAnak() async {
    setState(() => _isLoading = true);
    try {
      final data = await AnakService.getAnak();
      if (mounted) setState(() => _anakList = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e'), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<ChildModel> get _filtered => _anakList
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
        onSaved: () => _fetchAnak(),
      ),
    );
  }

  void _hapusAnak(BuildContext ctx, ChildModel child) {
    showDeleteConfirmDialog(
      context: ctx,
      title: 'Hapus Data Anak',
      message: 'Apakah Anda yakin ingin menghapus data ${child.name} dari database CareHub?',
      onConfirm: () async {
        setState(() => _isLoading = true);
        final success = await AnakService.deleteAnak(child.id);
        if (success) {
          _fetchAnak();
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Data ${child.name} berhasil dihapus'), backgroundColor: AppColors.danger, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
        } else {
          setState(() => _isLoading = false);
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menghapus data'), backgroundColor: AppColors.danger));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CareHubAppBar(),
      resizeToAvoidBottomInset: false,
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : RefreshIndicator(
            onRefresh: _fetchAnak,
            child: CustomScrollView(
              slivers: [
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
                    if (_canCreate) ...[
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
                          canEdit: _canEdit,
                          canDelete: _canDelete,
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
    ));
  }
}

// ─── Child Card ───────────────────────────────────────────────────────────────
class _ChildCard extends StatelessWidget {
  final ChildModel child;
  final VoidCallback onEdit;
  final VoidCallback onHapus;
  final bool canEdit;
  final bool canDelete;

  const _ChildCard({
    required this.child,
    required this.onEdit,
    required this.onHapus,
    required this.canEdit,
    required this.canDelete,
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
                          fontWeight: FontWeight.w800, // Dipertebal sedikit
                          fontSize: 20, // Diperbesar dari 16
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
                            style: const TextStyle(
                                fontSize: 14, // Diperbesar
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary)),
                      ],
                    ),
                    if (child.tempatTglLahir.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(child.tempatTglLahir,
                          style: const TextStyle(
                              fontSize: 14, // Diperbesar dari 12
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
          if (canEdit || canDelete) ...[
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 14),
            // Tombol aksi
            Row(
              children: [
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
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (canEdit && canDelete) const SizedBox(width: 10),
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
  late String _selectedGrade;
  final List<String> _pendidikanOptions = ['Belum Sekolah', 'TK', 'SD', 'SMP', 'SMA', 'Perguruan Tinggi', 'Lainnya'];

  bool get _isEdit => widget.editData != null;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final d = widget.editData;
    _nameCtrl = TextEditingController(text: d?.name ?? '');
    _ageCtrl = TextEditingController(text: d != null ? '${d.age}' : '');
    _tempatCtrl = TextEditingController(text: d?.tempatTglLahir ?? '');
    _riwayatCtrl = TextEditingController(text: d?.riwayatKesehatan ?? 'Sehat');
    _selectedGender = d?.gender == Gender.female ? 'female' : 'male';
    
    String existingGrade = d?.grade ?? '';
    if (existingGrade.isNotEmpty && !_pendidikanOptions.contains(existingGrade)) {
      _pendidikanOptions.add(existingGrade);
    }
    _selectedGrade = existingGrade.isEmpty ? 'Belum Sekolah' : existingGrade;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _tempatCtrl.dispose();
    _riwayatCtrl.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final data = {
      'nama_lengkap': _nameCtrl.text.trim(),
      'usia': int.tryParse(_ageCtrl.text.trim()) ?? 0,
      'jenis_kelamin': _selectedGender == 'female' ? 'Perempuan' : 'Laki-laki',
      'tempat_tgl_lahir': _tempatCtrl.text.trim(),
      'info_pendidikan': _selectedGrade,
      'riwayat_kesehatan': _riwayatCtrl.text.trim().isEmpty ? 'Sehat' : _riwayatCtrl.text.trim(),
    };

    bool success = false;
    if (_isEdit) {
      success = await AnakService.updateAnak(widget.editData!.id, data);
    } else {
      success = await AnakService.createAnak(data);
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        widget.onSaved();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEdit
                ? 'Data ${_nameCtrl.text} berhasil diperbarui!'
                : 'Data anak baru berhasil disimpan!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan data ke server!'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
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
                              initialValue: _selectedGender,
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

                  // Kelas (Info Pendidikan)
                  const _FieldLabel('Kelas / Info Pendidikan *'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedGrade,
                    decoration: const InputDecoration(
                      hintText: 'Pilih jenjang pendidikan',
                    ),
                    items: _pendidikanOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: AppTextStyle.body),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedGrade = newValue;
                        });
                      }
                    },
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
                    onPressed: _isLoading ? null : _simpan,
                    isLoading: _isLoading,
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
