import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/tour_service.dart';
import '../../data/tour_model.dart';

final toursProvider = FutureProvider<List<Tour>>((ref) async {
  final tourService = ref.watch(tourServiceProvider);
  return tourService.getAllTours();
});

final tourDetailProvider = FutureProvider.family<Tour, String>((ref, id) async {
  final tourService = ref.watch(tourServiceProvider);
  return tourService.getTour(id);
});
