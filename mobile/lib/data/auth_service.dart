import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/api_client.dart';

final authServiceProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthService(apiClient.client);
});

class AuthService {
  final Dio _dio;

  AuthService(this._dio);

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post('/users/login', data: {
        'email': email,
        'password': password,
      });
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('Connection error');
      }
    }
  }

  Future<Map<String, dynamic>> signup(String name, String email, String password, String passwordConfirm) async {
    try {
      final response = await _dio.post('/users/signup', data: {
        'name': name,
        'email': email,
        'password': password,
        'passwordConfirm': passwordConfirm,
      });
      return response.data;
    } on DioException catch (e) {
       if (e.response != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception('Connection error');
      }
    }
  }
}
