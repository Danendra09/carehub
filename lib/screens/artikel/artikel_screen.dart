import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/shared_widgets.dart';

// ─── Artikel List Screen ──────────────────────────────────────────────────────
class ArtikelScreen extends StatefulWidget {
  const ArtikelScreen({super.key});

  @override
  State<ArtikelScreen> createState() => _ArtikelScreenState();
}

class _ArtikelScreenState extends State<ArtikelScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  List<ArtikelModel> get _filtered => AppData.artikels
      .where((a) =>
          a.judul.toLowerCase().contains(_query.toLowerCase()) ||
          a.konten.toLowerCase().contains(_query.toLowerCase()))
      .toList();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _hapusArtikel(BuildContext ctx, ArtikelModel artikel) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Artikel'),
        content: Text(
            'Hapus artikel "${artikel.judul}" secara permanen?'),
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
              setState(() => AppData.artikels.removeWhere((a) => a.id == artikel.id));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(
                  content: const Text('Artikel berhasil dihapus'),
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

  void _bukaForm(BuildContext ctx, {ArtikelModel? artikel}) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: ArtikelFormScreen(
            artikel: artikel,
            onSaved: () => setState(() {}),
          ),
        ),
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
                // Header
                const Text('KONTEN & PUBLIKASI', style: AppTextStyle.label),
                const SizedBox(height: 4),
                const Text('Artikel & CMS', style: AppTextStyle.h2),
                const SizedBox(height: 20),

                // Search bar saja
                TextFormField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _query = v),
                  style: AppTextStyle.body,
                  decoration: const InputDecoration(
                    hintText: 'Cari artikel...',
                    hintStyle:
                        TextStyle(color: AppColors.textTertiary, fontSize: 14),
                    prefixIcon: Icon(Icons.search_rounded,
                        color: AppColors.textTertiary, size: 20),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  ),
                ),

                const SizedBox(height: 16),

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
                      const Icon(Icons.newspaper_rounded,
                          color: AppColors.primary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '${list.length} Artikel Dipublish',
                        style: AppTextStyle.body
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Grid artikel
                if (list.isEmpty)
                  _EmptyArtikel(onTambah: () => _bukaForm(context))
                else
                  ...list.map((a) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _ArtikelCard(
                          artikel: a,
                          onEdit: () => _bukaForm(context, artikel: a),
                          onHapus: () => _hapusArtikel(context, a),
                        ),
                      )),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_artikel',
        onPressed: () => _bukaForm(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Tulis Artikel',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14)),
      ),
    );
  }
}

// ─── Artikel Card ─────────────────────────────────────────────────────────────
class _ArtikelCard extends StatelessWidget {
  final ArtikelModel artikel;
  final VoidCallback onEdit;
  final VoidCallback onHapus;

