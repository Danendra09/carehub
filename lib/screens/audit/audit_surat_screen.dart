import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../../models/models.dart';
import '../../services/surat_service.dart';
import 'package:intl/intl.dart';

class AuditSuratScreen extends StatefulWidget {
  const AuditSuratScreen({super.key});

  @override
  State<AuditSuratScreen> createState() => _AuditSuratScreenState();
}

class _AuditSuratScreenState extends State<AuditSuratScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  List<SuratMasukModel> _suratMasuk = [];
  List<SuratKeluarModel> _suratKeluar = [];
  
  bool _isLoadingMasuk = true;
  bool _isLoadingKeluar = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchSuratMasuk();
    _fetchSuratKeluar();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchSuratMasuk() async {
    setState(() => _isLoadingMasuk = true);
    try {
      final data = await SuratService.getSuratMasuk();
      if (mounted) setState(() => _suratMasuk = data);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoadingMasuk = false);
    }
  }

  Future<void> _fetchSuratKeluar() async {
    setState(() => _isLoadingKeluar = true);
    try {
      final data = await SuratService.getSuratKeluar();
      if (mounted) setState(() => _suratKeluar = data);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoadingKeluar = false);
    }
  }

  void _showSuratMasukSheet({SuratMasukModel? editData}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddEditSuratMasukSheet(
        editData: editData,
        onSaved: _fetchSuratMasuk,
      ),
    );
  }

  void _showSuratKeluarSheet({SuratKeluarModel? editData}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddEditSuratKeluarSheet(
        editData: editData,
        onSaved: _fetchSuratKeluar,
      ),
    );
  }

  void _deleteSuratMasuk(SuratMasukModel item) {
    showDeleteConfirmDialog(
      context: context,
      title: 'Hapus Surat Masuk',
      message: 'Hapus surat "${item.kodeSurat}"?',
      onConfirm: () async {
        final success = await SuratService.deleteSuratMasuk(item.id);
        if (success) _fetchSuratMasuk();
      },
    );
  }

  void _deleteSuratKeluar(SuratKeluarModel item) {
    showDeleteConfirmDialog(
      context: context,
      title: 'Hapus Surat Keluar',
      message: 'Hapus surat "${item.kodeSurat}"?',
      onConfirm: () async {
        final success = await SuratService.deleteSuratKeluar(item.id);
        if (success) _fetchSuratKeluar();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Audit Sekretariat', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'SURAT MASUK'),
            Tab(text: 'SURAT KELUAR'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB SURAT MASUK
          _isLoadingMasuk
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _fetchSuratMasuk,
                  child: _suratMasuk.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 80),
                            EmptyStateWidget(
                              icon: Icons.mark_email_unread_rounded,
                              title: 'Belum Ada Surat Masuk',
                              subtitle: 'Data surat masuk masih kosong. Silakan tap tombol Tambah di bawah untuk mencatat.',
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(20).copyWith(bottom: 100),
                          itemCount: _suratMasuk.length,
                          itemBuilder: (ctx, index) {
                            final item = _suratMasuk[index];
                            return _SuratCard(
                              kodeSurat: item.kodeSurat,
                              perihal: item.perihal,
                              keterangan: item.keterangan,
                              instansiLabel: 'Pengirim',
                              instansiName: item.pengirim,
                              tanggalLabel: 'Diterima',
                              tanggalValue: item.tanggalDiterima,
                              isMasuk: true,
                              onEdit: () => _showSuratMasukSheet(editData: item),
                              onDelete: () => _deleteSuratMasuk(item),
                            );
                          },
                        ),
                ),
          
          // TAB SURAT KELUAR
          _isLoadingKeluar
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _fetchSuratKeluar,
                  child: _suratKeluar.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 80),
                            EmptyStateWidget(
                              icon: Icons.send_rounded,
                              title: 'Belum Ada Surat Keluar',
                              subtitle: 'Data surat keluar masih kosong. Silakan tap tombol Tambah di bawah untuk mencatat.',
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(20).copyWith(bottom: 100),
                          itemCount: _suratKeluar.length,
                          itemBuilder: (ctx, index) {
                            final item = _suratKeluar[index];
                            return _SuratCard(
                              kodeSurat: item.kodeSurat,
                              perihal: item.perihal,
                              keterangan: item.keterangan,
                              instansiLabel: 'Tujuan',
                              instansiName: item.tujuan,
                              tanggalLabel: 'Dikirim',
                              tanggalValue: item.tanggalDikirim,
                              isMasuk: false,
                              onEdit: () => _showSuratKeluarSheet(editData: item),
                              onDelete: () => _deleteSuratKeluar(item),
                            );
                          },
                        ),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_tabController.index == 0) {
            _showSuratMasukSheet();
          } else {
            _showSuratKeluarSheet();
          }
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

