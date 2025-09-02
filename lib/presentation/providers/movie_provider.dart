import 'package:flutter/material.dart';
import '../../data/models/movie_model.dart';
import '../../data/models/repositories/movie_repository.dart';
import '../../core/constants/errors/exceptions.dart';

enum MovieLoadingState {
  initial,
  loading,
  loaded,
  error,
}

class MovieProvider with ChangeNotifier {
  final MovieRepository _repository;

  MovieProvider(this._repository);

  // Loading states
  MovieLoadingState _trendingState = MovieLoadingState.initial;
  MovieLoadingState _nowPlayingState = MovieLoadingState.initial;
  MovieLoadingState _topRatedState = MovieLoadingState.initial;
  MovieLoadingState _upcomingState = MovieLoadingState.initial;
  MovieLoadingState _detailsState = MovieLoadingState.initial;

  // Movie lists
  List<Movie> _trendingMovies = [];
  List<Movie> _nowPlayingMovies = [];
  List<Movie> _topRatedMovies = [];
  List<Movie> _upcomingMovies = [];
  MovieDetails? _movieDetails;
  List<Cast> _movieCast = [];
  List<Crew> _movieCrew = [];
  List<MovieVideo> _movieVideos = [];

  // Error messages
  String _trendingError = '';
  String _nowPlayingError = '';
  String _topRatedError = '';
  String _upcomingError = '';
  String _detailsError = '';

  // Getters
  MovieLoadingState get trendingState => _trendingState;
  MovieLoadingState get nowPlayingState => _nowPlayingState;
  MovieLoadingState get topRatedState => _topRatedState;
  MovieLoadingState get upcomingState => _upcomingState;
  MovieLoadingState get detailsState => _detailsState;

  List<Movie> get trendingMovies => _trendingMovies;
  List<Movie> get nowPlayingMovies => _nowPlayingMovies;
  List<Movie> get topRatedMovies => _topRatedMovies;
  List<Movie> get upcomingMovies => _upcomingMovies;
  MovieDetails? get movieDetails => _movieDetails;
  List<Cast> get movieCast => _movieCast;
  List<Crew> get movieCrew => _movieCrew;
  List<MovieVideo> get movieVideos => _movieVideos;

  String get trendingError => _trendingError;
  String get nowPlayingError => _nowPlayingError;
  String get topRatedError => _topRatedError;
  String get upcomingError => _upcomingError;
  String get detailsError => _detailsError;

  // Get trending movies
  Future<void> getTrendingMovies() async {
    _trendingState = MovieLoadingState.loading;
    _trendingError = '';
    notifyListeners();

    try {
      _trendingMovies = await _repository.getTrendingMovies();
      _trendingState = MovieLoadingState.loaded;
    } catch (e) {
      _trendingState = MovieLoadingState.error;
      _trendingError = _getErrorMessage(e);
    }
    notifyListeners();
  }

  // Get now playing movies
  Future<void> getNowPlayingMovies() async {
    _nowPlayingState = MovieLoadingState.loading;
    _nowPlayingError = '';
    notifyListeners();

    try {
      _nowPlayingMovies = await _repository.getNowPlayingMovies();
      _nowPlayingState = MovieLoadingState.loaded;
    } catch (e) {
      _nowPlayingState = MovieLoadingState.error;
      _nowPlayingError = _getErrorMessage(e);
    }
    notifyListeners();
  }

  // Get top rated movies
  Future<void> getTopRatedMovies() async {
    _topRatedState = MovieLoadingState.loading;
    _topRatedError = '';
    notifyListeners();

    try {
      _topRatedMovies = await _repository.getTopRatedMovies();
      _topRatedState = MovieLoadingState.loaded;
    } catch (e) {
      _topRatedState = MovieLoadingState.error;
      _topRatedError = _getErrorMessage(e);
    }
    notifyListeners();
  }

  // Get upcoming movies
  Future<void> getUpcomingMovies() async {
    _upcomingState = MovieLoadingState.loading;
    _upcomingError = '';
    notifyListeners();

    try {
      _upcomingMovies = await _repository.getUpcomingMovies();
      _upcomingState = MovieLoadingState.loaded;
    } catch (e) {
      _upcomingState = MovieLoadingState.error;
      _upcomingError = _getErrorMessage(e);
    }
    notifyListeners();
  }

  // Load all home screen data
  Future<void> loadHomeData() async {
    await Future.wait([
      getTrendingMovies(),
      getNowPlayingMovies(),
      getTopRatedMovies(),
      getUpcomingMovies(),
    ]);
  }

