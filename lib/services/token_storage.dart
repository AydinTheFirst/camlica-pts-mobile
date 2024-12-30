import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static Future<String> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = await prefs.setString('token', token);
    return saved ? token : '';
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    return token;
  }

  static Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}
