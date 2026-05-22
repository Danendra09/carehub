import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_endpoints.dart';
import '../models/models.dart';
import 'auth_service.dart';

class AuditService {
  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, String>> _getFormHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $token',
    };
  }

  // === Audit Keuangan ===
  static Future<List<AuditKeuanganModel>> getAuditKeuangan() async {
    try {
      final headers = await _getHeaders();
      // Mengambil data audit, di backend ada pagination. Kita ambil banyak data
      final response = await http.get(
        Uri.parse('${ApiEndpoints.auditKeuangan}?per_page=1000'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'] ?? [];
        return data.map((e) => AuditKeuanganModel.fromJson(e)).toList();
      } else {
        throw Exception('Gagal memuat data audit keuangan');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  static Future<bool> createAuditKeuangan(Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(ApiEndpoints.auditKeuangan),
        headers: headers,
        body: json.encode(data),
      );
      print('[CREATE AUDIT] Status: ${response.statusCode} | Body: ${response.body}');
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('[CREATE AUDIT ERROR] $e');
      return false;
    }
  }

  static Future<bool> updateAuditKeuangan(String id, Map<String, dynamic> data) async {
    try {
      final headers = await _getFormHeaders();
      
      // Menggunakan form-urlencoded dengan _method=PUT
      final requestBody = {'_method': 'PUT'};
      data.forEach((key, value) {
        requestBody[key] = value.toString();
      });

      final response = await http.post(
        Uri.parse(ApiEndpoints.auditKeuanganDetail(id)),
        headers: headers,
        body: requestBody,
      );
      print('[UPDATE AUDIT] Status: ${response.statusCode} | Body: ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('[UPDATE AUDIT ERROR] $e');
      return false;
    }
  }

  static Future<bool> deleteAuditKeuangan(String id) async {
    try {
      final headers = await _getFormHeaders();
      final response = await http.post(
        Uri.parse(ApiEndpoints.auditKeuanganDetail(id)),
        headers: headers,
        body: '_method=DELETE',
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('[DELETE AUDIT ERROR] $e');
      return false;
    }
  }

  // === Keuangan Options ===
  static Future<List<KeuanganOptionModel>> getKeuanganOptions() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(ApiEndpoints.keuanganList),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => KeuanganOptionModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('[GET KEUANGAN OPTIONS ERROR] $e');
      return [];
    }
  }

  // === Surat Options ===
  static Future<List<SuratModel>> getSuratOptions() async {
    try {
      final headers = await _getHeaders();
      
      // Fetch Surat Masuk
      final responseMasuk = await http.get(
        Uri.parse('${ApiEndpoints.suratMasuk}?per_page=1000'),
        headers: headers,
      );
      List<SuratModel> suratList = [];
      
      if (responseMasuk.statusCode == 200) {
        final dataMasuk = json.decode(responseMasuk.body);
        final List<dynamic> items = dataMasuk['data'] ?? [];
        suratList.addAll(items.map((e) => SuratModel.fromJson(e)).toList());
      }

      // Fetch Surat Keluar
      final responseKeluar = await http.get(
        Uri.parse('${ApiEndpoints.suratKeluar}?per_page=1000'),
        headers: headers,
      );
      if (responseKeluar.statusCode == 200) {
        final dataKeluar = json.decode(responseKeluar.body);
        final List<dynamic> items = dataKeluar['data'] ?? [];
        suratList.addAll(items.map((e) => SuratModel.fromJson(e)).toList());
      }
      
      return suratList;
    } catch (e) {
      print('[GET SURAT OPTIONS ERROR] $e');
      return [];
    }
  }
}