  // Get movie details with credits and videos
  Future<void> getMovieDetails(int movieId) async {
    // Always clear data when loading a different movie
    if (_movieDetails?.id != movieId) {
      _movieDetails = null;
      _movieCast = [];
      _movieCrew = [];
      _movieVideos = [];
      _detailsState = MovieLoadingState.loading;
      _detailsError = '';
      notifyListeners();
    } else if (_detailsState == MovieLoadingState.loaded) {
      // Don't reload if it's the same movie and already loaded
      return;
    } else {
      _detailsState = MovieLoadingState.loading;
      _detailsError = '';
      notifyListeners();
    }

    try {
      // Load movie details, credits, and videos in parallel
      final results = await Future.wait([
        _repository.getMovieDetails(movieId),
        _repository.getMovieCredits(movieId),
        _repository.getMovieVideos(movieId),
      ]);

      _movieDetails = results[0] as MovieDetails;
      final credits = results[1] as Map<String, List<dynamic>>;
      _movieCast = credits['cast'] as List<Cast>;
      _movieCrew = credits['crew'] as List<Crew>;
      _movieVideos = results[2] as List<MovieVideo>;

      _detailsState = MovieLoadingState.loaded;
    } catch (e) {
      _detailsState = MovieLoadingState.error;
      _detailsError = _getErrorMessage(e);
    }
    notifyListeners();
  }

  // Get trailer for a movie
  MovieVideo? getMainTrailer() {
    if (_movieVideos.isEmpty) return null;

    // Try to find an official trailer first
    final officialTrailer = _movieVideos.firstWhere(
      (video) => video.isTrailer && video.isYouTube && video.official,
      orElse: () => _movieVideos.firstWhere(
        (video) => video.isTrailer && video.isYouTube,
        orElse: () => _movieVideos.first,
      ),
    );

    return officialTrailer;
  }

  // Get director from crew
  Crew? getDirector() {
    if (_movieCrew.isEmpty) return null;

    return _movieCrew.firstWhere(
      (crew) => crew.job.toLowerCase() == 'director',
      orElse: () => _movieCrew.first,
    );
  }

  // Retry methods
  Future<void> retryTrending() => getTrendingMovies();
  Future<void> retryNowPlaying() => getNowPlayingMovies();
  Future<void> retryTopRated() => getTopRatedMovies();
  Future<void> retryUpcoming() => getUpcomingMovies();
  Future<void> retryDetails(int movieId) => getMovieDetails(movieId);

  // Helper method to get user-friendly error messages
  String _getErrorMessage(dynamic error) {
    if (error is ApiException) {
      return error.message;
    } else if (error is NetworkException) {
      return 'Network error. Please check your connection and try again.';
    } else {
      return 'Something went wrong. Please try again.';
    }
  }

  // Clear movie details when leaving details screen
  void clearMovieDetails() {
    _movieDetails = null;
    _movieCast = [];
    _movieCrew = [];
    _movieVideos = [];
    _detailsState = MovieLoadingState.initial;
    _detailsError = '';
    notifyListeners();
  }

  // Additional methods for BrowseScreen compatibility
  bool get isLoading =>
      _trendingState == MovieLoadingState.loading ||
      _nowPlayingState == MovieLoadingState.loading ||
      _topRatedState == MovieLoadingState.loading ||
      _upcomingState == MovieLoadingState.loading;

  List<Movie> get popularMovies =>
      _nowPlayingMovies; // Use nowPlaying as popular

  // Fetch methods with consistent naming
  Future<void> fetchPopularMovies() => getNowPlayingMovies();

  Future<void> fetchTopRatedMovies() => getTopRatedMovies();

  Future<void> fetchUpcomingMovies() => getUpcomingMovies();

  // Discover movies with filters
  Future<void> discoverMovies({
    List<int> genreIds = const [],
    String sortBy = 'popularity.desc',
    int page = 1,
  }) async {
    _trendingState = MovieLoadingState.loading;
    _trendingError = '';
    notifyListeners();

    try {
      // For now, use trending as discover - can be enhanced later
      await getTrendingMovies();

      // Filter by genres if specified
      if (genreIds.isNotEmpty) {
        _trendingMovies = _trendingMovies.where((movie) {
          return movie.genreIds.any((id) => genreIds.contains(id));
        }).toList();
      }

      // Sort movies
      switch (sortBy) {
        case 'vote_average.desc':
          _trendingMovies
              .sort((a, b) => b.voteAverage.compareTo(a.voteAverage));
          break;
        case 'release_date.desc':
          _trendingMovies
              .sort((a, b) => b.releaseDate.compareTo(a.releaseDate));
          break;
        case 'title.asc':
          _trendingMovies.sort((a, b) => a.title.compareTo(b.title));
          break;
        default: // popularity.desc
          _trendingMovies.sort((a, b) => b.popularity.compareTo(a.popularity));
      }

      _trendingState = MovieLoadingState.loaded;
    } catch (error) {
      _trendingState = MovieLoadingState.error;
      _trendingError = _getErrorMessage(error);
    }

    notifyListeners();
  }
}
