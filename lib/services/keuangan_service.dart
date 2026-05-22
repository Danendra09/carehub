import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_endpoints.dart';
import 'auth_service.dart';

class KeuanganService {
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

  // Get all transaksi
  static Future<List<Map<String, dynamic>>> getKeuangan() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(ApiEndpoints.keuanganList),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Gagal mengambil data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // Create transaksi
  static Future<bool> createKeuangan(Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(ApiEndpoints.keuangan),
        headers: headers,
        body: json.encode(data),
      );
      print('[CREATE KEUANGAN] Status: ${response.statusCode}');
      print('[CREATE KEUANGAN] Body: ${response.body}');
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('[CREATE KEUANGAN ERROR] $e');
      return false;
    }
  }

  // Delete transaksi (POST + _method=DELETE karena hosting blokir DELETE)
  static Future<bool> deleteKeuangan(String id) async {
    try {
      final headers = await _getFormHeaders();
      final response = await http.post(
        Uri.parse(ApiEndpoints.keuanganDetail(id)),
        headers: headers,
        body: '_method=DELETE',
      );
      print('[DELETE KEUANGAN] Status: ${response.statusCode}');
      print('[DELETE KEUANGAN] Body: ${response.body}');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('[DELETE KEUANGAN ERROR] $e');
      return false;
    }
  }
}
