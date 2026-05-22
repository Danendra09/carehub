// ─── Child Model ─────────────────────────────────────────────────────────────
enum ChildStatus { sehat, pemulihan, perhatian }
enum Gender { male, female }

class ChildModel {
  final String id;
  final String name;
  final int age;
  final Gender gender;
  final ChildStatus status;
  final String grade;
  final String avatarInitials;
  final String tempatTglLahir;
  final String riwayatKesehatan;

  ChildModel({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.status,
    required this.grade,
    required this.avatarInitials,
    this.tempatTglLahir = '',
    this.riwayatKesehatan = 'Sehat',
  });

  factory ChildModel.fromJson(Map<String, dynamic> json) {
    // Parse gender (asumsi dari Laravel misal L/P atau male/female)
    String jk = (json['jenis_kelamin'] ?? '').toString().toLowerCase();
    Gender g = (jk == 'l' || jk == 'laki-laki' || jk == 'male') 
        ? Gender.male 
        : Gender.female;

    // Parse status secara statis dulu karena DB tidak punya kolom status (bisa diimprove nanti berdasar riwayat kesehatan)
    ChildStatus s = ChildStatus.sehat;

    // Generate Initials
    String n = json['nama_lengkap'] ?? 'Tanpa Nama';
    List<String> names = n.split(' ');
    String inits = '';
    if (names.isNotEmpty) {
      inits += names[0].isNotEmpty ? names[0][0].toUpperCase() : '';
      if (names.length > 1) {
        inits += names[names.length - 1].isNotEmpty ? names[names.length - 1][0].toUpperCase() : '';
      }
    }

    return ChildModel(
      id: json['id'].toString(),
      name: n,
      age: json['usia'] != null ? int.tryParse(json['usia'].toString()) ?? 0 : 0,
      gender: g,
      status: s,
      grade: json['info_pendidikan'] ?? '-',
      avatarInitials: inits.isEmpty ? '?' : inits,
      tempatTglLahir: json['tempat_tgl_lahir'] ?? '-',
      riwayatKesehatan: json['riwayat_kesehatan'] ?? 'Sehat',
    );
  }
}

// ─── Transaction Model ────────────────────────────────────────────────────────
enum TransactionType { income, expense }

class TransactionModel {
  final String id;
  final String title;
  final String subtitle;
  final String date;
  final double amount;
  final TransactionType type;
  final String category;

  TransactionModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.amount,
    required this.type,
    required this.category,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    String jenis = (json['jenis_transaksi'] ?? '').toString().toLowerCase();
    TransactionType tipe = (jenis == 'pemasukan' || jenis == 'income')
        ? TransactionType.income
        : TransactionType.expense;

    // Format tanggal dari created_at
    String tanggal = '-';
    if (json['created_at'] != null) {
      try {
        final dt = DateTime.parse(json['created_at'].toString());
        final bulan = ['','Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
        tanggal = '${dt.day} ${bulan[dt.month]} ${dt.year}';
      } catch (_) {}
    }

    return TransactionModel(
      id: json['id'].toString(),
      title: json['keterangan'] ?? 'Tanpa Keterangan',
      subtitle: json['kategori'] ?? '-',
      date: tanggal,
      amount: double.tryParse(json['jumlah_nominal'].toString()) ?? 0,
      type: tipe,
      category: json['kategori'] ?? '-',
    );
  }
}

// ─── Inventory Model ──────────────────────────────────────────────────────────
enum StockStatus { aman, menipis, habis }
enum ItemCategory { medis, pangan, kebersihan }

class InventoryItem {
  final String id;
  final String name;
  final String category;
  final int currentStock;
  final int minStock;
  final String unit;
  final StockStatus status;
  final String kondisi;

  InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.currentStock,
    required this.minStock,
    required this.unit,
    required this.status,
    this.kondisi = '-',
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    final stok = int.tryParse(json['stok'].toString()) ?? 0;
    // Tidak ada kolom minStock di DB, kita pakai 5 sebagai threshold default
    const minStok = 5;
    return InventoryItem(
      id: json['id'].toString(),
      name: json['nama_barang'] ?? 'Tanpa Nama',
      category: json['kategori'] ?? 'Lainnya',
      currentStock: stok,
      minStock: minStok,
      unit: 'Pcs',
      status: stok <= minStok ? StockStatus.menipis : StockStatus.aman,
      kondisi: json['kondisi'] ?? '-',
    );
  }
}

// ─── Artikel Model ────────────────────────────────────────────────────────────
class ArtikelModel {
  final String id;
  final String judul;
  final String konten;
  final String tanggal;
  final String? gambarPath;

  ArtikelModel({
    required this.id,
    required this.judul,
    required this.konten,
    required this.tanggal,
    this.gambarPath,
  });

  String get preview {
    final clean = konten.replaceAll('\n', ' ').trim();
    return clean.length > 120 ? '${clean.substring(0, 120)}...' : clean;
  }
}

// ─── Kunjungan Tamu Model ─────────────────────────────────────────────────────
class KunjunganTamuModel {
  final String id;
  final String judulKegiatan;
  final String namaTamu;
  final String tanggalPelaksanaan;
  final String? fotoUrl;
  final String deskripsiLaporan;
  final String? nomorSuratRef;

  KunjunganTamuModel({
    required this.id,
    required this.judulKegiatan,
    required this.namaTamu,
    required this.tanggalPelaksanaan,
    this.fotoUrl,
    required this.deskripsiLaporan,
    this.nomorSuratRef,
  });

  factory KunjunganTamuModel.fromJson(Map<String, dynamic> json) {
    return KunjunganTamuModel(
      id: json['id'].toString(),
      judulKegiatan: json['judul_kegiatan'] ?? '',
      namaTamu: json['nama_tamu'] ?? '',
      tanggalPelaksanaan: json['tanggal_pelaksanaan'] ?? '',
      fotoUrl: json['foto_url'],
      deskripsiLaporan: json['deskripsi_laporan'] ?? '',
      nomorSuratRef: json['nomor_surat_ref'],
    );
  }
}

class SuratOptionModel {
  final String id;
  final String kodeSurat;
  final String perihal;

  SuratOptionModel({
    required this.id,
    required this.kodeSurat,
    required this.perihal,
  });

  factory SuratOptionModel.fromJson(Map<String, dynamic> json) {
    return SuratOptionModel(
      id: json['id'].toString(),
      kodeSurat: json['kode_surat'] ?? '',
      perihal: json['perihal'] ?? '',
    );
  }
}

// ─── Audit Keuangan Model ─────────────────────────────────────────────────────
class AuditKeuanganModel {
  final String id;
  final String keuanganId;
  final String tanggal;
  final String jenis;
  final String kodeDokumen;
  final String keterangan;
  final double nominal;
  final String keuanganJenis;

  AuditKeuanganModel({
    required this.id,
    required this.keuanganId,
    required this.tanggal,
    required this.jenis,
    required this.kodeDokumen,
    required this.keterangan,
    required this.nominal,
    required this.keuanganJenis,
  });

  factory AuditKeuanganModel.fromJson(Map<String, dynamic> json) {
    // Format tanggal
    String tgl = '-';
    if (json['tanggal'] != null) {
      try {
        final dt = DateTime.parse(json['tanggal'].toString());
        final bulan = ['','Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
        tgl = '${dt.day} ${bulan[dt.month]} ${dt.year}';
      } catch (_) {}
    }

    return AuditKeuanganModel(
      id: json['id'].toString(),
      keuanganId: (json['keuangan_id'] ?? '').toString(),
      tanggal: tgl,
      jenis: json['jenis'] ?? '',
      kodeDokumen: json['kode_dokumen'] ?? '',
      keterangan: json['keterangan'] ?? '',
      nominal: double.tryParse((json['nominal'] ?? 0).toString()) ?? 0,
      keuanganJenis: json['keuangan_jenis'] ?? '',
    );
  }
}

class KeuanganOptionModel {
  final String id;
  final String keterangan;
  final double nominal;
  final String jenis;
  final String tanggal;

