import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../providers/movie_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/widgets/enhanced_movie_section.dart';
import '../providers/widgets/glassmorphism_app_bar.dart';
import '../providers/widgets/hero_banner.dart';
import '../providers/widgets/animated_bottom_nav_bar.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _backgroundController;
  late Animation<double> _backgroundAnimation;

  // Bottom Navigation Items
  final List<BottomNavItem> _navItems = [
    BottomNavItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: 'Home',
    ),
    BottomNavItem(
      icon: Icons.search_outlined,
      selectedIcon: Icons.search_rounded,
      label: 'Search',
    ),
    BottomNavItem(
      icon: Icons.favorite_outline_rounded,
      selectedIcon: Icons.favorite_rounded,
      label: 'Favorites',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadMovies();

    // Initialize background animation
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_backgroundController);
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  void _loadMovies() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieProvider>().loadHomeData();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      context.push('/search');
    } else if (index == 2) {
      context.push('/favorites');
    }
  }

  Widget _buildCurrentScreen() {
    if (_selectedIndex == 0) {
      return const _HomeContent();
    } else if (_selectedIndex == 1) {
      return Container(
        key: const ValueKey('search_placeholder'),
        child: const Center(child: Text('Search')),
      );
    } else {
      return Container(
        key: const ValueKey('favorites_placeholder'),
        child: const Center(child: Text('Favorites')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: _backgroundAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          AppTheme.darkBackground,
                          AppTheme.darkCardColor.withValues(alpha: 0.8),
                          AppTheme.darkBackground,
                        ]
                      : [
                          AppTheme.lightBackground,
                          AppTheme.lightCardColor.withValues(alpha: 0.8),
                          AppTheme.lightBackground,
                        ],
                  stops: [
                    0.0,
                    0.3 + (_backgroundAnimation.value * 0.4),
                    1.0,
                  ],
                ),
              ),
              child: Column(
                children: [
                  Expanded(child: _buildCurrentScreen()),
                  const SizedBox(height: 90),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: AnimatedBottomNavBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: _navItems,
        ),
      ),
    );
  }
}

// Home Content Widget
class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<MovieProvider>().loadHomeData();
      },
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // App Bar
                SliverToBoxAdapter(
                  child: GlassmorphismAppBar(
                    title: AppConstants.appName,
                    onSearchPressed: () => context.push('/search'),
                    actions: [
                      IconButton(
                        onPressed: () {
                          context.read<ThemeProvider>().toggleTheme();
                        },
                        icon: Icon(
                          Theme.of(context).brightness == Brightness.dark
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                        ),
                        tooltip: 'Toggle Theme',
                      ),
                    ],
                  ),
                ),

                // Movie Sections
                Consumer<MovieProvider>(
                  builder: (context, movieProvider, child) {
                    return SliverList(
                      delegate: SliverChildListDelegate([
                        // Hero Banner
                        if (movieProvider.trendingMovies.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: HeroBanner(
                                movies: movieProvider.trendingMovies
                                    .take(5)
                                    .toList(),
                                autoPlay: true,
                              ),
                            ),
                          ),

                        const SizedBox(height: AppConstants.largePadding),

                        // Trending Movies
                        EnhancedMovieSection(
                          title: 'Trending Now',
                          subtitle: 'What\'s hot right now',
                          titleIcon: Icons.trending_up_rounded,
                          movies: movieProvider.trendingMovies,
                          state: movieProvider.trendingState,
                          errorMessage: movieProvider.trendingError,
                          onRetry: movieProvider.retryTrending,
                          isHorizontal: true,
                        ),

                        const SizedBox(height: AppConstants.largePadding),

                        // Now Playing Movies
                        EnhancedMovieSection(
                          title: 'Now Playing',
                          subtitle: 'In theaters now',
                          titleIcon: Icons.play_circle_outline_rounded,
                          movies: movieProvider.nowPlayingMovies,
                          state: movieProvider.nowPlayingState,
                          errorMessage: movieProvider.nowPlayingError,
                          onRetry: movieProvider.retryNowPlaying,
                          isHorizontal: true,
                        ),

                        // Top Rated Movies
                        EnhancedMovieSection(
                          title: 'Top Rated',
                          subtitle: 'Highest rated movies',
                          titleIcon: Icons.star_rounded,
                          movies: movieProvider.topRatedMovies,
                          state: movieProvider.topRatedState,
                          errorMessage: movieProvider.topRatedError,
                          onRetry: movieProvider.retryTopRated,
                          isHorizontal: true,
                        ),

                        // Upcoming Movies
                        EnhancedMovieSection(
                          title: 'Coming Soon',
                          subtitle: 'Upcoming releases',
                          titleIcon: Icons.upcoming_rounded,
                          movies: movieProvider.upcomingMovies,
                          state: movieProvider.upcomingState,
                          errorMessage: movieProvider.upcomingError,
                          onRetry: movieProvider.retryUpcoming,
                          isHorizontal: true,
                        ),

                        const SizedBox(height: 20),
                      ]),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
