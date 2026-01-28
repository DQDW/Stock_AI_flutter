import 'dart:convert';
import 'package:flutter/foundation.dart'; // kIsWeb 사용을 위해
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final _storage = const FlutterSecureStorage();
  static const _keyAccessToken = 'ACCESS_TOKEN';

  // 백엔드 기본 URL (안드로이드 에뮬레이터 대응)
  // 웹에서 실행 중이거나 실기기인 경우 주소가 다를 수 있음
  static String get _baseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    // 제공된 백엔드 IP 주소로 수정
    return 'http://10.46.9.8:8080';
  }

  /// 로그인 시도
  Future<bool> login(String id, String password) async {
    try {
      final url = Uri.parse('$_baseUrl/user/api/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userid': id, // 백엔드 사양에 맞춰 userid 사용
          'password': password
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        if (token != null) {
          await _saveToken(token);
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  /// 로그아웃
  Future<void> logout() async {
    await _storage.delete(key: _keyAccessToken);
  }

  /// 현재 로그인 되어 있는지 확인 (토큰 존재 여부)
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: _keyAccessToken);
    return token != null;
  }

  /// 토큰 가져오기 (API 호출 시 헤더에 넣을 때 사용)
  Future<String?> getToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  /// 내부 함수: 토큰 저장
  Future<void> _saveToken(String token) async {
    await _storage.write(key: _keyAccessToken, value: token);
  }

  /// 회원가입 (Mock)
  Future<bool> register({
    required String id,
    required String password,
    required String name,
    required String gender,
    required String birthDate,
  }) async {
    // TODO: 실제 서버 API 연동 필요
    /*
    final url = Uri.parse('$_baseUrl/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id': id, 
        'password': password, 
        'name': name,
        'gender': gender,
        'birthDate': birthDate,
      }),
    );
    return response.statusCode == 200 || response.statusCode == 201;
    */

    await Future.delayed(const Duration(milliseconds: 500));
    return true; // 일단 무조건 성공
  }
}
