import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// خدمة الاتصال بسيرفر سواعد عربية
/// غيّر baseUrl لرابط الـAPI الحقيقي بتاعك على السيرفر
class ApiService {
  static const String baseUrl = 'https://hr.sawaedarab.com/api';

  static Future<String?> _getToken() async {
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
    // TODO: استبدل بالرابط الحقيقي بعد بناء الـAPI في Laravel
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Accept': 'application/json'},
        body: {'national_id': nationalId, 'password': password},
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      return {'status': 'error', 'message': 'بيانات الدخول غير صحيحة'};
    } catch (e) {
      return {'status': 'error', 'message': 'تعذر الاتصال بالسيرفر'};
    }
  }

  static Future<Map<String, dynamic>> punchAttendance(String type) async {
    final token = await _getToken();
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/attendance/punch'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {'type': type},
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
