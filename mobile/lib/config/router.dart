import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/signup_screen.dart';
import '../features/tours/home_screen.dart';
import '../features/tours/tour_detail_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/admin/admin_dashboard_screen.dart';
import '../features/admin/create_tour_screen.dart';
import '../features/admin/edit_tour_screen.dart';
import '../features/profile/my_bookings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/tour/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return TourDetailScreen(tourId: id);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/my-bookings',
        builder: (context, state) => const MyBookingsScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/create-tour',
        builder: (context, state) => const CreateTourScreen(),
      ),
      GoRoute(
        path: '/admin/edit-tour/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return EditTourScreen(tourId: id);
        },
      ),
      // Add more routes here
    ],
  );
});
