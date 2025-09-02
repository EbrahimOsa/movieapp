import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/errors/exceptions.dart';
import '../movie_model.dart';

class TMDBApiService {
  final http.Client _client = http.Client();

  // Base method for making API calls
  Future<Map<String, dynamic>> _makeRequest(String endpoint,
      {Map<String, String>? queryParams}) async {
    try {
      final uri = Uri.parse('${AppConstants.tmdbBaseUrl}$endpoint');
      final finalUri = uri.replace(queryParameters: {
        'api_key': AppConstants.tmdbApiKey,
        ...?queryParams,
      });

      final response = await _client.get(finalUri);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw const ApiException(
            'Invalid API key. Please check your TMDB API key.');
      } else if (response.statusCode == 404) {
        throw const ApiException('Resource not found.');
      } else {
        throw ApiException('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('Network error: $e');
    }
  }

  // Get trending movies
  Future<List<Movie>> getTrendingMovies() async {
    try {
      final data = await _makeRequest(AppConstants.trendingMovies);
      final List<dynamic> results = data['results'] ?? [];
      return results.map((json) => Movie.fromJson(json)).toList();
    } catch (e) {
      throw ApiException('Failed to load trending movies: $e');
    }
  }

  // Get now playing movies
  Future<List<Movie>> getNowPlayingMovies() async {
    try {
      final data = await _makeRequest(AppConstants.nowPlayingMovies);
      final List<dynamic> results = data['results'] ?? [];
      return results.map((json) => Movie.fromJson(json)).toList();
    } catch (e) {
      throw ApiException('Failed to load now playing movies: $e');
    }
  }

  // Get top rated movies
  Future<List<Movie>> getTopRatedMovies() async {
    try {
      final data = await _makeRequest(AppConstants.topRatedMovies);
      final List<dynamic> results = data['results'] ?? [];
      return results.map((json) => Movie.fromJson(json)).toList();
    } catch (e) {
      throw ApiException('Failed to load top rated movies: $e');
    }
  }

  // Get upcoming movies
  Future<List<Movie>> getUpcomingMovies() async {
    try {
      final data = await _makeRequest(AppConstants.upcomingMovies);
      final List<dynamic> results = data['results'] ?? [];
      return results.map((json) => Movie.fromJson(json)).toList();
    } catch (e) {
      throw ApiException('Failed to load upcoming movies: $e');
    }
  }

  // Search movies
  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    try {
      final data = await _makeRequest(
        AppConstants.searchMovies,
        queryParams: {
          'query': query,
          'page': page.toString(),
        },
      );
      final List<dynamic> results = data['results'] ?? [];
      return results.map((json) => Movie.fromJson(json)).toList();
    } catch (e) {
      throw ApiException('Failed to search movies: $e');
    }
  }

  // Get movie details
  Future<MovieDetails> getMovieDetails(int movieId) async {
    try {
      final data = await _makeRequest('${AppConstants.movieDetails}/$movieId');
      return MovieDetails.fromJson(data);
    } catch (e) {
      throw ApiException('Failed to load movie details: $e');
    }
  }

  // Get movie credits (cast and crew)
  Future<Map<String, List<dynamic>>> getMovieCredits(int movieId) async {
    try {
      final data =
          await _makeRequest('${AppConstants.movieDetails}/$movieId/credits');
      return {
        'cast': (data['cast'] as List<dynamic>?)
                ?.map((json) => Cast.fromJson(json))
                .toList() ??
            [],
        'crew': (data['crew'] as List<dynamic>?)
                ?.map((json) => Crew.fromJson(json))
                .toList() ??
            [],
      };
    } catch (e) {
      throw ApiException('Failed to load movie credits: $e');
    }
  }

  // Get movie videos (trailers)
  Future<List<MovieVideo>> getMovieVideos(int movieId) async {
    try {
      final data =
          await _makeRequest('${AppConstants.movieDetails}/$movieId/videos');
      final List<dynamic> results = data['results'] ?? [];
      return results.map((json) => MovieVideo.fromJson(json)).toList();
    } catch (e) {
      throw ApiException('Failed to load movie videos: $e');
    }
  }

  // Get movie genres
  Future<List<Genre>> getMovieGenres() async {
    try {
      final data = await _makeRequest(AppConstants.movieGenres);
      final List<dynamic> results = data['genres'] ?? [];
      return results.map((json) => Genre.fromJson(json)).toList();
    } catch (e) {
      throw ApiException('Failed to load movie genres: $e');
    }
  }

  // Dispose HTTP client
  void dispose() {
    _client.close();
  }
}
