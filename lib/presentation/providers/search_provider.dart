import 'package:flutter/material.dart';
import '../../data/models/movie_model.dart';
import '../../data/models/repositories/movie_repository.dart';
import '../../core/constants/errors/exceptions.dart';

class SearchProvider with ChangeNotifier {
  final MovieRepository _repository;

  SearchProvider(this._repository);

  bool _isLoading = false;
  List<Movie> _searchResults = [];
  String _searchQuery = '';
  String _errorMessage = '';
  bool _hasSearched = false;

  // Getters
  bool get isLoading => _isLoading;
  List<Movie> get searchResults => _searchResults;
  String get searchQuery => _searchQuery;
  String get errorMessage => _errorMessage;
  bool get hasSearched => _hasSearched;
  bool get hasResults => _searchResults.isNotEmpty;
  bool get showNoResults =>
      _hasSearched && _searchResults.isEmpty && !_isLoading;

  // Search movies with advanced filters
  Future<void> searchMovies(
    String query, {
    List<int> genres = const [],
    String? year,
    double minRating = 0.0,
    String sortBy = 'popularity',
  }) async {
    if (query.trim().isEmpty) {
      clearSearch();
      return;
    }

    _isLoading = true;
    _searchQuery = query.trim();
    _errorMessage = '';
    _hasSearched = true;
    notifyListeners();

    try {
      _searchResults = await _repository.searchMovies(_searchQuery);

      // Apply filters
      if (genres.isNotEmpty) {
        _searchResults = _searchResults.where((movie) {
          return movie.genreIds.any((genreId) => genres.contains(genreId));
        }).toList();
      }

      if (year != null && year.isNotEmpty) {
        _searchResults = _searchResults.where((movie) {
          return movie.releaseDate.startsWith(year);
        }).toList();
      }

      if (minRating > 0.0) {
        _searchResults = _searchResults.where((movie) {
          return movie.voteAverage >= minRating;
        }).toList();
      }

      // Apply sorting
      switch (sortBy) {
        case 'rating':
          _searchResults.sort((a, b) => b.voteAverage.compareTo(a.voteAverage));
          break;
        case 'release_date':
          _searchResults.sort((a, b) => b.releaseDate.compareTo(a.releaseDate));
          break;
        case 'title':
          _searchResults.sort((a, b) => a.title.compareTo(b.title));
          break;
        default: // popularity
          _searchResults.sort((a, b) => b.popularity.compareTo(a.popularity));
          break;
      }

      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      _searchResults = [];
    }
    notifyListeners();
  }

  // Clear search results
  void clearSearch() {
    _searchResults = [];
    _searchQuery = '';
    _errorMessage = '';
    _isLoading = false;
    _hasSearched = false;
    notifyListeners();
  }

  // Retry search
  Future<void> retrySearch() async {
    if (_searchQuery.isNotEmpty) {
      await searchMovies(_searchQuery);
    }
  }

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
}