  const _ArtikelCard({
    required this.artikel,
    required this.onEdit,
    required this.onHapus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail / placeholder
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              height: 130,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFEFF6FF), Color(0xFFE0E7FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Icon(Icons.newspaper_rounded,
                    size: 48, color: Color(0xFFBFDBFE)),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tanggal
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    artikel.tanggal,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Judul
                Text(
                  artikel.judul,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // Preview konten
                Text(
                  artikel.preview,
                  style: AppTextStyle.bodySmall,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 12),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 12),

                // Actions
                Row(
                  children: [
                    // Edit button
                    Expanded(
                      child: GestureDetector(
                        onTap: onEdit,
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(vertical: 10),
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
                          padding:
                              const EdgeInsets.symmetric(vertical: 10),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyArtikel extends StatelessWidget {
  final VoidCallback onTambah;
  const _EmptyArtikel({required this.onTambah});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.newspaper_rounded,
              size: 64, color: AppColors.border),
          const SizedBox(height: 16),
          const Text('Belum ada artikel',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              )),
          const SizedBox(height: 8),
          const Text('Tulis artikel pertama untuk publikasi',
              style: AppTextStyle.bodySmall),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onTambah,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Tulis Artikel Pertama'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(200, 46),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Artikel Form Screen (Tambah & Edit) ──────────────────────────────────────
class ArtikelFormScreen extends StatefulWidget {
  final ArtikelModel? artikel; // null = Tambah, tidak null = Edit
  final VoidCallback onSaved;

  const ArtikelFormScreen({
    super.key,
    this.artikel,
    required this.onSaved,
  });

  @override
  State<ArtikelFormScreen> createState() => _ArtikelFormScreenState();
}

class _ArtikelFormScreenState extends State<ArtikelFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _judulCtrl;
  late final TextEditingController _kontenCtrl;
  int _charCount = 0;

  bool get _isEdit => widget.artikel != null;

  @override
  void initState() {
    super.initState();
    _judulCtrl = TextEditingController(text: widget.artikel?.judul ?? '');
    _kontenCtrl = TextEditingController(text: widget.artikel?.konten ?? '');
    _charCount = _kontenCtrl.text.length;
    _kontenCtrl.addListener(() {
      setState(() => _charCount = _kontenCtrl.text.length);
    });
  }

  @override
  void dispose() {
    _judulCtrl.dispose();
    _kontenCtrl.dispose();
    super.dispose();
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final tanggal =
        '${now.day} ${_bulan(now.month)} ${now.year}';

    if (_isEdit) {
      final idx = AppData.artikels
          .indexWhere((a) => a.id == widget.artikel!.id);
      if (idx != -1) {
        AppData.artikels[idx] = ArtikelModel(
          id: widget.artikel!.id,
          judul: _judulCtrl.text.trim(),
          konten: _kontenCtrl.text.trim(),
          tanggal: widget.artikel!.tanggal,
        );
      }
    } else {
      final newId =
          (AppData.artikels.length + 1).toString();
      AppData.artikels.insert(
        0,
        ArtikelModel(
          id: newId,
          judul: _judulCtrl.text.trim(),
          konten: _kontenCtrl.text.trim(),
          tanggal: tanggal,
        ),
      );
    }

    widget.onSaved();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEdit
            ? 'Artikel berhasil diperbarui!'
            : 'Artikel berhasil dipublish!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _bulan(int m) {
    const bulan = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return bulan[m];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header banner
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isEdit ? 'Edit Artikel' : 'Tulis Artikel Baru',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'CareHub CMS Engine',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white70,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Form body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul
                    const Text('JUDUL ARTIKEL', style: AppTextStyle.label),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _judulCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Masukkan judul artikel yang menarik...',
                        fillColor: AppColors.surface,
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 20),

                    // Konten
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('ISI KONTEN / DESKRIPSI',
                            style: AppTextStyle.label),
                        Text(
                          '$_charCount karakter',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textTertiary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _kontenCtrl,
                      maxLines: 10,
                      decoration: const InputDecoration(
                        hintText:
                            'Tuliskan isi berita, kegiatan, atau pengumuman panti asuhan di sini...',
                        fillColor: AppColors.surface,
                        contentPadding: EdgeInsets.all(16),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 20),

                    // Upload gambar (placeholder UI)
                    const Text('GAMBAR ARTIKEL', style: AppTextStyle.label),
                    const SizedBox(height: 4),
                    const Text('Opsional, dari galeri perangkat',
                        style: AppTextStyle.bodySmall),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Upload gambar akan aktif setelah koneksi ke backend'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.border,
                            width: 1.5,
                            strokeAlign: BorderSide.strokeAlignInside,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.image_rounded,
                                  color: AppColors.primary, size: 22),
                            ),
                            const SizedBox(height: 10),
                            const Text('Ketuk untuk upload gambar',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                )),
                            const Text('JPG, PNG • Maks. 10MB',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textTertiary,
                                )),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Tombol actions
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close_rounded, size: 18),
                            label: const Text('Batal'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 52),
                              side: const BorderSide(
                                  color: AppColors.border, width: 1.5),
                              foregroundColor: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: _simpan,
                            icon: Icon(
                              _isEdit
                                  ? Icons.save_rounded
                                  : Icons.send_rounded,
                              size: 18,
                            ),
                            label: Text(
                                _isEdit ? 'Simpan Perubahan' : 'Publish'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(0, 52),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
