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
      .where((c) => c.name.toLowerCase().contains(_query.toLowerCase()))
      .toList();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

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
                const Text('MANAJEMEN DATA', style: AppTextStyle.label),
                const SizedBox(height: 4),
                const Text('Daftar Anak Asuh', style: AppTextStyle.h2),

                const SizedBox(height: 20),

                // Search + filter row
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
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.tune_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Add button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddDialog(context),
                    icon: const Icon(Icons.add_rounded, size: 20),
                    label: const Text('TAMBAH ANAK ASUH'),
                  ),
                ),

                const SizedBox(height: 20),

                // Child list
                ..._filtered.map((child) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ChildCard(child: child),
                    )),

                if (_filtered.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(Icons.search_off_rounded,
                              size: 48, color: AppColors.textTertiary),
                          SizedBox(height: 12),
                          Text('Tidak ditemukan',
                              style: AppTextStyle.bodySmall),
                        ],
                      ),
                    ),
                  ),

                if (_query.isEmpty) ...[
                  const SizedBox(height: 4),
                  Center(
                    child: GestureDetector(
                      onTap: () {},
                      child: const Column(
                        children: [
                          Text(
                            'LIHAT LEBIH BANYAK',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Icon(Icons.keyboard_arrow_down_rounded,
                              color: AppColors.primary),
                        ],
                      ),
                    ),
                  ),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddChildSheet(),
    );
  }
}

class _ChildCard extends StatelessWidget {
  final ChildModel child;

  const _ChildCard({required this.child});

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
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          ChildAvatar(initials: child.avatarInitials, radius: 30),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  child.name,
                  style: AppTextStyle.body.copyWith(
                      fontWeight: FontWeight.w700, fontSize: 15),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(
                      child.gender == Gender.male
                          ? Icons.male_rounded
                          : Icons.female_rounded,
                      size: 14,
                      color: child.gender == Gender.male
                          ? AppColors.info
                          : AppColors.danger,
                    ),
                    const SizedBox(width: 2),
                    Text('${child.age} Tahun',
                        style: AppTextStyle.bodySmall),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _statusBadge(),
                    const SizedBox(width: 6),
                    StatusBadge(
                      label: child.grade,
                      color: AppColors.textSecondary,
                      bgColor: AppColors.border,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              _IconButton(
                icon: Icons.edit_outlined,
                color: AppColors.primary,
                onTap: () {},
              ),
              const SizedBox(height: 8),
              _IconButton(
                icon: Icons.delete_outline_rounded,
                color: AppColors.danger,
                onTap: () => _showDeleteConfirm(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Data Anak'),
        content: Text('Apakah Anda yakin ingin menghapus data ${child.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              minimumSize: const Size(80, 36),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _IconButton({
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
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}

class _AddChildSheet extends StatefulWidget {
  const _AddChildSheet();

  @override
  State<_AddChildSheet> createState() => _AddChildSheetState();
}

class _AddChildSheetState extends State<_AddChildSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  String _selectedGender = 'male';
  String _selectedStatus = 'sehat';
  String _selectedGrade = 'Kelas 1 SD';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
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
                const Text('Tambah Anak Asuh', style: AppTextStyle.h3),
                const SizedBox(height: 20),
                const _FieldLabel('Nama Lengkap'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameCtrl,
                  decoration:
                      const InputDecoration(hintText: 'Masukkan nama anak'),
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
                          const _FieldLabel('Umur'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _ageCtrl,
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
                          const _FieldLabel('Jenis Kelamin'),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedGender,
                            decoration: const InputDecoration(),
                            items: const [
                              DropdownMenuItem(
                                  value: 'male', child: Text('Laki-laki')),
                              DropdownMenuItem(
                                  value: 'female', child: Text('Perempuan')),
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
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _FieldLabel('Status'),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedStatus,
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
                            initialValue: _selectedGrade,
                            decoration: const InputDecoration(),
                            items: [
                              'Kelas 1 SD',
                              'Kelas 2 SD',
                              'Kelas 3 SD',
                              'Kelas 4 SD',
                              'Kelas 5 SD',
                              'Kelas 6 SD',
                              'Kelas 7 SMP',
                              'Kelas 8 SMP',
                              'Kelas 9 SMP',
                            ]
                                .map((g) => DropdownMenuItem(
                                    value: g, child: Text(g, style: const TextStyle(fontSize: 12))))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedGrade = v!),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  text: 'SIMPAN DATA',
                  icon: Icons.check_rounded,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Data anak berhasil ditambahkan'),
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
