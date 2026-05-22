import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_endpoints.dart';
import '../models/models.dart';
import 'auth_service.dart';

class AnakService {
  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Get all anak
  static Future<List<ChildModel>> getAnak() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(ApiEndpoints.anak),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ChildModel.fromJson(json)).toList();
      } else {
        throw Exception('Gagal mengambil data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // Create anak
  static Future<bool> createAnak(Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(ApiEndpoints.anak),
        headers: headers,
        body: json.encode(data),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Update anak (POST + _method=PUT karena server hosting blokir PUT/PATCH)
  static Future<bool> updateAnak(String id, Map<String, dynamic> data) async {
    try {
      final token = await AuthService.getToken();
      final uri = Uri.parse(ApiEndpoints.anakDetail(id));

      // Gunakan form-encoded agar _method=PUT dikenali Laravel method spoofing
      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer $token',
      };

      // Encode semua field sebagai form data
      final formData = <String, String>{
        '_method': 'PUT',
      };
      data.forEach((key, value) {
        formData[key] = value.toString();
      });

      final response = await http.post(
        uri,
        headers: headers,
        body: Uri(queryParameters: formData).query,
      );

      print('[UPDATE ANAK] Status: ${response.statusCode}');
      print('[UPDATE ANAK] Body: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('[UPDATE ANAK ERROR] $e');
      return false;
    }
  }

  // Delete anak (POST + _method=DELETE karena server hosting blokir DELETE)
  static Future<bool> deleteAnak(String id) async {
    try {
      final token = await AuthService.getToken();
      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer $token',
      };
      final response = await http.post(
        Uri.parse(ApiEndpoints.anakDetail(id)),
        headers: headers,
        body: '_method=DELETE',
      );

      print('[DELETE ANAK] Status: ${response.statusCode}');
      print('[DELETE ANAK] Body: ${response.body}');

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('[DELETE ANAK ERROR] $e');
      return false;
    }
  }
}
