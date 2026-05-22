import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_endpoints.dart';
import '../models/models.dart';
import 'auth_service.dart';

class SuratService {
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

  // === SURAT MASUK ===
  static Future<List<SuratMasukModel>> getSuratMasuk() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiEndpoints.suratMasuk}?per_page=1000'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'] ?? [];
        return data.map((e) => SuratMasukModel.fromJson(e)).toList();
      } else {
        throw Exception('Gagal memuat surat masuk');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  static Future<bool> createSuratMasuk(Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(ApiEndpoints.suratMasuk),
        headers: headers,
        body: json.encode(data),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('[CREATE SURAT MASUK ERROR] $e');
      return false;
    }
  }

  static Future<bool> updateSuratMasuk(String id, Map<String, dynamic> data) async {
    try {
      final headers = await _getFormHeaders();
      final requestBody = {'_method': 'PUT'};
      data.forEach((key, value) {
        requestBody[key] = value.toString();
      });

      final response = await http.post(
        Uri.parse(ApiEndpoints.suratMasukDetail(id)),
        headers: headers,
        body: requestBody,
      );
      return response.statusCode == 200;
    } catch (e) {
      print('[UPDATE SURAT MASUK ERROR] $e');
      return false;
    }
  }

  static Future<bool> deleteSuratMasuk(String id) async {
    try {
      final headers = await _getFormHeaders();
      final response = await http.post(
        Uri.parse(ApiEndpoints.suratMasukDetail(id)),
        headers: headers,
        body: '_method=DELETE',
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('[DELETE SURAT MASUK ERROR] $e');
      return false;
    }
  }

  // === SURAT KELUAR ===
  static Future<List<SuratKeluarModel>> getSuratKeluar() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiEndpoints.suratKeluar}?per_page=1000'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'] ?? [];
        return data.map((e) => SuratKeluarModel.fromJson(e)).toList();
      } else {
        throw Exception('Gagal memuat surat keluar');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  static Future<bool> createSuratKeluar(Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(ApiEndpoints.suratKeluar),
        headers: headers,
        body: json.encode(data),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('[CREATE SURAT KELUAR ERROR] $e');
      return false;
    }
  }

  static Future<bool> updateSuratKeluar(String id, Map<String, dynamic> data) async {
    try {
      final headers = await _getFormHeaders();
      final requestBody = {'_method': 'PUT'};
      data.forEach((key, value) {
        requestBody[key] = value.toString();
      });

      final response = await http.post(
        Uri.parse(ApiEndpoints.suratKeluarDetail(id)),
        headers: headers,
        body: requestBody,
      );
      return response.statusCode == 200;
    } catch (e) {
      print('[UPDATE SURAT KELUAR ERROR] $e');
      return false;
    }
  }

  static Future<bool> deleteSuratKeluar(String id) async {
    try {
      final headers = await _getFormHeaders();
      final response = await http.post(
        Uri.parse(ApiEndpoints.suratKeluarDetail(id)),
        headers: headers,
        body: '_method=DELETE',
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('[DELETE SURAT KELUAR ERROR] $e');
      return false;
    }
  }
}
