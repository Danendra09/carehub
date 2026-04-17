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

  InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.currentStock,
    required this.minStock,
    required this.unit,
    required this.status,
  });
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

  static List<ArtikelModel> artikels = [
    ArtikelModel(
      id: '1',
      judul: 'Kegiatan Belajar Bersama Anak Asuh CareHub',
      konten:
          'CareHub kembali menggelar kegiatan belajar bersama yang diikuti oleh seluruh anak asuh. Kegiatan ini bertujuan untuk meningkatkan semangat belajar dan mempersiapkan mereka menghadapi ujian semester. Pengajar sukarela dari berbagai universitas turut berpartisipasi dalam program ini.',
      tanggal: '15 Okt 2023',
    ),
    ArtikelModel(
      id: '2',
      judul: 'Penerimaan Donasi dari PT. Maju Bersama',
      konten:
          'CareHub dengan bangga menerima donasi dari PT. Maju Bersama sebesar Rp 10.000.000. Dana ini akan digunakan untuk memenuhi kebutuhan sehari-hari anak asuh dan program pendidikan. Terima kasih atas kepercayaan dan kepedulian.',
      tanggal: '10 Okt 2023',
    ),
    ArtikelModel(
      id: '3',
      judul: 'Perayaan Hari Anak Nasional di CareHub',
      konten:
          'Dalam rangka memperingati Hari Anak Nasional, CareHub mengadakan berbagai kegiatan menyenangkan. Mulai dari lomba mewarnai, pertunjukan seni, hingga pembagian hadiah bagi seluruh anak asuh.',
      tanggal: '23 Jul 2023',
    ),
    ArtikelModel(
      id: '4',
      judul: 'Program Pemeriksaan Kesehatan Gratis',
      konten:
          'Bekerjasama dengan Puskesmas setempat, CareHub mengadakan pemeriksaan kesehatan gratis untuk seluruh anak asuh. Dokter dan tenaga medis hadir langsung untuk memeriksa kondisi kesehatan dan memberikan konsultasi nutrisi.',
      tanggal: '5 Sep 2023',
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
