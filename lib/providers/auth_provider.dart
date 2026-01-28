import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  // 앱 시작 시 로그인 상태 확인
  Future<void> checkLoginStatus() async {
    _isAuthenticated = await _authService.isLoggedIn();
    notifyListeners();
  }

  Future<bool> login(String id, String password) async {
    final success = await _authService.login(id, password);
    if (success) {
      _isAuthenticated = true;
      notifyListeners();
    }
    return success;
  }

  Future<void> logout() async {
    await _authService.logout();
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<bool> register({
    required String id,
    required String password,
    required String name,
    required String gender,
    required String birthDate,
  }) async {
    return await _authService.register(
      id: id,
      password: password,
      name: name,
      gender: gender,
      birthDate: birthDate,
    );
  }
}