// === FORM SURAT MASUK ===
class _AddEditSuratMasukSheet extends StatefulWidget {
  final SuratMasukModel? editData;
  final VoidCallback onSaved;
  const _AddEditSuratMasukSheet({this.editData, required this.onSaved});
  @override
  State<_AddEditSuratMasukSheet> createState() => _AddEditSuratMasukSheetState();
}
class _AddEditSuratMasukSheetState extends State<_AddEditSuratMasukSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _kodeCtrl, _perihalCtrl, _pengirimCtrl, _keteranganCtrl;
  DateTime? _tglSurat, _tglDiterima;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final d = widget.editData;
    _kodeCtrl = TextEditingController(text: d?.kodeSurat ?? '');
    _perihalCtrl = TextEditingController(text: d?.perihal ?? '');
    _pengirimCtrl = TextEditingController(text: d?.pengirim ?? '');
    _keteranganCtrl = TextEditingController(text: d?.keterangan ?? '');
    if (d != null) {
      try { _tglSurat = DateTime.parse(d.tanggalSurat); } catch (_) {}
      try { _tglDiterima = DateTime.parse(d.tanggalDiterima); } catch (_) {}
    }
  }

  Future<void> _pickDate(bool isSurat) async {
    final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
    if (picked != null) {
      setState(() {
        if (isSurat) _tglSurat = picked;
        else _tglDiterima = picked;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_tglSurat == null || _tglDiterima == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mohon pilih tanggal')));
      return;
    }
    setState(() => _isLoading = true);
    
    final data = {
      'kode_surat': _kodeCtrl.text,
      'perihal': _perihalCtrl.text,
      'pengirim': _pengirimCtrl.text,
      'tanggal_surat': DateFormat('yyyy-MM-dd').format(_tglSurat!),
      'tanggal_diterima': DateFormat('yyyy-MM-dd').format(_tglDiterima!),
      'keterangan': _keteranganCtrl.text,
    };

    bool success;
    if (widget.editData != null) {
      success = await SuratService.updateSuratMasuk(widget.editData!.id, data);
    } else {
      success = await SuratService.createSuratMasuk(data);
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        widget.onSaved();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menyimpan')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildFormLayout(
      context: context,
      title: widget.editData != null ? 'Edit Surat Masuk' : 'Tambah Surat Masuk',
      formKey: _formKey,
      children: [
        _buildField('Kode Surat', _kodeCtrl, true),
        _buildField('Perihal', _perihalCtrl, true),
        _buildField('Pengirim', _pengirimCtrl, true),
        Row(
          children: [
            Expanded(child: _buildDatePicker('Tgl Surat', _tglSurat, () => _pickDate(true))),
            const SizedBox(width: 16),
            Expanded(child: _buildDatePicker('Tgl Diterima', _tglDiterima, () => _pickDate(false))),
          ],
        ),
        _buildField('Keterangan', _keteranganCtrl, false, maxLines: 3),
        const SizedBox(height: 24),
        _buildActionButtons(context, _isLoading, _save),
      ],
    );
  }
}

// === FORM SURAT KELUAR ===
class _AddEditSuratKeluarSheet extends StatefulWidget {
  final SuratKeluarModel? editData;
  final VoidCallback onSaved;
  const _AddEditSuratKeluarSheet({this.editData, required this.onSaved});
  @override
  State<_AddEditSuratKeluarSheet> createState() => _AddEditSuratKeluarSheetState();
}
class _AddEditSuratKeluarSheetState extends State<_AddEditSuratKeluarSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _kodeCtrl, _perihalCtrl, _tujuanCtrl, _keteranganCtrl;
  DateTime? _tglSurat, _tglDikirim;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final d = widget.editData;
    _kodeCtrl = TextEditingController(text: d?.kodeSurat ?? '');
    _perihalCtrl = TextEditingController(text: d?.perihal ?? '');
    _tujuanCtrl = TextEditingController(text: d?.tujuan ?? '');
    _keteranganCtrl = TextEditingController(text: d?.keterangan ?? '');
    if (d != null) {
      try { _tglSurat = DateTime.parse(d.tanggalSurat); } catch (_) {}
      try { _tglDikirim = DateTime.parse(d.tanggalDikirim); } catch (_) {}
    }
  }

  Future<void> _pickDate(bool isSurat) async {
    final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
    if (picked != null) {
      setState(() {
        if (isSurat) _tglSurat = picked;
        else _tglDikirim = picked;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_tglSurat == null || _tglDikirim == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mohon pilih tanggal')));
      return;
    }
    setState(() => _isLoading = true);
    
    final data = {
      'kode_surat': _kodeCtrl.text,
      'perihal': _perihalCtrl.text,
      'tujuan': _tujuanCtrl.text,
      'tanggal_surat': DateFormat('yyyy-MM-dd').format(_tglSurat!),
      'tanggal_dikirim': DateFormat('yyyy-MM-dd').format(_tglDikirim!),
      'keterangan': _keteranganCtrl.text,
    };

    bool success;
    if (widget.editData != null) {
      success = await SuratService.updateSuratKeluar(widget.editData!.id, data);
    } else {
      success = await SuratService.createSuratKeluar(data);
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        widget.onSaved();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menyimpan')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildFormLayout(
      context: context,
      title: widget.editData != null ? 'Edit Surat Keluar' : 'Tambah Surat Keluar',
      formKey: _formKey,
      children: [
        _buildField('Kode Surat', _kodeCtrl, true),
        _buildField('Perihal', _perihalCtrl, true),
        _buildField('Tujuan', _tujuanCtrl, true),
        Row(
          children: [
            Expanded(child: _buildDatePicker('Tgl Surat', _tglSurat, () => _pickDate(true))),
            const SizedBox(width: 16),
            Expanded(child: _buildDatePicker('Tgl Dikirim', _tglDikirim, () => _pickDate(false))),
          ],
        ),
        _buildField('Keterangan', _keteranganCtrl, false, maxLines: 3),
        const SizedBox(height: 24),
        _buildActionButtons(context, _isLoading, _save),
      ],
    );
  }
}

// HELPER COMPONENTS FOR FORMS
Widget _buildFormLayout({required BuildContext context, required String title, required GlobalKey formKey, required List<Widget> children}) {
  return Align(
    alignment: Alignment.bottomCenter,
    child: Container(
      decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24).copyWith(bottom: MediaQuery.of(context).viewInsets.bottom + 24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 10),
                Row(
                  children: [
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20)),
                    Text(title, style: AppTextStyle.h3),
                  ],
                ),
                const SizedBox(height: 20),
                ...children
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _buildField(String label, TextEditingController controller, bool required, {int maxLines = 1}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label.toUpperCase(),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black45, letterSpacing: 1.0),
            children: required ? [const TextSpan(text: ' *', style: TextStyle(color: AppColors.danger))] : [],
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87),
          decoration: InputDecoration(
            hintText: 'Contoh / Masukkan $label',
            hintStyle: const TextStyle(color: Colors.black38),
            filled: true,
            fillColor: const Color(0xFFF8F9FA), // Very light grey
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
          ),
          validator: required ? (v) => v!.isEmpty ? 'Wajib diisi' : null : null,
        ),
      ],
    ),
  );
}

