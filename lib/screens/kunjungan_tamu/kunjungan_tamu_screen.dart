import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/shared_widgets.dart';
import '../../services/kunjungan_tamu_service.dart';
import '../../utils/api_endpoints.dart';
import '../../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KunjunganTamuScreen extends StatefulWidget {
  const KunjunganTamuScreen({super.key});

  @override
  State<KunjunganTamuScreen> createState() => _KunjunganTamuScreenState();
}

class _KunjunganTamuScreenState extends State<KunjunganTamuScreen> {
  List<KunjunganTamuModel> _items = [];
  bool _isLoading = true;
  bool _canCreate = false;
  bool _canEdit = false;
  bool _canDelete = false;

  @override
  void initState() {
    super.initState();
    _loadPermissions();
    _fetchData();
  }

  Future<void> _loadPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('user_role') ?? '';
    final isAdmin = role.toLowerCase() == 'admin' || role.toLowerCase() == 'superadmin';
    
    final create = await AuthService.hasPermission('create_kunjungan');
    final edit = await AuthService.hasPermission('edit_kunjungan');
    final delete = await AuthService.hasPermission('delete_kunjungan');
    
    if (mounted) {
      setState(() {
        _canCreate = isAdmin || create;
        _canEdit = isAdmin || edit;
        _canDelete = isAdmin || delete;
      });
    }
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final data = await KunjunganTamuService.getKunjunganTamu();
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

  void _showAddEditSheet({KunjunganTamuModel? editData}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddEditKunjunganSheet(
        editData: editData,
        onSaved: () => _fetchData(),
      ),
    );
  }

  void _deleteItem(KunjunganTamuModel item) {
    showDeleteConfirmDialog(
      context: context,
      title: 'Hapus Kunjungan',
      message: 'Hapus kunjungan "${item.judulKegiatan}"?',
      onConfirm: () async {
        final success = await KunjunganTamuService.deleteKunjunganTamu(item.id);
        if (success) {
          _fetchData();
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data berhasil dihapus'), backgroundColor: AppColors.danger));
        } else {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menghapus data'), backgroundColor: AppColors.danger));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CareHubAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchData,
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const Text('MANAJEMEN KUNJUNGAN',
                            style: AppTextStyle.label),
                        const SizedBox(height: 4),
                        const Text('Daftar Kunjungan Tamu Panti',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 24),
                        if (_items.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 40),
                            child: EmptyStateWidget(
                              icon: Icons.groups_rounded,
                              title: 'Belum Ada Kunjungan',
                              subtitle:
                                  'Belum ada data kunjungan tamu panti. Silakan tap tombol Tambah di bawah.',
                            ),
                          )
                        else
                          ..._items.map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _KunjunganCard(
                                  item: item,
                                  canEdit: _canEdit,
                                  canDelete: _canDelete,
                                  onEdit: () =>
                                      _showAddEditSheet(editData: item),
                                  onDelete: () => _deleteItem(item),
                                ),
                              )),
                      ]),
                    ),
                  )
                ],
              ),
            ),
      floatingActionButton: _canCreate ? FloatingActionButton.extended(
        heroTag: 'fab_kunjungan',
        onPressed: () => _showAddEditSheet(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
        label: const Text('Tambah',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ) : null,
    );
  }
}

class _KunjunganCard extends StatelessWidget {
  final KunjunganTamuModel item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool canEdit;
  final bool canDelete;

