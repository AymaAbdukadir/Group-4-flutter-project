import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';
import 'booking_model.dart';

final bookingServiceProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return BookingService(apiClient.client);
});

class BookingService {
  final Dio _dio;

  BookingService(this._dio);

  Future<List<Booking>> getMyBookings() async {
    try {
      final response = await _dio.get('/bookings');
      final data = response.data['data']['bookings'] as List;
      return data.map((e) => Booking.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load bookings');
    }
  }

  Future<void> createBooking(String tourId, double price) async {
    try {
      await _dio.post('/bookings', data: {
        'tour': tourId,
        'price': price,
      });
    } catch (e) {
      throw Exception('Failed to create booking');
    }
  }
}