Widget _buildDatePicker(String label, DateTime? date, VoidCallback onTap) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label.toUpperCase(),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black45, letterSpacing: 1.0),
            children: [const TextSpan(text: ' *', style: TextStyle(color: AppColors.danger))],
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date != null ? DateFormat('dd/MM/yyyy').format(date) : 'dd/mm/tttt',
                  style: TextStyle(
                    color: date != null ? Colors.black87 : Colors.black87,
                    fontWeight: date != null ? FontWeight.w600 : FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const Icon(Icons.calendar_today_rounded, size: 18, color: Colors.black87),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildActionButtons(BuildContext context, bool isLoading, VoidCallback onSave) {
  return Row(
    children: [
      Expanded(
        child: OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            side: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('Batal', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 15)),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: ElevatedButton(
          onPressed: isLoading ? null : onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        ),
      ),
    ],
  );
}

// === CUSTOM SURAT CARD ===
class _SuratCard extends StatelessWidget {
  final String kodeSurat;
  final String perihal;
  final String keterangan;
  final String instansiLabel;
  final String instansiName;
  final String tanggalLabel;
  final String tanggalValue;
  final bool isMasuk;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SuratCard({
    required this.kodeSurat,
    required this.perihal,
    required this.keterangan,
    required this.instansiLabel,
    required this.instansiName,
    required this.tanggalLabel,
    required this.tanggalValue,
    required this.isMasuk,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Sesuai screenshot: icon besar di kiri dengan bg merah (kita gunakan AppColors.primary untuk keseragaman atau warna sesuai jenis surat).
    // Kita gunakan warna primary (merah/biru tua) agar persis screenshot (icon box besar merah).
    final themeColor = isMasuk ? AppColors.success : AppColors.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER ROW
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: themeColor, // Warna kotak icon surat
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(isMasuk ? Icons.mark_email_unread_rounded : Icons.send_rounded, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      perihal,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: AppColors.textPrimary, letterSpacing: 0.5),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.person_rounded, size: 14, color: Colors.black54),
                        const SizedBox(width: 6),
                        Expanded(child: Text(instansiName, style: const TextStyle(fontSize: 13, color: Colors.black54), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 14, color: Colors.black54),
                        const SizedBox(width: 6),
                        Text(tanggalValue, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          // DESCRIPTION TEXT
          Text(
            'Surat ini tercatat dengan nomor dokumen $kodeSurat. ${keterangan.isNotEmpty ? keterangan : ''}',
            style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
          ),
          
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 16),
          
          // BUTTONS
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(color: const Color(0xFFF0F5FF), borderRadius: BorderRadius.circular(12)),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit_rounded, color: AppColors.primary, size: 18),
                        SizedBox(width: 8),
                        Text('Edit', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(12)),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 18),
                        SizedBox(width: 8),
                        Text('Hapus', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold, fontSize: 14)),
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

