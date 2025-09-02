import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/models/movie_model.dart';
import '../../core/config/app_config.dart';

class RecommendationsProvider extends ChangeNotifier {
  List<Movie> _recommendations = [];
  List<Movie> _trending = [];
  List<Movie> _similarMovies = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Movie> get recommendations => _recommendations;
  List<Movie> get trending => _trending;
  List<Movie> get similarMovies => _similarMovies;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Base URLs
  final String _baseUrl = 'https://api.themoviedb.org/3';

  // Get API key - fallback method
  String get _apiKey {
    try {
      return AppConfig.apiKey;
    } catch (e) {
      // Fallback - should be replaced with proper config
      return '4b5db5c2b6b6d3b3f2a9d6e7b2c3d4e5'; // Your API key here
    }
  }

  // Get personalized recommendations based on user's viewing history
  Future<void> getPersonalizedRecommendations({
    List<int> favoriteGenres = const [],
    List<int> watchedMovies = const [],
  }) async {
    _setLoading(true);
    _error = null;

    try {
      List<Movie> allRecommendations = [];

      // Get trending movies
      await getTrendingMovies();
      allRecommendations.addAll(_trending.take(5));

      // Get popular movies from favorite genres
      if (favoriteGenres.isNotEmpty) {
        for (int genreId in favoriteGenres.take(3)) {
          final genreMovies = await _getMoviesByGenre(genreId);
          allRecommendations.addAll(genreMovies.take(3));
        }
      }

      // Get similar movies to watched ones
      if (watchedMovies.isNotEmpty) {
        for (int movieId in watchedMovies.take(3)) {
          final similar = await getSimilarMovies(movieId);
          allRecommendations.addAll(similar.take(2));
        }
      }

      // Remove duplicates and limit
      final uniqueMovies = <int, Movie>{};
      for (var movie in allRecommendations) {
        uniqueMovies[movie.id] = movie;
      }

      _recommendations = uniqueMovies.values.take(20).toList();

      // Sort by popularity and rating
      _recommendations.sort((a, b) {
        double scoreA = (a.voteAverage * 0.7) + (a.popularity * 0.3);
        double scoreB = (b.voteAverage * 0.7) + (b.popularity * 0.3);
        return scoreB.compareTo(scoreA);
      });
    } catch (e) {
      _error = 'Failed to get recommendations: $e';
    }

    _setLoading(false);
  }

  // Get trending movies
  Future<void> getTrendingMovies() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/trending/movie/week?api_key=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _trending = (data['results'] as List)
            .map((movieData) => Movie.fromJson(movieData))
            .toList();
      } else {
        throw Exception('Failed to load trending movies');
      }
    } catch (e) {
      _error = 'Failed to get trending movies: $e';
    }
  }

  // Get similar movies
  Future<List<Movie>> getSimilarMovies(int movieId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/movie/$movieId/similar?api_key=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final movies = (data['results'] as List)
            .map((movieData) => Movie.fromJson(movieData))
            .toList();

        if (_similarMovies.isNotEmpty && movieId == _similarMovies.first.id) {
          _similarMovies = movies;
          notifyListeners();
        }

        return movies;
      } else {
        throw Exception('Failed to load similar movies');
      }
    } catch (e) {
      _error = 'Failed to get similar movies: $e';
      return [];
    }
  }

  // Get movies by genre
  Future<List<Movie>> _getMoviesByGenre(int genreId) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/discover/movie?api_key=$_apiKey&with_genres=$genreId&sort_by=popularity.desc',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['results'] as List)
            .map((movieData) => Movie.fromJson(movieData))
            .toList();
      } else {
        throw Exception('Failed to load genre movies');
      }
    } catch (e) {
      throw Exception('Failed to get movies by genre: $e');
    }
  }

  // Get recommendations based on a specific movie
  Future<void> getMovieRecommendations(int movieId) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/movie/$movieId/recommendations?api_key=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _recommendations = (data['results'] as List)
            .map((movieData) => Movie.fromJson(movieData))
            .toList();
      } else {
        throw Exception('Failed to load movie recommendations');
      }
    } catch (e) {
      _error = 'Failed to get movie recommendations: $e';
    }

    _setLoading(false);
  }

  // Clear recommendations
  void clearRecommendations() {
    _recommendations.clear();
    _trending.clear();
    _similarMovies.clear();
    _error = null;
    notifyListeners();
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}

