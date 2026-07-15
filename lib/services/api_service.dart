import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// خدمة الاتصال بسيرفر سواعد عربية
class ApiService {
  static const String baseUrl = 'https://hr.sawaedarab.com/api';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  static Future<Map<String, dynamic>> login(
      String nationalId, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Accept': 'application/json'},
        body: {'national_id': nationalId, 'password': password},
      );
      final body = jsonDecode(res.body);
      if (res.statusCode == 200) {
        return body;
      }
      return {
        'status': 'error',
        'message': body['message'] ?? 'بيانات الدخول غير صحيحة'
      };
    } catch (e) {
      return {'status': 'error', 'message': 'تعذر الاتصال بالسيرفر'};
    }
  }

  static Future<Map<String, dynamic>> logout() async {
    final token = await getToken();
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      await clearToken();
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      return {'status': 'error'};
    } catch (e) {
      return {'status': 'error', 'message': 'تعذر الاتصال بالسيرفر'};
    }
  }

  static Future<Map<String, dynamic>> me() async {
    final token = await getToken();
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/me'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      return {'status': 'error'};
    } catch (e) {
      return {'status': 'error', 'message': 'تعذر الاتصال بالسيرفر'};
    }
  }

  static Future<Map<String, dynamic>> dashboardSummary() async {
    final token = await getToken();
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/dashboard/summary'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      return {'status': 'error'};
    } catch (e) {
      return {'status': 'error', 'message': 'تعذر الاتصال بالسيرفر'};
    }
  }
}
