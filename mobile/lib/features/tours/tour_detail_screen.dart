import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tour_controller.dart';

class TourDetailScreen extends ConsumerWidget {
  final String tourId;

  const TourDetailScreen({super.key, required this.tourId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tourAsyncValue = ref.watch(tourDetailProvider(tourId));

    return Scaffold(
      body: tourAsyncValue.when(
        data: (tour) => CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(tour.name),
                background: Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, size: 100, color: Colors.grey),
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
                         style: Theme.of(context).textTheme.headlineSmall,
                       ),
                       const SizedBox(height: 10),
                       Text(tour.description),
                       const SizedBox(height: 20),
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
                           onPressed: () {
                             // Implement Booking
                             ScaffoldMessenger.of(context).showSnackBar(
                               const SnackBar(content: Text('Booking feature coming soon!')),
                             );
                           },
                           child: const Text('Book Now'),
                         ),
                       ),
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
