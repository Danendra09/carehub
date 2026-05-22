import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/api_endpoints.dart';

class AuthService {
  static const _secureStorage = FlutterSecureStorage();
  // Login dan simpan token
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.login),
        headers: {
          'Accept': 'application/json',
        },
        body: {
          'email': email,
          'password': password,
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        // Login berhasil, simpan token DENGAN AMAN menggunakan Secure Storage
        await _secureStorage.write(key: 'auth_token', value: data['token']);
        
        // Simpan data role/nama biasa di SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        if (data['user'] != null) {
          await prefs.setString('user_name', data['user']['name'] ?? 'Admin');
          await prefs.setString('user_email', data['user']['email'] ?? '');
          await prefs.setString('user_role', data['user']['role'] ?? '');
          await prefs.setString('user_foto', data['user']['foto'] ?? '');
          
          // Simpan permissions jika ada
          if (data['user']['all_permissions'] != null) {
            final List<dynamic> perms = data['user']['all_permissions'];
            final List<String> permissionsList = perms.map((e) => e.toString()).toList();
            await prefs.setStringList('user_permissions', permissionsList);
          } else {
            await prefs.setStringList('user_permissions', []);
          }
        }

        return {'success': true, 'message': 'Login Berhasil'};
      } else {
        // Gagal login (kredensial salah / error)
        return {'success': false, 'message': data['message'] ?? 'Email atau password salah.'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Gagal menghubungi server. Periksa koneksi internet Anda.'};
    }
  }

  // Ambil token saat ini dengan aman
  static Future<String?> getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  // Logout dan hapus token
  static Future<bool> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        // Panggil API logout di backend agar token di-revoke
        await http.post(
          Uri.parse(ApiEndpoints.logout),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      }
      
      await _secureStorage.delete(key: 'auth_token');
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_name');
      await prefs.remove('user_email');
      await prefs.remove('user_role');
      await prefs.remove('user_foto');
      await prefs.remove('user_permissions');
      
      return true;
    } catch (e) {
      await _secureStorage.delete(key: 'auth_token');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_name');
      await prefs.remove('user_role');
      await prefs.remove('user_foto');
      await prefs.remove('user_permissions');
      return true;
    }
  }

  // Get User Permissions
  static Future<List<String>> getPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('user_permissions') ?? [];
  }

  // Cek apakah user memiliki permission tertentu (contoh: view_anak)
  static Future<bool> hasPermission(String permission) async {
    final permissions = await getPermissions();
    // Jika user punya role admin atau punya permission spesifik
    return permissions.contains(permission);
  }

  // Cek apakah user sudah login (token masih ada)
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Update profil (termasuk upload foto jika ada)
  static Future<Map<String, dynamic>> updateProfile(String name, String email, File? fotoFile) async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Token tidak ditemukan'};

      var request = http.MultipartRequest('POST', Uri.parse(ApiEndpoints.updateProfile));
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      request.fields['name'] = name;
      request.fields['email'] = email;

      if (fotoFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('foto', fotoFile.path),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      var data = json.decode(response.body);

      if (response.statusCode == 200) {
        // Simpan pembaruan ke lokal
        final prefs = await SharedPreferences.getInstance();
        final updatedUser = data['user'];
        if (updatedUser != null) {
          await prefs.setString('user_name', updatedUser['name'] ?? name);
          await prefs.setString('user_email', updatedUser['email'] ?? email);
          if (updatedUser['foto'] != null) {
            await prefs.setString('user_foto', updatedUser['foto']);
          }
        }
        return {'success': true, 'message': 'Profil berhasil diperbarui'};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Gagal memperbarui profil'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi server'};
    }
  }

  // Update password
  static Future<Map<String, dynamic>> updatePassword(String currentPassword, String newPassword) async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Token tidak ditemukan'};

      final response = await http.post(
        Uri.parse(ApiEndpoints.updatePassword),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {
          '_method': 'PUT',
          'current_password': currentPassword,
          'password': newPassword,
          'password_confirmation': newPassword,
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message'] ?? 'Password berhasil diubah'};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Gagal mengubah password'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi server'};
    }
  }
}