  const _KunjunganCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
    required this.canEdit,
    required this.canDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar (jika ada)
              if (item.fotoUrl != null)
                Container(
                  width: 60,
                  height: 60,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(item.fotoUrl!),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                Container(
                  width: 60,
                  height: 60,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.people_alt_rounded,
                      color: AppColors.primary),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.judulKegiatan,
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.person_rounded,
                            size: 16, color: Colors.black54),
                        const SizedBox(width: 6),
                        Expanded(
                            child: Text(item.namaTamu,
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black87),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            size: 16, color: Colors.black54),
                        const SizedBox(width: 6),
                        Text(item.tanggalPelaksanaan,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black87)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.deskripsiLaporan,
            style: const TextStyle(
                fontSize: 14, color: Colors.black87, height: 1.4),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          if (canEdit || canDelete) ...[
            const Divider(height: 1),
            const SizedBox(height: 12),
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
                            borderRadius: BorderRadius.circular(10)),
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
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (canEdit && canDelete) const SizedBox(width: 10),
                if (canDelete)
                  Expanded(
                    child: GestureDetector(
                      onTap: onDelete,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                            color: AppColors.dangerLight,
                            borderRadius: BorderRadius.circular(10)),
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
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ] else ...[
            const Divider(height: 1),
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

class _AddEditKunjunganSheet extends StatefulWidget {
  final KunjunganTamuModel? editData;
  final VoidCallback onSaved;

  const _AddEditKunjunganSheet({this.editData, required this.onSaved});

  @override
  State<_AddEditKunjunganSheet> createState() => _AddEditKunjunganSheetState();
}

class _AddEditKunjunganSheetState extends State<_AddEditKunjunganSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _judulCtrl;
  late TextEditingController _tamuCtrl;
  late TextEditingController _poinCtrl;
  late TextEditingController _laporanCtrl;

  DateTime? _tanggal;
  File? _imageFile;
  bool _isLoading = false;
  bool _isGeneratingAI = false;

  bool get _isEdit => widget.editData != null;

  @override
  void initState() {
    super.initState();
    final d = widget.editData;
    _judulCtrl = TextEditingController(text: d?.judulKegiatan ?? '');
    _tamuCtrl = TextEditingController(text: d?.namaTamu ?? '');
    _laporanCtrl = TextEditingController(text: d?.deskripsiLaporan ?? '');
    _poinCtrl = TextEditingController();

    if (d?.tanggalPelaksanaan != null) {
      try {
        _tanggal = DateTime.parse(d!.tanggalPelaksanaan);
      } catch (e) {
        _tanggal = DateTime.now();
      }
    } else {
      _tanggal = DateTime.now();
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _generateAiDescription() async {
    final judul = _judulCtrl.text.trim();
    final tamu = _tamuCtrl.text.trim();

    if (judul.isEmpty || tamu.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Isi Judul Kegiatan dan Nama Tamu terlebih dahulu')));
      return;
    }

    final prompt = 'Kegiatan $judul bersama $tamu di panti asuhan';

    setState(() => _isGeneratingAI = true);
    final result = await KunjunganTamuService.generateAiDescription(prompt);
    if (mounted) {
      setState(() => _isGeneratingAI = false);
      if (result != null) {
        _laporanCtrl.text = result;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Berhasil generate narasi AI'),
            backgroundColor: AppColors.success));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Gagal generate AI'),
            backgroundColor: AppColors.danger));
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_tanggal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih tanggal pelaksanaan')));
      return;
    }

    setState(() => _isLoading = true);

    final data = {
      'judul_kegiatan': _judulCtrl.text.trim(),
      'nama_tamu': _tamuCtrl.text.trim(),
      'tanggal_pelaksanaan': DateFormat('yyyy-MM-dd').format(_tanggal!),
      'deskripsi_laporan': _laporanCtrl.text.trim(),
    };

    bool success;
    if (_isEdit) {
      success = await KunjunganTamuService.updateKunjunganTamu(
          id: widget.editData!.id, data: data, imageFile: _imageFile);
    } else {
      success = await KunjunganTamuService.createKunjunganTamu(
          data: data, imageFile: _imageFile);
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        widget.onSaved();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(_isEdit ? 'Data diperbarui' : 'Data ditambahkan'),
              backgroundColor: AppColors.success),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Gagal menyimpan data'),
              backgroundColor: AppColors.danger),
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
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24).copyWith(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24),
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
                            borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
                              size: 20, color: AppColors.textPrimary),
                          padding: const EdgeInsets.only(right: 12),
                          constraints: const BoxConstraints(),
                          splashRadius: 24,
                        ),
                        Text(
                            _isEdit
                                ? 'Edit Kunjungan Tamu'
                                : 'Tambah Kunjungan',
                            style: AppTextStyle.h3),
                      ],
                    ),
                    const SizedBox(height: 20),

                    const Text('JUDUL KEGIATAN', style: AppTextStyle.label),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _judulCtrl,
                      decoration: const InputDecoration(
                          hintText: 'Cth: Bakti Sosial Kampus'),
                      validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),

                    const Text('NAMA TAMU / INSTANSI',
                        style: AppTextStyle.label),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _tamuCtrl,
                      decoration: const InputDecoration(
                          hintText: 'Cth: BEM Universitas ABC'),
                      validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),

                    const Text('TANGGAL PELAKSANAAN',
                        style: AppTextStyle.label),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _tanggal ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setState(() => _tanggal = picked);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                _tanggal != null
                                    ? DateFormat('dd MMM yyyy')
                                        .format(_tanggal!)
                                    : 'Pilih Tanggal',
                                style: TextStyle(
                                    color: _tanggal != null
                                        ? AppColors.textPrimary
                                        : Colors.grey)),
                            const Icon(Icons.calendar_today_rounded,
                                color: Colors.grey, size: 20),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text('FOTO KEGIATAN', style: AppTextStyle.label),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          border: Border.all(
                              color: AppColors.border,
                              style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(12),
                          image: _imageFile != null
                              ? DecorationImage(
                                  image: FileImage(_imageFile!),
                                  fit: BoxFit.cover)
                              : (_isEdit && widget.editData!.fotoUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(
                                          widget.editData!.fotoUrl!),
                                      fit: BoxFit.cover)
                                  : null),
                        ),
                        child: _imageFile == null &&
                                (!(_isEdit && widget.editData!.fotoUrl != null))
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo_rounded,
                                      color: Colors.grey, size: 32),
                                  SizedBox(height: 8),
                                  Text('Tap untuk pilih foto',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 12)),
                                ],
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // AI Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome,
                                  color: Color(0xFF16A34A), size: 18),
                              const SizedBox(width: 8),
                              const Expanded(
                                  child: Text('Buat Laporan dengan AI',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF166534)))),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isGeneratingAI
                                  ? null
                                  : _generateAiDescription,
                              icon: _isGeneratingAI
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white))
                                  : const Icon(Icons.bolt, size: 18),
                              label: Text(_isGeneratingAI
                                  ? 'Generating...'
                                  : 'Generate Narasi Laporan'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF16A34A),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text('DESKRIPSI LAPORAN', style: AppTextStyle.label),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _laporanCtrl,
                      maxLines: 5,
                      decoration: const InputDecoration(
                          hintText: 'Laporan lengkap kegiatan...'),
                      validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 24),

                    PrimaryButton(
                      text: _isEdit ? 'SIMPAN PERUBAHAN' : 'SIMPAN KUNJUNGAN',
                      icon: Icons.check_rounded,
                      isLoading: _isLoading,
                      onPressed: _isLoading ? null : _save,
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
