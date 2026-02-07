import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/api_client.dart';

final adminTourServiceProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AdminTourService(apiClient.client);
});

class AdminTourService {
  final Dio _dio;

  AdminTourService(this._dio);

  Future<Map<String, dynamic>> createTour(Map<String, dynamic> tourData, {String? imagePath}) async {
    try {
      dynamic data;
      
      if (imagePath != null) {
        data = FormData.fromMap({
          ...tourData,
          'imageCover': await MultipartFile.fromFile(
            imagePath,
            filename: imagePath.split('/').last,
          ),
        });
      } else {
        data = tourData;
      }

      final response = await _dio.post('/tours', data: data);
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'Failed to create tour');
      } else {
        throw Exception('Connection error');
      }
    }
  }

  Future<Map<String, dynamic>> updateTour(String tourId, Map<String, dynamic> tourData, {String? imagePath}) async {
    try {
      dynamic data;
      
      if (imagePath != null) {
        data = FormData.fromMap({
          ...tourData,
          'imageCover': await MultipartFile.fromFile(
            imagePath,
            filename: imagePath.split('/').last,
          ),
        });
      } else {
        data = tourData;
      }

      final response = await _dio.patch('/tours/$tourId', data: data);
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'Failed to update tour');
      } else {
        throw Exception('Connection error');
      }
    }
  }

  Future<void> deleteTour(String tourId) async {
    try {
      await _dio.delete('/tours/$tourId');
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'Failed to delete tour');
      } else {
        throw Exception('Connection error');
      }
    }
  }
}
