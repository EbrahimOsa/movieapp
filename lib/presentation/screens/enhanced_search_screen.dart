import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../providers/search_provider.dart';
import '../providers/widgets/movie_card.dart';
import '../providers/widgets/shimmer_loading.dart';
import '../providers/widgets/genre_filter.dart';

class EnhancedSearchScreen extends StatefulWidget {
  const EnhancedSearchScreen({super.key});

  @override
  State<EnhancedSearchScreen> createState() => _EnhancedSearchScreenState();
}

class _EnhancedSearchScreenState extends State<EnhancedSearchScreen>
    with TickerProviderStateMixin {
  late TextEditingController _searchController;
  late AnimationController _animationController;
  final FocusNode _focusNode = FocusNode();

  Timer? _debounceTimer;
  bool _showFilters = false;

  // Recent searches and live suggestions
  List<String> _liveSuggestions = [];
  bool _showSuggestions = false;

  // Filter variables
  List<GenreModel> _availableGenres = [];
  final List<int> _selectedGenres =
      []; // إزالة final لأننا نحتاج لتعديل القائمة
  String _selectedYear = 'All Years';
  double _minRating = 0.0;
  String _sortBy = 'popularity';
  String _searchType = 'movies';

  // Years list
  final List<String> _years = [
    'All Years',
    '2024',
    '2023',
    '2022',
    '2021',
    '2020',
    '2019',
    '2018',
  ];

  // تم حذف Popular suggestions لتبسيط التجربة

  // تم حذف Trending searches لتبسيط التجربة

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _loadGenres();
    _loadRecentSearches();

    // Add focus listener for suggestions
    _focusNode.addListener(_onFocusChanged);

    // Auto focus search bar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    _focusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadGenres() async {
    try {
      _availableGenres = MovieGenres.predefined.take(8).toList();
      setState(() {});
    } catch (e) {
      debugPrint('Error loading genres: $e');
    }
  }

  void _loadRecentSearches() {
    // لا نحفظ عمليات البحث السابقة
  }

  void _saveRecentSearch(String query) {
    // لا نحفظ عمليات البحث
    return;
  }

  void _onSearchChanged(String query) {
    if (query.trim().isEmpty) {
      context.read<SearchProvider>().clearSearch();
      _animationController.reverse();
      setState(() {
        _showSuggestions = false;
        _liveSuggestions.clear();
      });
      return;
    }

    // Show live suggestions
    _updateLiveSuggestions(query);

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query);
    });
  }

  void _updateLiveSuggestions(String query) {
    // لا نعرض أي اقتراحات - تبسيط كامل
    setState(() {
      _liveSuggestions = [];
      _showSuggestions = false;
    });
  }

  void _performSearch(String query) {
    // تطبيق البحث حسب النوع المحدد
    switch (_searchType) {
      case 'movies':
        context.read<SearchProvider>().searchMovies(
              query,
              genres: _selectedGenres,
              year: _selectedYear == 'All Years' ? null : _selectedYear,
              minRating: _minRating,
              sortBy: _sortBy,
            );
        break;
      case 'actors':
        // البحث في أفلام الممثل
        context.read<SearchProvider>().searchMoviesByActor(query);
        break;
      case 'all':
      default:
        // البحث العام
        context.read<SearchProvider>().searchMovies(
              query,
              genres: _selectedGenres,
              year: _selectedYear == 'All Years' ? null : _selectedYear,
              minRating: _minRating,
              sortBy: _sortBy,
            );
        break;
    }
    _animationController.forward();
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().isNotEmpty) {
      _focusNode.unfocus();
      _performSearch(query);
      _saveRecentSearch(query);
      setState(() {
        _showSuggestions = false;
      });
    }
  }

  void _onSuggestionSelected(String suggestion) {
    _searchController.text = suggestion;
    _focusNode.unfocus();
    _performSearch(suggestion);
    _saveRecentSearch(suggestion);
    setState(() {
      _showSuggestions = false;
    });
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      if (_searchController.text.isNotEmpty) {
        _updateLiveSuggestions(_searchController.text);
      } else {
        // إخفاء الاقتراحات عند التركيز بدون نص
        setState(() {
          _liveSuggestions = [];
          _showSuggestions = false;
        });
      }
    } else {
      // إخفاء الاقتراحات عند فقدان التركيز
      Timer(const Duration(milliseconds: 150), () {
        if (mounted) {
          setState(() {
            _showSuggestions = false;
          });
        }
      });
    }
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });
  }

  void _applyFilters() {
    if (_searchController.text.isNotEmpty) {
      _performSearch(_searchController.text);
    }
    _toggleFilters();
  }

  void _clearFilters() {
    setState(() {
      _selectedGenres.clear();
      _selectedYear = 'All Years';
      _minRating = 0.0;
      _sortBy = 'popularity';
    });

    if (_searchController.text.isNotEmpty) {
      _performSearch(_searchController.text);
    }
  }

  String _getHintText() {
    switch (_searchType) {
      case 'movies':
        return 'Search for movies...';
      case 'actors':
        return 'Search for actors...';
      case 'all':
      default:
        return 'Search movies, actors, genres...';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            // Close suggestions and unfocus when tapping outside
            if (_showSuggestions || _focusNode.hasFocus) {
              _focusNode.unfocus();
              setState(() {
                _showSuggestions = false;
              });
            }
          },
          child: Stack(
            children: [
              Column(
                children: [
                  _buildHeader(),
                  if (_showFilters && _searchType != 'actors')
                    _buildFiltersSection(),
                  if (_searchType != 'actors') _buildActiveFilters(),
                  Expanded(child: _buildContent()),
                ],
              ),
              // Live suggestions overlay
              if (_showSuggestions) _buildSuggestionsOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(
        children: [
          // Header with back button and search bar
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(12),
                  minimumSize: const Size(48, 48),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(child: _buildSearchInput()),
            ],
          ),
          const SizedBox(height: 16),
          _buildSearchTabs(),
        ],
      ),
    );
  }

  Widget _buildSearchInput() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: _focusNode.hasFocus
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _focusNode,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
        decoration: InputDecoration(
          hintText: _getHintText(),
          hintStyle: TextStyle(
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Container(
            padding: const EdgeInsets.only(left: 16, right: 12),
            child: Icon(
              Icons.search_rounded,
              size: 22,
              color: _focusNode.hasFocus
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 50,
            minHeight: 22,
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_searchController.text.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(right: 4),
                    child: IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                      onPressed: () {
                        _searchController.clear();
                        context.read<SearchProvider>().clearSearch();
                        _animationController.reverse();
                        setState(() {
                          _showSuggestions = false;
                          _liveSuggestions.clear();
                        });
                        // Show trending suggestions when cleared and focused
                        if (_focusNode.hasFocus) {
                          _onFocusChanged();
                        }
                      },
                      style: IconButton.styleFrom(
                        padding: const EdgeInsets.all(6),
                        minimumSize: const Size(32, 32),
                      ),
                    ),
                  ),
                // إخفاء زر الفلاتر عند البحث في الممثلين
                if (_searchType != 'actors')
                  Container(
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      color: _showFilters
                          ? Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.tune_rounded,
                        size: 20,
                        color: _showFilters
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                      ),
                      onPressed: _toggleFilters,
                      style: IconButton.styleFrom(
                        padding: const EdgeInsets.all(6),
                        minimumSize: const Size(32, 32),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 14,
          ),
          isDense: false,
        ),
        onChanged: _onSearchChanged,
        onSubmitted: _onSearchSubmitted,
        textInputAction: TextInputAction.search,
      ),
    );
  }

  Widget _buildSearchTabs() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildSearchTab('All', 'all'),
          const SizedBox(width: 12),
          _buildSearchTab('Movies', 'movies'),
          const SizedBox(width: 12),
          _buildSearchTab('Actors', 'actors'),
        ],
      ),
    );
  }

  Widget _buildSearchTab(String title, String type) {
    final isSelected = _searchType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          // إضافة haptic feedback
          HapticFeedback.lightImpact();
          setState(() {
            _searchType = type;
          });
          // إعادة البحث إذا كان هناك نص مكتوب
          if (_searchController.text.isNotEmpty) {
            _performSearch(_searchController.text);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: 40,
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(20),
            border: isSelected
                ? null
                : Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.2),
                    width: 1.5,
                  ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 0,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.8),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
              ),
              child: Text(title),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFiltersSection() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.tune_rounded,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Advanced Filters',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              TextButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.clear_all_rounded, size: 18),
                label: const Text('Clear'),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Genres Section
          _buildFilterSection(
            title: 'Movie Genres',
            icon: Icons.category_rounded,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableGenres.map((genre) {
                final isSelected = _selectedGenres.contains(genre.id);
                return _buildGenreChip(genre, isSelected);
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),

          // Year and Rating Row
          Row(
            children: [
              // Year Filter
              Expanded(
                child: _buildFilterSection(
                  title: 'Release Year',
                  icon: Icons.calendar_today_rounded,
                  child: _buildYearDropdown(),
                ),
              ),
              const SizedBox(width: 16),
              // Rating Filter
              Expanded(
                flex: 2,
                child: _buildFilterSection(
                  title: 'Minimum Rating',
                  icon: Icons.star_rounded,
                  child: _buildRatingSlider(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Apply Button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _applyFilters,
              icon: const Icon(Icons.search_rounded),
              label: const Text('Apply Filters'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for filters
  Widget _buildFilterSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildGenreChip(GenreModel genre, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: FilterChip(
        label: Text(
          genre.name,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            if (selected) {
              _selectedGenres.add(genre.id);
            } else {
              _selectedGenres.remove(genre.id);
            }
          });
        },
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedColor: Theme.of(context).colorScheme.primaryContainer,
        checkmarkColor: Theme.of(context).colorScheme.primary,
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          width: isSelected ? 1.5 : 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _buildYearDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedYear,
          isDense: true,
          items: _years.map((year) {
            return DropdownMenuItem<String>(
              value: year,
              child: Text(
                year,
                style: const TextStyle(fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedYear = value ?? 'All Years';
            });
          },
        ),
      ),
    );
  }

  Widget _buildRatingSlider() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _minRating == 0.0
                  ? 'Any Rating'
                  : '${_minRating.toStringAsFixed(1)}+',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star_rounded,
                  size: 16,
                  color: Colors.amber,
                ),
                const SizedBox(width: 2),
                Text(
                  _minRating.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
          ),
          child: Slider(
            value: _minRating,
            min: 0.0,
            max: 10.0,
            divisions: 20,
            onChanged: (value) {
              setState(() {
                _minRating = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActiveFilters() {
    final hasActiveFilters = _selectedGenres.isNotEmpty ||
        _selectedYear != 'All Years' ||
        _minRating > 0.0;

    if (!hasActiveFilters) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                'Active Filters',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.8),
                    ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _clearFilters,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Genre filters
                ..._selectedGenres.map((genreId) {
                  final genre = _availableGenres.firstWhere(
                    (g) => g.id == genreId,
                    orElse: () =>
                        GenreModel(id: genreId, name: 'Unknown', emoji: '❓'),
                  );
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: Chip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(genre.emoji),
                          const SizedBox(width: 4),
                          Text(genre.name),
                        ],
                      ),
                      onDeleted: () {
                        setState(() {
                          _selectedGenres.remove(genreId);
                        });
                        if (_searchController.text.isNotEmpty) {
                          _performSearch(_searchController.text);
                        }
                      },
                      visualDensity: VisualDensity.compact,
                    ),
                  );
                }),

                // Year filter
                if (_selectedYear != 'All Years')
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: Chip(
                      label: Text(_selectedYear),
                      onDeleted: () {
                        setState(() {
                          _selectedYear = 'All Years';
                        });
                        if (_searchController.text.isNotEmpty) {
                          _performSearch(_searchController.text);
                        }
                      },
                      visualDensity: VisualDensity.compact,
                    ),
                  ),

                // Rating filter
                if (_minRating > 0.0)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: Chip(
                      label: Text('Rating: ${_minRating.toStringAsFixed(1)}+'),
                      onDeleted: () {
                        setState(() {
                          _minRating = 0.0;
                        });
                        if (_searchController.text.isNotEmpty) {
                          _performSearch(_searchController.text);
                        }
                      },
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, child) {
        if (searchProvider.isLoading) {
          return _buildLoadingState();
        } else if (searchProvider.errorMessage.isNotEmpty) {
          return _buildErrorState(searchProvider);
        } else if (searchProvider.showNoResults) {
          return _buildNoResultsState();
        } else if (searchProvider.hasResults) {
          return _buildSearchResults(searchProvider);
        } else {
          return _buildInitialState();
        }
      },
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: 8,
        itemBuilder: (context, index) {
          return const ShimmerLoading(
            width: double.infinity,
            height: double.infinity,
          );
        },
      ),
    );
  }

  Widget _buildErrorState(SearchProvider searchProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              searchProvider.errorMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_searchController.text.isNotEmpty) {
                  _performSearch(_searchController.text);
                }
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Try different keywords or adjust filters',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(SearchProvider searchProvider) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search type indicator
              if (_searchType == 'actors')
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person_rounded,
                        size: 16,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Movies by "${searchProvider.searchQuery}"',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
              // Results count
              Row(
                children: [
                  Text(
                    '${searchProvider.searchResults.length} results',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.7),
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: searchProvider.searchResults.length,
              itemBuilder: (context, index) {
                return MovieCard(
                  movie: searchProvider.searchResults[index],
                  width: double.infinity,
                  height: double.infinity,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInitialState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search illustration
          Center(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withValues(alpha: 0.3),
                    Theme.of(context)
                        .colorScheme
                        .secondaryContainer
                        .withValues(alpha: 0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.movie_filter_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Advanced Movie Search',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Find movies by genre, year, rating and more',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsOverlay() {
    return Positioned(
      top: 120, // Adjust based on header height
      left: 16,
      right: 16,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 400),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: _searchController.text.isEmpty
              ? _buildTrendingSuggestions()
              : _buildSearchSuggestions(),
        ),
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _liveSuggestions.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
      ),
      itemBuilder: (context, index) {
        final suggestion = _liveSuggestions[index];

        return ListTile(
          dense: true,
          leading: Icon(
            Icons.search,
            size: 20,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          title: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                  ),
              children: _highlightMatch(suggestion, _searchController.text),
            ),
          ),
          trailing: Icon(
            Icons.call_made,
            size: 16,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          onTap: () => _onSuggestionSelected(suggestion),
        );
      },
    );
  }

  Widget _buildTrendingSuggestions() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.search_rounded,
                size: 56,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Discover Movies',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Search for your favorite movies, actors,\nand discover new cinema experiences',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                    height: 1.6,
                    fontSize: 16,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<TextSpan> _highlightMatch(String text, String query) {
    final spans = <TextSpan>[];
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();

    if (lowerQuery.isEmpty) {
      spans.add(TextSpan(
        text: text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14),
      ));
      return spans;
    }

    int start = 0;
    int index = lowerText.indexOf(lowerQuery);

    while (index >= 0) {
      // Add text before match
      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14),
        ));
      }

      // Add highlighted match
      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ));

      start = index + query.length;
      index = lowerText.indexOf(lowerQuery, start);
    }

    // Add remaining text
    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14),
      ));
    }

    return spans;
  }
}
