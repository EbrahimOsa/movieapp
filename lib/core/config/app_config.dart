import '../constants/app_constants.dart';

class AppConfig {
  // استخدام API key من app_constants
  static String get apiKey => AppConstants.tmdbApiKey;

  static String get baseUrl => 'https://api.themoviedb.org/3';
  static String get imageBaseUrl => 'https://image.tmdb.org/t/p/w500';

  static Future<void> initialize() async {
    print('AppConfig initialized');
  }

  static bool get isValidated {
    return apiKey.isNotEmpty && apiKey != 'your_tmdb_api_key_here';
  }
}
