import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/api_client.dart';
import 'tour_model.dart';

final tourServiceProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TourService(apiClient.client);
});

class TourService {
  final Dio _dio;

  TourService(this._dio);

  Future<List<Tour>> getAllTours() async {
    try {
      final response = await _dio.get('/tours');
      final data = response.data['data']['tours'] as List;
      return data.map((e) => Tour.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load tours');
    }
  }

  Future<Tour> getTour(String id) async {
    try {
      final response = await _dio.get('/tours/$id');
      return Tour.fromJson(response.data['data']['tour']);
    } catch (e) {
      throw Exception('Failed to load tour');
    }
  }
}
