import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../presentation/screens/home_screen.dart';
import '../../../presentation/screens/movie_details_screen.dart';
import '../../../presentation/screens/enhanced_search_screen.dart';
import '../../../presentation/screens/favorites_screen.dart';
import '../../../data/models/movie_model.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/home',
    routes: [
      // Home Screen (as root)
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),

      // Home Screen (explicit)
      GoRoute(
        path: '/home',
        name: 'home_explicit',
        builder: (context, state) => const HomeScreen(),
      ),

      // Movie Details Screen
      GoRoute(
        path: '/movie/:id',
        name: 'movieDetails',
        builder: (context, state) {
          final movieId = int.parse(state.pathParameters['id']!);
          final movie = state.extra as Movie?;
          return MovieDetailsScreen(
            movieId: movieId,
            movie: movie,
          );
        },
      ),

      // Search Screen
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const EnhancedSearchScreen(),
      ),

      // Favorites Screen
      GoRoute(
        path: '/favorites',
        name: 'favorites',
        builder: (context, state) => const FavoritesScreen(),
      ),
    ],

    // Error handling
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page Not Found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'The page you are looking for does not exist.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