// Recommendation algorithms
class RecommendationEngine {
  // Calculate similarity between two movies based on genres and ratings
  static double calculateSimilarity(Movie movie1, Movie movie2) {
    // Genre similarity (0-1)
    final commonGenres =
        movie1.genreIds.toSet().intersection(movie2.genreIds.toSet()).length;
    final totalGenres =
        movie1.genreIds.toSet().union(movie2.genreIds.toSet()).length;
    final genreSimilarity = totalGenres > 0 ? commonGenres / totalGenres : 0.0;

    // Rating similarity (0-1)
    final ratingDiff = (movie1.voteAverage - movie2.voteAverage).abs();
    final ratingSimilarity = 1.0 - (ratingDiff / 10.0);

    // Popularity similarity (0-1)
    final popularityDiff = (movie1.popularity - movie2.popularity).abs();
    final maxPopularity =
        [movie1.popularity, movie2.popularity].reduce((a, b) => a > b ? a : b);
    final popularitySimilarity =
        maxPopularity > 0 ? 1.0 - (popularityDiff / maxPopularity) : 0.0;

    // Weighted combination
    return (genreSimilarity * 0.5) +
        (ratingSimilarity * 0.3) +
        (popularitySimilarity * 0.2);
  }

  // Get content-based recommendations
  static List<Movie> getContentBasedRecommendations(
      Movie targetMovie, List<Movie> moviePool,
      {int limit = 10}) {
    final recommendations = <MovieSimilarity>[];

    for (final movie in moviePool) {
      if (movie.id != targetMovie.id) {
        final similarity = calculateSimilarity(targetMovie, movie);
        recommendations.add(MovieSimilarity(movie, similarity));
      }
    }

    // Sort by similarity and take top results
    recommendations.sort((a, b) => b.similarity.compareTo(a.similarity));
    return recommendations.take(limit).map((rec) => rec.movie).toList();
  }

  // Get hybrid recommendations combining multiple signals
  static List<Movie> getHybridRecommendations({
    required List<Movie> favoriteMovies,
    required List<Movie> moviePool,
    required List<int> favoriteGenres,
    int limit = 15,
  }) {
    final recommendations = <MovieScore>[];

    for (final movie in moviePool) {
      if (!favoriteMovies.any((fav) => fav.id == movie.id)) {
        double score = 0.0;

        // Content-based score
        if (favoriteMovies.isNotEmpty) {
          final similarities = favoriteMovies
              .map((fav) => calculateSimilarity(fav, movie))
              .toList();
          final avgSimilarity =
              similarities.reduce((a, b) => a + b) / similarities.length;
          score += avgSimilarity * 0.4;
        }

        // Genre preference score
        if (favoriteGenres.isNotEmpty) {
          final genreScore =
              movie.genreIds.where(favoriteGenres.contains).length /
                  movie.genreIds.length;
          score += genreScore * 0.3;
        }

        // Quality score (rating and popularity)
        final normalizedRating = movie.voteAverage / 10.0;
        final normalizedPopularity =
            movie.popularity / 1000.0; // Normalize to 0-1 range
        score += (normalizedRating * 0.2) + (normalizedPopularity * 0.1);

        recommendations.add(MovieScore(movie, score));
      }
    }

    // Sort by score and return top results
    recommendations.sort((a, b) => b.score.compareTo(a.score));
    return recommendations.take(limit).map((rec) => rec.movie).toList();
  }
}

// Helper classes
class MovieSimilarity {
  final Movie movie;
  final double similarity;

  MovieSimilarity(this.movie, this.similarity);
}

class MovieScore {
  final Movie movie;
  final double score;

  MovieScore(this.movie, this.score);
}
