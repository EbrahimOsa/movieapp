import '../datasources/tmdb_api_service.dart';
import '../movie_model.dart';
import '../../../core/constants/errors/exceptions.dart';

class MovieRepository {
  final TMDBApiService apiService;

  MovieRepository({required this.apiService});

  Future<List<Movie>> getTrendingMovies() async {
    try {
      return await apiService.getTrendingMovies();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw const NetworkException('Failed to load trending movies');
    }
  }

  Future<List<Movie>> getNowPlayingMovies() async {
    try {
      return await apiService.getNowPlayingMovies();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw const NetworkException('Failed to load now playing movies');
    }
  }

  Future<List<Movie>> getTopRatedMovies() async {
    try {
      return await apiService.getTopRatedMovies();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw const NetworkException('Failed to load top rated movies');
    }
  }

  Future<List<Movie>> getUpcomingMovies() async {
    try {
      return await apiService.getUpcomingMovies();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw const NetworkException('Failed to load upcoming movies');
    }
  }

  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    try {
      return await apiService.searchMovies(query, page: page);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw const NetworkException('Failed to search movies');
    }
  }

  Future<MovieDetails> getMovieDetails(int movieId) async {
    try {
      return await apiService.getMovieDetails(movieId);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw const NetworkException('Failed to load movie details');
    }
  }

  Future<Map<String, List<dynamic>>> getMovieCredits(int movieId) async {
    try {
      return await apiService.getMovieCredits(movieId);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw const NetworkException('Failed to load movie credits');
    }
  }

  Future<List<MovieVideo>> getMovieVideos(int movieId) async {
    try {
      return await apiService.getMovieVideos(movieId);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw const NetworkException('Failed to load movie videos');
    }
  }

  Future<List<Genre>> getMovieGenres() async {
    try {
      return await apiService.getMovieGenres();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw const NetworkException('Failed to load movie genres');
    }
  }
}