  KeuanganOptionModel({
    required this.id,
    required this.keterangan,
    required this.nominal,
    required this.jenis,
    required this.tanggal,
  });

  factory KeuanganOptionModel.fromJson(Map<String, dynamic> json) {
    return KeuanganOptionModel(
      id: json['id'].toString(),
      keterangan: json['keterangan'] ?? 'Tanpa Keterangan',
      nominal: double.tryParse((json['jumlah_nominal'] ?? 0).toString()) ?? 0,
      jenis: json['jenis_transaksi'] ?? '',
      tanggal: json['created_at'] ?? '',
    );
  }
}

class SuratModel {
  final String kodeSurat;
  final String perihal;

  SuratModel({
    required this.kodeSurat,
    required this.perihal,
  });

  factory SuratModel.fromJson(Map<String, dynamic> json) {
    return SuratModel(
      kodeSurat: json['kode_surat'] ?? '',
      perihal: json['perihal'] ?? '',
    );
  }
}

class SuratMasukModel {
  final String id;
  final String kodeSurat;
  final String perihal;
  final String pengirim;
  final String tanggalSurat;
  final String tanggalDiterima;
  final String keterangan;

  SuratMasukModel({
    required this.id,
    required this.kodeSurat,
    required this.perihal,
    required this.pengirim,
    required this.tanggalSurat,
    required this.tanggalDiterima,
    required this.keterangan,
  });

  factory SuratMasukModel.fromJson(Map<String, dynamic> json) {
    return SuratMasukModel(
      id: json['id'].toString(),
      kodeSurat: json['kode_surat'] ?? '',
      perihal: json['perihal'] ?? '',
      pengirim: json['pengirim'] ?? '',
      tanggalSurat: json['tanggal_surat'] ?? '',
      tanggalDiterima: json['tanggal_diterima'] ?? '',
      keterangan: json['keterangan'] ?? '',
    );
  }
}

class SuratKeluarModel {
  final String id;
  final String kodeSurat;
  final String perihal;
  final String tujuan;
  final String tanggalSurat;
  final String tanggalDikirim;
  final String keterangan;

  SuratKeluarModel({
    required this.id,
    required this.kodeSurat,
    required this.perihal,
    required this.tujuan,
    required this.tanggalSurat,
    required this.tanggalDikirim,
    required this.keterangan,
  });

  factory SuratKeluarModel.fromJson(Map<String, dynamic> json) {
    return SuratKeluarModel(
      id: json['id'].toString(),
      kodeSurat: json['kode_surat'] ?? '',
      perihal: json['perihal'] ?? '',
      tujuan: json['tujuan'] ?? '',
      tanggalSurat: json['tanggal_surat'] ?? '',
      tanggalDikirim: json['tanggal_dikirim'] ?? '',
      keterangan: json['keterangan'] ?? '',
    );
  }
}

// ─── Dummy Data ───────────────────────────────────────────────────────────────
class AppData {
  static List<ChildModel> children = [
    ChildModel(
      id: '1',
      name: 'Ahmad Hidayat',
      age: 12,
      gender: Gender.male,
      status: ChildStatus.sehat,
      grade: 'Kelas 6 SD',
      avatarInitials: 'AH',
      tempatTglLahir: 'Purwokerto, 5 Maret 2012',
      riwayatKesehatan: 'Sehat',
    ),
    ChildModel(
      id: '2',
      name: 'Siti Aminah',
      age: 9,
      gender: Gender.female,
      status: ChildStatus.pemulihan,
      grade: 'Kelas 3 SD',
      avatarInitials: 'SA',
      tempatTglLahir: 'Banyumas, 14 Juli 2015',
      riwayatKesehatan: 'Alergi debu ringan',
    ),
    ChildModel(
      id: '3',
      name: 'Rizky Pratama',
      age: 15,
      gender: Gender.male,
      status: ChildStatus.sehat,
      grade: 'Kelas 9 SMP',
      avatarInitials: 'RP',
      tempatTglLahir: 'Cilacap, 20 Januari 2009',
      riwayatKesehatan: 'Sehat',
    ),
    ChildModel(
      id: '4',
      name: 'Dewi Rahayu',
      age: 7,
      gender: Gender.female,
      status: ChildStatus.sehat,
      grade: 'Kelas 1 SD',
      avatarInitials: 'DR',
      tempatTglLahir: 'Kebumen, 8 November 2017',
      riwayatKesehatan: 'Sehat',
    ),
    ChildModel(
      id: '5',
      name: 'Fajar Nugroho',
      age: 11,
      gender: Gender.male,
      status: ChildStatus.perhatian,
      grade: 'Kelas 5 SD',
      avatarInitials: 'FN',
      tempatTglLahir: 'Wonosobo, 3 Juni 2013',
      riwayatKesehatan: 'Asma ringan',
    ),
  ];

