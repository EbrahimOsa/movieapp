import 'package:flutter/material.dart';
import '../../data/models/movie_model.dart';
import '../../core/cache/preferences_helper.dart';

class FavoritesProvider with ChangeNotifier {
  final Set<int> _favoriteMovieIds = <int>{};
  final Map<int, Movie> _favoriteMovies = <int, Movie>{};
  bool _isLoading = false;

  // Getters
  Set<int> get favoriteMovieIds => Set.unmodifiable(_favoriteMovieIds);
  List<Movie> get favoriteMovies => _favoriteMovies.values.toList();
  bool get isLoading => _isLoading;
  int get favoriteCount => _favoriteMovieIds.length;

  // Initialize favorites from local storage
  Future<void> initializeFavorites() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load favorite IDs from local storage
      final savedIds = await PreferencesHelper.getFavoriteMovieIds();
      _favoriteMovieIds.addAll(savedIds);

      // Load favorite movies data from local storage
      final savedMovies = await PreferencesHelper.getFavoriteMovies();
      for (final movie in savedMovies) {
        _favoriteMovies[movie.id] = movie;
      }
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check if movie is favorite
  bool isFavorite(int movieId) {
    return _favoriteMovieIds.contains(movieId);
  }

  // Add movie to favorites
  Future<void> addToFavorites(Movie movie) async {
    if (_favoriteMovieIds.contains(movie.id)) return;

    _favoriteMovieIds.add(movie.id);
    _favoriteMovies[movie.id] = movie;

    // Save to local storage
    await _saveFavorites();

    notifyListeners();
  }

  // Remove movie from favorites
  Future<void> removeFromFavorites(int movieId) async {
    if (!_favoriteMovieIds.contains(movieId)) return;

    _favoriteMovieIds.remove(movieId);
    _favoriteMovies.remove(movieId);

    // Save to local storage
    await _saveFavorites();

    notifyListeners();
  }

  // Toggle favorite status
  Future<void> toggleFavorite(Movie movie) async {
    if (isFavorite(movie.id)) {
      await removeFromFavorites(movie.id);
    } else {
      await addToFavorites(movie);
    }
  }

  // Clear all favorites
  Future<void> clearFavorites() async {
    _favoriteMovieIds.clear();
    _favoriteMovies.clear();

    await _saveFavorites();

    notifyListeners();
  }

  // Private method to save favorites to local storage
  Future<void> _saveFavorites() async {
    try {
      await PreferencesHelper.saveFavoriteMovieIds(_favoriteMovieIds.toList());
      await PreferencesHelper.saveFavoriteMovies(
          _favoriteMovies.values.toList());
    } catch (e) {
      debugPrint('Error saving favorites: $e');
    }
  }
}
