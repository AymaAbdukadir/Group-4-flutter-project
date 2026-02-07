import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/booking_service.dart';
import '../../data/review_service.dart';
import '../../data/review_model.dart';
import '../../config/constants.dart';
import 'tour_controller.dart';

final tourReviewsProvider = FutureProvider.family<List<Review>, String>((ref, id) async {
  final reviewService = ref.watch(reviewServiceProvider);
  return reviewService.getTourReviews(id);
});

class TourDetailScreen extends ConsumerStatefulWidget {
  final String tourId;

  const TourDetailScreen({super.key, required this.tourId});

  @override
  ConsumerState<TourDetailScreen> createState() => _TourDetailScreenState();
}

class _TourDetailScreenState extends ConsumerState<TourDetailScreen> {
  final _reviewController = TextEditingController();
  int _selectedRating = 5;
  bool _isBooking = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tourAsyncValue = ref.watch(tourDetailProvider(widget.tourId));
    final reviewsAsyncValue = ref.watch(tourReviewsProvider(widget.tourId));

    return Scaffold(
      body: tourAsyncValue.when(
        data: (tour) => CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(tour.name),
                background: Image.network(
                  '${AppConstants.toursImageUrl}/${tour.imageCover}',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 100, color: Colors.grey),
                    );
                  },
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                 Padding(
                   padding: const EdgeInsets.all(20),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text(
                         'About ${tour.name}',
                         style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                       ),
                       const SizedBox(height: 10),
                       Text(tour.description, style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.5)),
                       const SizedBox(height: 25),
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                            _InfoChip(icon: Icons.calendar_today, label: '${tour.duration} days'),
                            _InfoChip(icon: Icons.group, label: '${tour.maxGroupSize} people'),
                            _InfoChip(icon: Icons.star, label: '${tour.ratingsAverage} / 5'),
                         ],
                       ),
                       const SizedBox(height: 30),
                       SizedBox(
                         width: double.infinity,
                         child: ElevatedButton(
                           onPressed: _isBooking ? null : () async {
                             setState(() => _isBooking = true);
                             try {
                               await ref.read(bookingServiceProvider).createBooking(tour.id, tour.price);
                               if (mounted) {
                                 ScaffoldMessenger.of(context).showSnackBar(
                                   const SnackBar(content: Text('Tour booked successfully! Check your profile.')),
                                 );
                               }
                             } catch (e) {
                               if (mounted) {
                                 ScaffoldMessenger.of(context).showSnackBar(
                                   SnackBar(content: Text('Error: $e')),
                                 );
                               }
                             } finally {
                               if (mounted) setState(() => _isBooking = false);
                             }
                           },
                           child: _isBooking 
                             ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                             : Text('Book Now for \$${tour.price}'),
                         ),
                       ),
                       const SizedBox(height: 40),
                       const Divider(),
                       const SizedBox(height: 20),
                       Text(
                         'Reviews',
                         style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                       ),
                       const SizedBox(height: 15),
                       
                       // Write a review section
                       Container(
                         padding: const EdgeInsets.all(16),
                         decoration: BoxDecoration(
                           color: Colors.grey[100],
                           borderRadius: BorderRadius.circular(12),
                         ),
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             const Text('Write a review', style: TextStyle(fontWeight: FontWeight.bold)),
                             const SizedBox(height: 8),
                             Row(
                               children: List.generate(5, (index) {
                                 return IconButton(
                                   icon: Icon(
                                     index < _selectedRating ? Icons.star : Icons.star_border,
                                     color: Colors.amber,
                                   ),
                                   onPressed: () => setState(() => _selectedRating = index + 1),
                                 );
                               }),
                             ),
                             TextField(
                               controller: _reviewController,
                               maxLines: 2,
                               decoration: const InputDecoration(
                                 hintText: 'Share your experience...',
                                 fillColor: Colors.white,
                               ),
                             ),
                             const SizedBox(height: 12),
                             Align(
                               alignment: Alignment.centerRight,
                               child: ElevatedButton(
                                 style: ElevatedButton.styleFrom(
                                   minimumSize: const Size(100, 40),
                                   padding: const EdgeInsets.symmetric(horizontal: 16),
                                 ),
                                 onPressed: () async {
                                   if (_reviewController.text.isEmpty) return;
                                   try {
                                     await ref.read(reviewServiceProvider).createReview(
                                       tour.id, 
                                       _reviewController.text, 
                                       _selectedRating
                                     );
                                     _reviewController.clear();
                                     ref.invalidate(tourReviewsProvider(widget.tourId));
                                     if (mounted) {
                                       ScaffoldMessenger.of(context).showSnackBar(
                                         const SnackBar(content: Text('Review submitted!')),
                                       );
                                     }
                                   } catch (e) {
                                      if (mounted) {
                                       ScaffoldMessenger.of(context).showSnackBar(
                                         SnackBar(content: Text('Error: $e')),
                                       );
                                     }
                                   }
                                 },
                                 child: const Text('Submit'),
                               ),
                             ),
                           ],
                         ),
                       ),
                       const SizedBox(height: 25),
                       
                       // Reviews list
                       reviewsAsyncValue.when(
                         data: (reviews) {
                           if (reviews.isEmpty) return const Text('No reviews yet. Be the first!');
                           return ListView.separated(
                             shrinkWrap: true,
                             physics: const NeverScrollableScrollPhysics(),
                             itemCount: reviews.length,
                             separatorBuilder: (context, index) => const SizedBox(height: 15),
                             itemBuilder: (context, index) {
                               final r = reviews[index];
                               return Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   Row(
                                     children: [
                                       Text(r.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                       const Spacer(),
                                       Row(
                                         children: List.generate(5, (i) => Icon(
                                           i < r.rating ? Icons.star : Icons.star_border,
                                           size: 14,
                                           color: Colors.amber,
                                         )),
                                       ),
                                     ],
                                   ),
                                   const SizedBox(height: 4),
                                   Text(r.review, style: TextStyle(color: Colors.grey[800])),
                                 ],
                               );
                             },
                           );
                         },
                         loading: () => const Center(child: CircularProgressIndicator()),
                         error: (err, stack) => Text('Error loading reviews: $err'),
                       ),
                       const SizedBox(height: 50),
                     ],
                   ),
                 ),
              ]),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(label),
      ],
    );
  }
}
