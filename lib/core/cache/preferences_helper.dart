import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/movie_model.dart';

class PreferencesHelper {
  static const String _favoriteMovieIdsKey = 'favorite_movie_ids';
  static const String _favoriteMoviesKey = 'favorite_movies';

  // Get favorite movie IDs
  static Future<List<int>> getFavoriteMovieIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final idsString = prefs.getStringList(_favoriteMovieIdsKey) ?? [];
      return idsString.map((id) => int.parse(id)).toList();
    } catch (e) {
      return [];
    }
  }

  // Save favorite movie IDs
  static Future<void> saveFavoriteMovieIds(List<int> movieIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final idsString = movieIds.map((id) => id.toString()).toList();
      await prefs.setStringList(_favoriteMovieIdsKey, idsString);
    } catch (e) {
      // Handle error silently
    }
  }

  // Get favorite movies data
  static Future<List<Movie>> getFavoriteMovies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final moviesJson = prefs.getStringList(_favoriteMoviesKey) ?? [];
      return moviesJson.map((movieString) {
        final movieMap = json.decode(movieString) as Map<String, dynamic>;
        return Movie.fromJson(movieMap);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Save favorite movies data
  static Future<void> saveFavoriteMovies(List<Movie> movies) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final moviesJson = movies.map((movie) {
        return json.encode(movie.toJson());
      }).toList();
      await prefs.setStringList(_favoriteMoviesKey, moviesJson);
    } catch (e) {
      // Handle error silently
    }
  }
}
