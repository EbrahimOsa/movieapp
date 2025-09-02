// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:movieverse/main.dart';
import 'package:movieverse/presentation/providers/theme_provider.dart';
import 'package:movieverse/presentation/providers/movie_provider.dart';
import 'package:movieverse/presentation/providers/search_provider.dart';
import 'package:movieverse/presentation/providers/favorites_provider.dart';
import 'package:movieverse/data/models/repositories/movie_repository.dart';
import 'package:movieverse/data/models/datasources/tmdb_api_service.dart';

void main() {
  testWidgets('App starts without errors', (WidgetTester tester) async {
    // Create test providers
    final movieRepository = MovieRepository(apiService: TMDBApiService());

    // Build our app with proper providers and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => MovieProvider(movieRepository)),
          ChangeNotifierProvider(
              create: (_) => SearchProvider(movieRepository)),
          ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ],
        child: const MovieVerseApp(),
      ),
    );

    // Verify that the app builds without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
