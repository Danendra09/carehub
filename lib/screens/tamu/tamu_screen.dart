import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class TamuScreen extends StatefulWidget {
  const TamuScreen({super.key});

  @override
  State<TamuScreen> createState() => _TamuScreenState();
}

class _TamuScreenState extends State<TamuScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  DateTime? selectedDate;

  final TextEditingController judulController =
      TextEditingController();

  final TextEditingController namaController =
      TextEditingController();

  final TextEditingController tanggalController =
      TextEditingController();

  final TextEditingController deskripsiController =
      TextEditingController();

  final List<Map<String, dynamic>> kunjunganList = [
    {
      'title':
          'Semarak Akhir Pekan: Belajar Membuat Kerajinan',
      'description':
          'Akhir pekan ini, antusias mengikuti workshop barang bekas bersama relawan.',
      'date': '12 April 2026',
      'image':
          'https://images.unsplash.com/photo-1516627145497-ae6968895b74?q=80&w=1200&auto=format&fit=crop',
    },
    {
      'title': 'Kunjungan Edukasi Anak',
      'description':
          'Kegiatan edukasi bersama anak-anak dengan suasana yang menyenangkan.',
      'date': '14 April 2026',
      'image':
          'https://images.unsplash.com/photo-1509062522246-3755977927d7?q=80&w=1200&auto=format&fit=crop',
    },
  ];

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;

        tanggalController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  void _showTambahBottomSheet(BuildContext context) {
    judulController.clear();
    namaController.clear();
    tanggalController.clear();
    deskripsiController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _buildFormSheet(
          context,
          title: 'TAMBAH KUNJUNGAN TAMU',
          buttonText: 'Simpan',
          onSave: () {
            setState(() {
              kunjunganList.add({
                'title': judulController.text,
                'description':
                    deskripsiController.text,
                'date': tanggalController.text,
                'image':
                    'https://images.unsplash.com/photo-1516627145497-ae6968895b74?q=80&w=1200&auto=format&fit=crop',
              });
            });

            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _showEditBottomSheet(
    BuildContext context,
    int index,
  ) {
    final item = kunjunganList[index];

    judulController.text = item['title'];
    namaController.text = item['title'];
    tanggalController.text = item['date'];
    deskripsiController.text =
        item['description'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _buildFormSheet(
          context,
          title: 'EDIT KUNJUNGAN TAMU',
          buttonText: 'Update',
          imageUrl: item['image'],
          onSave: () {
            setState(() {
              kunjunganList[index] = {
                'title': judulController.text,
                'description':
                    deskripsiController.text,
                'date': tanggalController.text,
                'image': item['image'],
              };
            });

            Navigator.pop(context);
          },
        );
      },
    );
  }

  Widget _buildFormSheet(
    BuildContext context, {
    required String title,
    required String buttonText,
    required VoidCallback onSave,
    String? imageUrl,
  }) {
    return Container(
      height: MediaQuery.of(context).size.height *
          0.92,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 70,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius:
                      BorderRadius.circular(20),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xff2962FF),
                    Color(0xff4F46E5),
                  ],
                ),
                borderRadius:
                    BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white
                          .withOpacity(0.15),
                      borderRadius:
                          BorderRadius.circular(
                              16),
                    ),
                    child: const Icon(
                      Icons.groups_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Database kunjungan',
                          style: TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _buildLabel('Judul Kegiatan'),

            TextField(
              controller: judulController,
              decoration: InputDecoration(
                hintText:
                    'Masukkan judul kegiatan...',
                filled: true,
                fillColor:
                    const Color(0xffF5F7FB),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 18),

            _buildLabel('Nama Kegiatan'),

            TextField(
              controller: namaController,
              decoration: InputDecoration(
                hintText:
                    'Masukkan nama kegiatan...',
                filled: true,
                fillColor:
                    const Color(0xffF5F7FB),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 18),

            _buildLabel('Tanggal Pelaksanaan'),

            TextField(
              controller: tanggalController,
              readOnly: true,
              onTap: () => _pickDate(context),
              decoration: InputDecoration(
                hintText: 'dd/mm/yyyy',
                suffixIcon: const Icon(
                  Icons.calendar_today_outlined,
                ),
                filled: true,
                fillColor:
                    const Color(0xffF5F7FB),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 18),

            if (imageUrl != null) ...[
              _buildLabel('Foto Kegiatan'),

              Container(
                width: double.infinity,
                height: 170,
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                ),
                child: Center(
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(
                            16),
                    child: Image.network(
                      imageUrl,
                      width: 140,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),
            ],

            _buildLabel('Deskripsi Laporan'),

            TextField(
              controller: deskripsiController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText:
                    'Tuliskan laporan kegiatan...',
                filled: true,
                fillColor:
                    const Color(0xffF5F7FB),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 30),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style:
                        OutlinedButton.styleFrom(
                      minimumSize:
                          const Size.fromHeight(
                              56),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                                18),
                      ),
                    ),
                    child: const Text(
                      'Batal',
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: ElevatedButton(
                    onPressed: onSave,
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          AppColors.primary,
                      minimumSize:
                          const Size.fromHeight(
                              56),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                                18),
                      ),
                    ),
                    child: Text(
                      buttonText,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    int index,
  ) {
    showDeleteConfirmDialog(
      context: context,
      title: 'Hapus Kunjungan Tamu',
      message: 'Apakah Anda yakin ingin menghapus kunjungan tamu ini secara permanen? Tindakan ini tidak dapat dibatalkan.',
      onConfirm: () async {
        setState(() {
          kunjunganList.removeAt(index);
        });
      },
    );
  }

  Widget _buildLabel(String title) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xffF5F7FB),
      appBar: const CareHubAppBar(),
      floatingActionButton:
          FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () {
          _showTambahBottomSheet(context);
        },
        icon: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        label: const Text(
          'Tambah',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate:
                    SliverChildListDelegate([
                  Container(
                    padding:
                        const EdgeInsets.all(
                            20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(
                              24),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        const Text(
                          'KUNJUNGAN TAMU',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),

                        const SizedBox(
                            height: 8),

                        Text(
                          'TOTAL: ${kunjunganList.length} KUNJUNGAN',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                FontWeight.w700,
                            color: Colors
                                .grey.shade600,
                          ),
                        ),

                        const SizedBox(
                            height: 20),

                        TextField(
                          controller:
                              _searchController,
                          decoration:
                              InputDecoration(
                            hintText:
                                'Cari kunjungan...',
                            prefixIcon:
                                const Icon(
                                    Icons
                                        .search),
                            filled: true,
                            fillColor:
                                const Color(
                                    0xffF5F7FB),
                            border:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          16),
                              borderSide:
                                  BorderSide
                                      .none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  ...List.generate(
                    kunjunganList.length,
                    (index) {
                      final item =
                          kunjunganList[index];

                      return Padding(
                        padding:
                            const EdgeInsets
                                .only(
                                    bottom:
                                        18),
                        child:
                            _KunjunganCard(
                          item: item,
                          onEdit: () {
                            _showEditBottomSheet(
                              context,
                              index,
                            );
                          },
                          onDelete: () {
                            _showDeleteDialog(
                              context,
                              index,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KunjunganCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _KunjunganCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
            child: Stack(
              children: [
                Image.network(
                  item['image'],
                  height: 190,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),

                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(
                              20),
                    ),
                    child: Text(
                      item['date'],
                      style:
                          const TextStyle(
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding:
                const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                        const Color(0xffEEF2FF),
                    borderRadius:
                        BorderRadius.circular(
                            14),
                  ),
                  child: Row(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.person_outline,
                        size: 16,
                        color:
                            AppColors.primary,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'DEANKT',
                        style: TextStyle(
                          color:
                              AppColors.primary,
                          fontWeight:
                              FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  item['title'],
                  style: const TextStyle(
                    fontSize: 22,
                    height: 1.2,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  item['description'],
                  style: TextStyle(
                    fontSize: 14,
                    color:
                        Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child:
                          GestureDetector(
                        onTap: onEdit,
                        child: Container(
                          height: 48,
                          decoration:
                              BoxDecoration(
                            color:
                                const Color(
                                    0xffEEF4FF),
                            borderRadius:
                                BorderRadius
                                    .circular(
                                        14),
                          ),
                          child:
                              const Center(
                            child: Text(
                              'EDIT DATA',
                              style:
                                  TextStyle(
                                color:
                                    AppColors
                                        .primary,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child:
                          GestureDetector(
                        onTap: onDelete,
                        child: Container(
                          height: 48,
                          decoration:
                              BoxDecoration(
                            color:
                                const Color(
                                    0xffFFF1F1),
                            borderRadius:
                                BorderRadius
                                    .circular(
                                        14),
                          ),
                          child:
                              const Center(
                            child: Text(
                              'HAPUS DATA',
                              style:
                                  TextStyle(
                                color:
                                    Colors.red,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
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