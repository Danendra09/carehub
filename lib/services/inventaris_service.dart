import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../utils/api_endpoints.dart';
import '../models/models.dart';
import 'auth_service.dart';

class InventarisService {
  static Future<String?> _getToken() async => await AuthService.getToken();

  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Get all inventaris
  static Future<List<InventoryItem>> getInventaris() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(ApiEndpoints.inventaris),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => InventoryItem.fromJson(e)).toList();
      } else {
        throw Exception('Gagal mengambil data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // Create inventaris (multipart agar bisa upload gambar)
  static Future<bool> createInventaris(
    Map<String, dynamic> data, {
    File? gambar,
  }) async {
    try {
      final token = await _getToken();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiEndpoints.inventaris),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      data.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      if (gambar != null) {
        request.files.add(await http.MultipartFile.fromPath('gambar', gambar.path));
      }

      final streamed = await request.send();
      final body = await streamed.stream.bytesToString();
      print('[CREATE INVENTARIS] Status: ${streamed.statusCode}');
      print('[CREATE INVENTARIS] Body: $body');
      return streamed.statusCode == 201 || streamed.statusCode == 200;
    } catch (e) {
      print('[CREATE INVENTARIS ERROR] $e');
      return false;
    }
  }

  // Update inventaris (multipart + _method=PUT)
  static Future<bool> updateInventaris(
    String id,
    Map<String, dynamic> data, {
    File? gambar,
  }) async {
    try {
      final token = await _getToken();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiEndpoints.inventarisDetail(id)),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      request.fields['_method'] = 'PUT';
      data.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      if (gambar != null) {
        request.files.add(await http.MultipartFile.fromPath('gambar', gambar.path));
      }

      final streamed = await request.send();
      final body = await streamed.stream.bytesToString();
      print('[UPDATE INVENTARIS] Status: ${streamed.statusCode}');
      print('[UPDATE INVENTARIS] Body: $body');
      return streamed.statusCode == 200;
    } catch (e) {
      print('[UPDATE INVENTARIS ERROR] $e');
      return false;
    }
  }

  // Delete inventaris (POST + _method=DELETE)
  static Future<bool> deleteInventaris(String id) async {
    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse(ApiEndpoints.inventarisDetail(id)),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer $token',
        },
        body: '_method=DELETE',
      );
      print('[DELETE INVENTARIS] Status: ${response.statusCode}');
      print('[DELETE INVENTARIS] Body: ${response.body}');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('[DELETE INVENTARIS ERROR] $e');
      return false;
    }
  }
}
