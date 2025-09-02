import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/movie_model.dart';
import '../../core/constants/theme/app_theme.dart';
import '../providers/movie_provider.dart';
import '../providers/widgets/professional_movie_card.dart';
import '../providers/widgets/glassmorphism_app_bar.dart';
import '../widgets/error_widget.dart';

class CategoryMoviesScreen extends StatefulWidget {
  final String category;
  final String title;

  const CategoryMoviesScreen({
    super.key,
    required this.category,
    required this.title,
  });

  @override
  State<CategoryMoviesScreen> createState() => _CategoryMoviesScreenState();
}

class _CategoryMoviesScreenState extends State<CategoryMoviesScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _setupScrollListener();
    _loadInitialData();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (!_isLoadingMore) {
          _loadMoreData();
        }
      }
    });
  }

  void _loadInitialData() {
    final movieProvider = Provider.of<MovieProvider>(context, listen: false);

    switch (widget.category.toLowerCase()) {
      case 'trending':
        movieProvider.getTrendingMovies();
        break;
      case 'now_playing':
        movieProvider.getNowPlayingMovies();
        break;
      case 'top_rated':
        movieProvider.getTopRatedMovies();
        break;
      case 'upcoming':
        movieProvider.getUpcomingMovies();
        break;
      default:
        movieProvider.getTrendingMovies();
    }
  }

  void _loadMoreData() async {
    setState(() {
      _isLoadingMore = true;
    });

    final movieProvider = Provider.of<MovieProvider>(context, listen: false);

    try {
      switch (widget.category.toLowerCase()) {
        case 'trending':
          await movieProvider.getTrendingMovies();
          break;
        case 'now_playing':
          await movieProvider.getNowPlayingMovies();
          break;
        case 'top_rated':
          await movieProvider.getTopRatedMovies();
          break;
        case 'upcoming':
          await movieProvider.getUpcomingMovies();
          break;
      }
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  List<Movie> _getMoviesForCategory(MovieProvider provider) {
    switch (widget.category.toLowerCase()) {
      case 'trending':
        return provider.trendingMovies;
      case 'now_playing':
        return provider.nowPlayingMovies;
      case 'top_rated':
        return provider.topRatedMovies;
      case 'upcoming':
        return provider.upcomingMovies;
      default:
        return provider.trendingMovies;
    }
  }

  MovieLoadingState _getStateForCategory(MovieProvider provider) {
    switch (widget.category.toLowerCase()) {
      case 'trending':
        return provider.trendingState;
      case 'now_playing':
        return provider.nowPlayingState;
      case 'top_rated':
        return provider.topRatedState;
      case 'upcoming':
        return provider.upcomingState;
      default:
        return provider.trendingState;
    }
  }

  String? _getErrorForCategory(MovieProvider provider) {
    switch (widget.category.toLowerCase()) {
      case 'trending':
        return provider.trendingError;
      case 'now_playing':
        return provider.nowPlayingError;
      case 'top_rated':
        return provider.topRatedError;
      case 'upcoming':
        return provider.upcomingError;
      default:
        return provider.trendingError;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      body: Consumer<MovieProvider>(
        builder: (context, movieProvider, child) {
          final movies = _getMoviesForCategory(movieProvider);
          final state = _getStateForCategory(movieProvider);
          final error = _getErrorForCategory(movieProvider);

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Custom App Bar
              SliverAppBar(
                expandedHeight: 120,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: GlassmorphismAppBar(
                  title: widget.title,
                  showSearchIcon: false,
                  leading: IconButton(
                    onPressed: () => context.pop(),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.2)
                              : Colors.black.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
              ),

              // Content
              if (state == MovieLoadingState.loading && movies.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(
                            isDark
                                ? AppTheme.neonBlue
                                : AppTheme.secondaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading ${widget.title.toLowerCase()}...',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (state == MovieLoadingState.error)
                SliverFillRemaining(
                  child: CustomErrorWidget(
                    message: error ?? 'Something went wrong',
                    onRetry: _loadInitialData,
                  ),
                )
              else if (movies.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.movie_outlined,
                          size: 64,
                          color: isDark ? Colors.white30 : Colors.black26,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No movies found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index < movies.length) {
                          return ProfessionalMovieCard(
                            movie: movies[index],
                            onTap: () {
                              context.push(
                                '/movie/${movies[index].id}',
                                extra: movies[index],
                              );
                            },
                          );
                        } else if (_isLoadingMore) {
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(
                                isDark
                                    ? AppTheme.neonBlue
                                    : AppTheme.secondaryColor,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                      childCount: movies.length + (_isLoadingMore ? 1 : 0),
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                  ),
                ),

              // Load more indicator at bottom
              if (_isLoadingMore && movies.isNotEmpty)
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(
                          isDark ? AppTheme.neonBlue : AppTheme.secondaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
