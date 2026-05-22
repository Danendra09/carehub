class ApiEndpoints {
  // === BASE URL ===
  // Ganti URL ini jika backend di-hosting di tempat lain.
  static const String baseUrl = 'https://carehub.my.id/api';
  static const String baseStorageUrl = 'https://carehub.my.id/storage';

  // === AUTHENTICATION & USER ===
  static const String login = '$baseUrl/login';
  static const String logout = '$baseUrl/logout';
  static const String user = '$baseUrl/user';
  static const String updateProfile = '$baseUrl/user/profile'; // Gunakan endpoint post/multipart
  static const String updatePassword = '$baseUrl/user/password';
  static const String sendOtp = '$baseUrl/lupa-password/kirim-otp';
  static const String resetPassword = '$baseUrl/reset-password';

  // === DASHBOARD ===
  static const String dashboard = '$baseUrl/dashboard';

  // === MANAJEMEN ANAK ===
  static const String anak = '$baseUrl/anak'; // GET (List), POST (Create)
  static String anakDetail(String id) => '$baseUrl/anak/$id'; // GET, PUT, DELETE

  // === INVENTARIS ===
  static const String inventaris = '$baseUrl/inventaris';
  static String inventarisDetail(String id) => '$baseUrl/inventaris/$id';

  // === KEUANGAN ===
  static const String keuangan = '$baseUrl/keuangan'; // Paginasi
  static const String keuanganList = '$baseUrl/keuangan-list'; // Semua data
  static String keuanganDetail(String id) => '$baseUrl/keuangan/$id';

  // === AUDIT KEUANGAN ===
  static const String auditKeuangan = '$baseUrl/audit-keuangan';
  static String auditKeuanganDetail(String id) => '$baseUrl/audit-keuangan/$id';

  // === KUNJUNGAN TAMU ===
  static const String kunjunganTamu = '$baseUrl/kunjungan-tamu';
  static String kunjunganTamuDetail(String id) => '$baseUrl/kunjungan-tamu/$id';
  static const String generateAiDescription = '$baseUrl/kunjungan-tamu/generate-ai';
  static const String suratOptions = '$baseUrl/kunjungan-tamu/surat-options';

  // === SEKRETARIAT (SURAT) ===
  static const String suratMasuk = '$baseUrl/surat-masuk';
  static String suratMasukDetail(String id) => '$baseUrl/surat-masuk/$id';
  
  static const String suratKeluar = '$baseUrl/surat-keluar';
  static String suratKeluarDetail(String id) => '$baseUrl/surat-keluar/$id';

  // === PROFIL PANTI ===
  static const String profil = '$baseUrl/profil';
  static String profilDetail(String id) => '$baseUrl/profil/$id';

  // === ARTIKEL / BERITA ===
  static const String artikel = '$baseUrl/artikel';
  static String artikelDetail(String id) => '$baseUrl/artikel/$id';

  // === SDM & ROLES (ADMIN ONLY) ===
  static const String sdm = '$baseUrl/sdm';
  static String sdmDetail(String id) => '$baseUrl/sdm/$id';
  static const String roles = '$baseUrl/sdm/roles';
  static const String rolesPermissions = '$baseUrl/roles-permissions';
  static String rolesPermissionsDetail(String id) => '$baseUrl/roles-permissions/$id';

  // === EXPORT REPORT ===
  static const String exportAuditCsv = '$baseUrl/export/audit-keuangan-csv';
  static const String exportAuditExcel = '$baseUrl/export/audit-keuangan-excel';
  static const String exportSuratMasukCsv = '$baseUrl/export/surat-masuk-csv';
  static const String exportSuratMasukExcel = '$baseUrl/export/surat-masuk-excel';
  static const String exportSuratKeluarCsv = '$baseUrl/export/surat-keluar-csv';
  static const String exportSuratKeluarExcel = '$baseUrl/export/surat-keluar-excel';
}
