import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/theme/app_theme.dart';
import 'core/constants/router/app_router.dart';
import 'data/models/repositories/movie_repository.dart';
import 'data/models/datasources/tmdb_api_service.dart';
import 'presentation/providers/movie_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/search_provider.dart';
import 'presentation/providers/favorites_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize API service
  final apiService = TMDBApiService();
  final movieRepository = MovieRepository(apiService: apiService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => MovieProvider(movieRepository)),
        ChangeNotifierProvider(create: (_) => SearchProvider(movieRepository)),
        ChangeNotifierProvider(
            create: (_) => FavoritesProvider()..initializeFavorites()),
      ],
      child: const MovieVerseApp(),
    ),
  );
}

class MovieVerseApp extends StatelessWidget {
  const MovieVerseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp.router(
          title: 'MovieVerse',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