  static List<TransactionModel> transactions = [
    TransactionModel(
      id: '1',
      title: 'Donasi Rutin Yayasan',
      subtitle: 'Donasi',
      date: '12 Okt 2023',
      amount: 2500000,
      type: TransactionType.income,
      category: 'Donasi',
    ),
    TransactionModel(
      id: '2',
      title: 'Pembelian Beras 50kg',
      subtitle: 'Pembelian',
      date: '10 Okt 2023',
      amount: 850000,
      type: TransactionType.expense,
      category: 'Pembelian',
    ),
    TransactionModel(
      id: '3',
      title: 'Zakat Hamba Allah',
      subtitle: 'Donasi',
      date: '08 Okt 2023',
      amount: 500000,
      type: TransactionType.income,
      category: 'Donasi',
    ),
    TransactionModel(
      id: '4',
      title: 'Obat-obatan Rutin',
      subtitle: 'Pembelian',
      date: '05 Okt 2023',
      amount: 320000,
      type: TransactionType.expense,
      category: 'Pembelian',
    ),
    TransactionModel(
      id: '5',
      title: 'Donasi Bulanan Corp',
      subtitle: 'Donasi',
      date: '01 Okt 2023',
      amount: 5000000,
      type: TransactionType.income,
      category: 'Donasi',
    ),
    TransactionModel(
      id: '6',
      title: 'Bayar Listrik & Air',
      subtitle: 'Operasional',
      date: '28 Sep 2023',
      amount: 450000,
      type: TransactionType.expense,
      category: 'Operasional',
    ),
  ];

  static List<InventoryItem> inventoryItems = [
    InventoryItem(
      id: '1',
      name: 'Paracetamol Drop 60ml',
      category: 'Obat-obatan',
      currentStock: 4,
      minStock: 10,
      unit: 'Botol',
      status: StockStatus.menipis,
    ),
    InventoryItem(
      id: '2',
      name: 'Popok Bayi Size M',
      category: 'Kebersihan',
      currentStock: 12,
      minStock: 20,
      unit: 'Pcs',
      status: StockStatus.menipis,
    ),
    InventoryItem(
      id: '3',
      name: 'Susu Formula Tahap 1',
      category: 'Pangan',
      currentStock: 2,
      minStock: 8,
      unit: 'Box',
      status: StockStatus.menipis,
    ),
    InventoryItem(
      id: '4',
      name: 'Sabun Cuci Tangan',
      category: 'Kebersihan',
      currentStock: 5,
      minStock: 15,
      unit: 'Liter',
      status: StockStatus.menipis,
    ),
    InventoryItem(
      id: '5',
      name: 'Beras Premium 5kg',
      category: 'Pangan',
      currentStock: 40,
      minStock: 20,
      unit: 'Kg',
      status: StockStatus.aman,
    ),
    InventoryItem(
      id: '6',
      name: 'Vitamin C 500mg',
      category: 'Obat-obatan',
      currentStock: 60,
      minStock: 30,
      unit: 'Strip',
      status: StockStatus.aman,
    ),
  ];

  static List<double> cashflowData = [
    1200000,
    1500000,
    1400000,
    1800000,
    2320000,
    2100000,
    1900000,
    2400000,
    2200000,
    2800000,
    2600000,
    3200000,
  ];
}
