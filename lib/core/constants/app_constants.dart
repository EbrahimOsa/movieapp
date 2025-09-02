class AppConstants {
  // TMDB API
  static const String tmdbApiKey =
      '85ab13a2ceab7b05259fc886e272f016'; // Replace with your actual API key
  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const String tmdbImageBaseUrl = 'https://image.tmdb.org/t/p/w500';
  static const String tmdbBackdropBaseUrl =
      'https://image.tmdb.org/t/p/original';
  static const String tmdbYouTubeBaseUrl = 'https://www.youtube.com/watch?v=';

  // API Endpoints
  static const String trendingMovies = '/trending/movie/day';
  static const String nowPlayingMovies = '/movie/now_playing';
  static const String topRatedMovies = '/movie/top_rated';
  static const String upcomingMovies = '/movie/upcoming';
  static const String searchMovies = '/search/movie';
  static const String searchPeople = '/search/person';
  static const String personMovies = '/person/{person_id}/movie_credits';
  static const String movieDetails = '/movie';
  static const String movieGenres = '/genre/movie/list';
  static const String movieVideos = '/movie/{movie_id}/videos';
  static const String movieCredits = '/movie/{movie_id}/credits';

  // App Settings
  static const String appName = 'MovieVerse';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String themeKey = 'theme_mode';
  static const String favoritesKey = 'favorite_movies';
  static const String watchHistoryKey = 'watch_history';

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 4.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
}
