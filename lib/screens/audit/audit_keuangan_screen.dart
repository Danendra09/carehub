import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../../models/models.dart';
import '../../services/audit_service.dart';

class AuditKeuanganScreen extends StatefulWidget {
  const AuditKeuanganScreen({super.key});

  @override
  State<AuditKeuanganScreen> createState() => _AuditKeuanganScreenState();
}

class _AuditKeuanganScreenState extends State<AuditKeuanganScreen> {
  List<AuditKeuanganModel> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final data = await AuditService.getAuditKeuangan();
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

  void _showAddEditSheet({AuditKeuanganModel? editData}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddEditAuditSheet(
        editData: editData,
        onSaved: () => _fetchData(),
      ),
    );
  }

  void _deleteItem(AuditKeuanganModel item) {
    showDeleteConfirmDialog(
      context: context,
      title: 'Hapus Audit',
      message: 'Hapus riwayat audit dokumen "${item.kodeDokumen}"?',
      onConfirm: () async {
        final success = await AuditService.deleteAuditKeuangan(item.id);
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchData,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: CareHubAppBar(
                      titleText: 'Audit Keuangan',
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: AppColors.textPrimary, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const Text('PENGELOLAAN AUDIT',
                            style: AppTextStyle.label),
                        const SizedBox(height: 4),
                        const Text('Audit Transaksi Keuangan',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 24),
                        if (_items.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 40),
                            child: EmptyStateWidget(
                              icon: Icons.monetization_on_rounded,
                              title: 'Belum Ada Audit',
                              subtitle:
                                  'Belum ada data audit keuangan. Silakan tap tombol Tambah di bawah.',
                            ),
                          )
                        else
                          ..._items.map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _AuditCard(
                                  item: item,
                                  onDelete: () => _deleteItem(item),
                                ),
                              )),
                      ]),
                    ),
                  )
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_audit',
        onPressed: () => _showAddEditSheet(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
        label: const Text('Tambah',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _AuditCard extends StatelessWidget {
  final AuditKeuanganModel item;
  final VoidCallback onDelete;

  const _AuditCard({required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: item.jenis == 'MASUK'
                      ? AppColors.successLight
                      : AppColors.dangerLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.jenis == 'MASUK' ? 'AUDIT MASUK' : 'AUDIT KELUAR',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: item.jenis == 'MASUK'
                        ? AppColors.success
                        : AppColors.danger,
                  ),
                ),
              ),
              Text(item.tanggal,
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 12),
          Text(item.kodeDokumen,
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.description_rounded,
                  size: 16, color: Colors.black54),
              const SizedBox(width: 6),
              Expanded(
                  child: Text(
                      item.keterangan.isNotEmpty
                          ? item.keterangan
                          : 'Tanpa Keterangan',
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black87),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.monetization_on_rounded,
                  size: 16, color: Colors.black54),
              const SizedBox(width: 6),
              Text(
                'Rp ${item.nominal.toStringAsFixed(0)}',
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
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
                        Icon(Icons.delete_outline_rounded,
                            color: AppColors.danger, size: 16),
                        SizedBox(width: 6),
                        Text('Hapus',
                            style: TextStyle(
                                color: AppColors.danger,
                                fontWeight: FontWeight.w600,
                                fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _AddEditAuditSheet extends StatefulWidget {
  final AuditKeuanganModel? editData;
  final VoidCallback onSaved;

  const _AddEditAuditSheet({this.editData, required this.onSaved});

  @override
  State<_AddEditAuditSheet> createState() => _AddEditAuditSheetState();
}

class _AddEditAuditSheetState extends State<_AddEditAuditSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _keteranganCtrl;

  String? _selectedKeuanganId;
  String? _selectedSurat;
  String _selectedJenis = 'MASUK';

  bool _isLoading = false;

  List<KeuanganOptionModel> _keuanganOptions = [];
  List<SuratModel> _suratOptions = [];
  bool _isLoadingOptions = true;

  bool get _isEdit => widget.editData != null;

  @override
  void initState() {
    super.initState();
    final d = widget.editData;
    _keteranganCtrl = TextEditingController(text: d?.keterangan ?? '');

    if (_isEdit) {
      _selectedSurat = d!.kodeDokumen;
      _selectedJenis = d.jenis;
    }

    _loadOptions();
  }

  Future<void> _loadOptions() async {
    final keuanganOpts = await AuditService.getKeuanganOptions();
    final suratOpts = await AuditService.getSuratOptions();

    if (mounted) {
      setState(() {
        _keuanganOptions = keuanganOpts;
        _suratOptions = suratOpts;

        // Memastikan dropdown awal valid jika ada yang terlewat
        if (!_isEdit && _keuanganOptions.isNotEmpty) {
          _selectedKeuanganId = _keuanganOptions.first.id;
        }
        if (!_isEdit && _suratOptions.isNotEmpty) {
          _selectedSurat = _suratOptions.first.kodeSurat;
        }

        // Cek fallback form edit apabila kode dokumen sudah dihapus di master data surat
        if (_isEdit &&
            !_suratOptions
                .any((element) => element.kodeSurat == _selectedSurat)) {
          _selectedSurat = null;
        }

        _isLoadingOptions = false;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isEdit && _selectedKeuanganId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih Transaksi Keuangan')));
      return;
    }
    if (_selectedSurat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih Kode Dokumen (Surat)')));
      return;
    }

    setState(() => _isLoading = true);

    final data = {
      'jenis_audit': _selectedJenis,
      'kode_dokumen': _selectedSurat!,
      'keterangan': _keteranganCtrl.text.trim(),
    };

    if (!_isEdit) {
      data['keuangan_id'] = _selectedKeuanganId!;
    }

    bool success;
    if (_isEdit) {
      success =
          await AuditService.updateAuditKeuangan(widget.editData!.id, data);
    } else {
      success = await AuditService.createAuditKeuangan(data);
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
                        Text(_isEdit ? 'Edit Audit Keuangan' : 'Tambah Audit',
                            style: AppTextStyle.h3),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (_isLoadingOptions)
                      const Center(
                          child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator()))
                    else ...[
                      if (!_isEdit) ...[
                        const Text('TRANSAKSI KEUANGAN',
                            style: AppTextStyle.label),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedKeuanganId,
                          isExpanded: true,
                          decoration: const InputDecoration(
                              hintText: 'Pilih Transaksi'),
                          items: _keuanganOptions
                              .map((e) => DropdownMenuItem(
                                    value: e.id,
                                    child: Text(
                                        '${e.jenis.toUpperCase()} - Rp ${e.nominal.toStringAsFixed(0)}\n${e.keterangan}'),
                                  ))
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _selectedKeuanganId = val),
                        ),
                        const SizedBox(height: 16),
                      ],
                      const Text('KODE DOKUMEN (SURAT)',
                          style: AppTextStyle.label),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedSurat,
                        isExpanded: true,
                        decoration: const InputDecoration(
                            hintText: 'Pilih Kode Dokumen'),
                        items: _suratOptions
                            .map((e) => DropdownMenuItem(
                                  value: e.kodeSurat,
                                  child: Text('${e.kodeSurat} - ${e.perihal}'),
                                ))
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedSurat = val),
                      ),
                      const SizedBox(height: 16),
                      const Text('JENIS AUDIT', style: AppTextStyle.label),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedJenis,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(
                              value: 'MASUK', child: Text('MASUK')),
                          DropdownMenuItem(
                              value: 'KELUAR', child: Text('KELUAR')),
                        ],
                        onChanged: (val) =>
                            setState(() => _selectedJenis = val!),
                      ),
                      const SizedBox(height: 16),
                      const Text('KETERANGAN', style: AppTextStyle.label),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _keteranganCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(
                            hintText: 'Keterangan atau hasil audit...'),
                        validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        text: _isEdit ? 'SIMPAN PERUBAHAN' : 'TAMBAH AUDIT',
                        icon: Icons.check_rounded,
                        isLoading: _isLoading,
                        onPressed: _isLoading ? null : _save,
                      ),
                    ]
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
