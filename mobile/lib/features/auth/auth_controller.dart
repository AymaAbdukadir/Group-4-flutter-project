import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/auth_service.dart';

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(() {
  return AuthController();
});

class AuthController extends AsyncNotifier<void> {
  late final AuthService _authService;
  final _storage = const FlutterSecureStorage();

  @override
  FutureOr<void> build() {
    _authService = ref.watch(authServiceProvider);
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final data = await _authService.login(email, password);
      final token = data['token'];
      await _storage.write(key: 'jwt', value: token);
    });
  }

  Future<void> signup(String name, String email, String password, String passwordConfirm) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final data = await _authService.signup(name, email, password, passwordConfirm);
      final token = data['token'];
      await _storage.write(key: 'jwt', value: token);
    });
  }
  
  Future<void> logout() async {
      await _storage.delete(key: 'jwt');
  }
}
