import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/auth_service.dart';
import '../../data/user_model.dart';

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(() {
  return AuthController();
});

// Provider to expose current user using NotifierProvider
class CurrentUserNotifier extends Notifier<User?> {
  @override
  User? build() => null;

  void setUser(User? user) {
    state = user;
  }
}

final currentUserProvider = NotifierProvider<CurrentUserNotifier, User?>(() {
  return CurrentUserNotifier();
});

class AuthController extends AsyncNotifier<void> {
  late final AuthService _authService;
  final _storage = const FlutterSecureStorage();

  @override
  FutureOr<void> build() {
    _authService = ref.watch(authServiceProvider);
    _loadUser();
  }

  Future<void> _loadUser() async {
    final userJson = await _storage.read(key: 'user');
    if (userJson != null) {
      final userData = jsonDecode(userJson);
      ref.read(currentUserProvider.notifier).setUser(User.fromJson(userData));
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final data = await _authService.login(email, password);
      final token = data['token'];
      final userData = data['user'];
      
      await _storage.write(key: 'jwt', value: token);
      await _storage.write(key: 'user', value: jsonEncode(userData));
      
      ref.read(currentUserProvider.notifier).setUser(User.fromJson(userData));
    });
  }

  Future<void> signup(String name, String email, String password, String passwordConfirm) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final data = await _authService.signup(name, email, password, passwordConfirm);
      final token = data['token'];
      final userData = data['user'];
      
      await _storage.write(key: 'jwt', value: token);
      await _storage.write(key: 'user', value: jsonEncode(userData));
      
      ref.read(currentUserProvider.notifier).setUser(User.fromJson(userData));
    });
  }
  
  Future<void> logout() async {
      await _storage.delete(key: 'jwt');
      await _storage.delete(key: 'user');
      ref.read(currentUserProvider.notifier).setUser(null);
  }
}

