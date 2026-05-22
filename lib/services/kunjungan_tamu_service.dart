import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../utils/api_endpoints.dart';
import '../models/models.dart';
import 'auth_service.dart';

class KunjunganTamuService {
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

  static Future<Map<String, String>> _getMultipartHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Get all kunjungan tamu
  static Future<List<KunjunganTamuModel>> getKunjunganTamu() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(ApiEndpoints.kunjunganTamu),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => KunjunganTamuModel.fromJson(e)).toList();
      } else {
        throw Exception('Gagal mengambil data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // Create kunjungan tamu
  static Future<bool> createKunjunganTamu({
    required Map<String, String> data,
    File? imageFile,
  }) async {
    try {
      final headers = await _getMultipartHeaders();
      final uri = Uri.parse(ApiEndpoints.kunjunganTamu);
      var request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);

      data.forEach((key, value) {
        request.fields[key] = value;
      });

      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath('foto_kegiatan', imageFile.path));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print('[CREATE KUNJUNGAN] Status: ${response.statusCode}');
      print('[CREATE KUNJUNGAN] Body: ${response.body}');
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('[CREATE KUNJUNGAN ERROR] $e');
      return false;
    }
  }

  // Update kunjungan tamu (POST + _method=PUT)
  static Future<bool> updateKunjunganTamu({
    required String id,
    required Map<String, String> data,
    File? imageFile,
  }) async {
    try {
      final headers = await _getMultipartHeaders();
      final uri = Uri.parse(ApiEndpoints.kunjunganTamuDetail(id));
      var request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);

      data.forEach((key, value) {
        request.fields[key] = value;
      });

      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath('foto_kegiatan', imageFile.path));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print('[UPDATE KUNJUNGAN] Status: ${response.statusCode}');
      print('[UPDATE KUNJUNGAN] Body: ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('[UPDATE KUNJUNGAN ERROR] $e');
      return false;
    }
  }

  // Delete kunjungan tamu (POST + _method=DELETE)
  static Future<bool> deleteKunjunganTamu(String id) async {
    try {
      final headers = await _getFormHeaders();
      final response = await http.post(
        Uri.parse(ApiEndpoints.kunjunganTamuDetail(id)),
        headers: headers,
        body: '_method=DELETE',
      );
      print('[DELETE KUNJUNGAN] Status: ${response.statusCode}');
      print('[DELETE KUNJUNGAN] Body: ${response.body}');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('[DELETE KUNJUNGAN ERROR] $e');
      return false;
    }
  }

  // Get surat options
  static Future<Map<String, List<SuratOptionModel>>> getSuratOptions() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(ApiEndpoints.suratOptions),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> masuk = data['surat_masuk'] ?? [];
        final List<dynamic> keluar = data['surat_keluar'] ?? [];
        
        return {
          'surat_masuk': masuk.map((e) => SuratOptionModel.fromJson(e)).toList(),
          'surat_keluar': keluar.map((e) => SuratOptionModel.fromJson(e)).toList(),
        };
      }
      return {'surat_masuk': [], 'surat_keluar': []};
    } catch (e) {
      print('[GET SURAT OPTIONS ERROR] $e');
      return {'surat_masuk': [], 'surat_keluar': []};
    }
  }

  // Generate AI Description
  static Future<String?> generateAiDescription(String poinPoin) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(ApiEndpoints.generateAiDescription),
        headers: headers,
        body: json.encode({'poin_poin': poinPoin}),
      );
      
      print('[GENERATE AI] Status: ${response.statusCode}');
      print('[GENERATE AI] Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      }
      return null;
    } catch (e) {
      print('[GENERATE AI ERROR] $e');
      return null;
    }
  }
}
