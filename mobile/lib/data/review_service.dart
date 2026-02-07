import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';
import 'review_model.dart';

final reviewServiceProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ReviewService(apiClient.client);
});

class ReviewService {
  final Dio _dio;

  ReviewService(this._dio);

  Future<List<Review>> getTourReviews(String tourId) async {
    try {
      final response = await _dio.get('/tours/$tourId/reviews');
      final data = response.data['data']['reviews'] as List;
      return data.map((e) => Review.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load reviews');
    }
  }

  Future<void> createReview(String tourId, String review, int rating) async {
    try {
      await _dio.post('/tours/$tourId/reviews', data: {
        'review': review,
        'rating': rating,
      });
    } catch (e) {
      throw Exception('Failed to create review');
    }
  }
}
