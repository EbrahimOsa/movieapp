import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../providers/movie_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/widgets/movie_section.dart';
import '../providers/widgets/custom_app_bar.dart';
import '../providers/widgets/hero_banner.dart';
import '../../core/constants/app_constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _loadMovies();
    _screens.addAll([
      _HomeContent(),
      Container(), // سيتم استبدالها لاحقًا بشاشة البحث
      Container(), // سيتم استبدالها لاحقًا بشاشة المفضلة
    ]);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }
}

// محتوى شاشة الهوم كما كان سابقًا
class _HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<MovieProvider>().loadHomeData();
      },
      child: CustomScrollView(
        slivers: [
          // Custom App Bar
          SliverToBoxAdapter(
            child: CustomAppBar(
              title: AppConstants.appName,
              onSearchPressed: () => context.push('/search'),
              onThemePressed: () {
                context.read<ThemeProvider>().toggleTheme();
              },
            ),
          ),

          // Movie Sections
          Consumer<MovieProvider>(
            builder: (context, movieProvider, child) {
              return SliverList(
                delegate: SliverChildListDelegate([
                  // Hero Banner
                  if (movieProvider.trendingMovies.isNotEmpty)
                    HeroBanner(
                      movies: movieProvider.trendingMovies.take(5).toList(),
                      autoPlay: true,
                    ),

                  const SizedBox(height: AppConstants.defaultPadding),

                  // Trending Movies Section
                  MovieSection(
                    title: 'Trending Now',
                    movies: movieProvider.trendingMovies,
                    state: movieProvider.trendingState,
                    errorMessage: movieProvider.trendingError,
                    onRetry: movieProvider.retryTrending,
                    isHorizontal: true,
                  ),

                  const SizedBox(height: AppConstants.defaultPadding),

                  // Now Playing Movies Section
                  MovieSection(
                    title: 'Now Playing',
                    movies: movieProvider.nowPlayingMovies,
                    state: movieProvider.nowPlayingState,
                    errorMessage: movieProvider.nowPlayingError,
                    onRetry: movieProvider.retryNowPlaying,
                    isHorizontal: true,
                  ),

                  const SizedBox(height: AppConstants.defaultPadding),

                  // Top Rated Movies Section
                  MovieSection(
                    title: 'Top Rated',
                    movies: movieProvider.topRatedMovies,
                    state: movieProvider.topRatedState,
                    errorMessage: movieProvider.topRatedError,
                    onRetry: movieProvider.retryTopRated,
                    isHorizontal: true,
                  ),

                  const SizedBox(height: AppConstants.defaultPadding),

                  // Upcoming Movies Section
                  MovieSection(
                    title: 'Upcoming',
                    movies: movieProvider.upcomingMovies,
                    state: movieProvider.upcomingState,
                    errorMessage: movieProvider.upcomingError,
                    onRetry: movieProvider.retryUpcoming,
                    isHorizontal: true,
                  ),
                ]),
              );
            },
          ),
        ],
      ),
    );
  }
}
