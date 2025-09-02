import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../providers/recommendations_provider.dart';
import '../providers/widgets/genre_filter.dart';
import '../providers/widgets/movie_card.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<int> _selectedGenres = [];
  String _selectedSortBy = 'popularity.desc';

  final List<String> _sortOptions = [
    'popularity.desc',
    'vote_average.desc',
    'release_date.desc',
    'title.asc',
  ];

  final Map<String, String> _sortLabels = {
    'popularity.desc': 'Most Popular',
    'vote_average.desc': 'Highest Rated',
    'release_date.desc': 'Newest',
    'title.asc': 'A-Z',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final movieProvider = Provider.of<MovieProvider>(context, listen: false);
      final recProvider =
          Provider.of<RecommendationsProvider>(context, listen: false);

      movieProvider.fetchPopularMovies();
      movieProvider.fetchTopRatedMovies();
      movieProvider.fetchUpcomingMovies();
      recProvider.getTrendingMovies();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final movieProvider = Provider.of<MovieProvider>(context, listen: false);

    // Apply genre and sort filters
    movieProvider.discoverMovies(
      genreIds: _selectedGenres,
      sortBy: _selectedSortBy,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Movies'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Trending', icon: Icon(Icons.trending_up)),
            Tab(text: 'Popular', icon: Icon(Icons.local_fire_department)),
            Tab(text: 'Top Rated', icon: Icon(Icons.star)),
            Tab(text: 'Upcoming', icon: Icon(Icons.upcoming)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterBottomSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Active filters display
          if (_selectedGenres.isNotEmpty ||
              _selectedSortBy != 'popularity.desc')
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Active Filters',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedGenres.clear();
                            _selectedSortBy = 'popularity.desc';
                          });
                          _applyFilters();
                        },
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      // Sort chip
                      if (_selectedSortBy != 'popularity.desc')
                        Chip(
                          label: Text(
                              _sortLabels[_selectedSortBy] ?? _selectedSortBy),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () {
                            setState(() {
                              _selectedSortBy = 'popularity.desc';
                            });
                            _applyFilters();
                          },
                        ),

                      // Genre chips
                      ...MovieGenres.getGenresByIds(_selectedGenres).map(
                        (genre) => Chip(
                          avatar: Text(genre.emoji),
                          label: Text(genre.name),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () {
                            setState(() {
                              _selectedGenres.remove(genre.id);
                            });
                            _applyFilters();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _TrendingTab(),
                _PopularTab(),
                _TopRatedTab(),
                _UpcomingTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                const SizedBox(height: 16),

                // Title
                Text(
                  'Filter & Sort',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),

                const SizedBox(height: 24),

                // Sort section
                Text(
                  'Sort By',
                  style: Theme.of(context).textTheme.titleMedium,
                ),

                const SizedBox(height: 12),

                Wrap(
                  spacing: 8,
                  children: _sortOptions.map((sort) {
                    final isSelected = _selectedSortBy == sort;
                    return FilterChip(
                      selected: isSelected,
                      onSelected: (_) {
                        setModalState(() {
                          _selectedSortBy = sort;
                        });
                      },
                      label: Text(_sortLabels[sort] ?? sort),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // Genre filter
                Expanded(
                  child: GenreFilter(
                    genres: MovieGenres.predefined,
                    selectedGenreIds: _selectedGenres,
                    onSelectionChanged: (selectedIds) {
                      setModalState(() {
                        _selectedGenres = selectedIds;
                      });
                    },
                  ),
                ),

                // Apply button
                SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          // Update main state
                        });
                        _applyFilters();
                        Navigator.pop(context);
                      },
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Tab widgets
class _TrendingTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<RecommendationsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Failed to load trending movies',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => provider.getTrendingMovies(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (provider.trending.isEmpty) {
          return const Center(
            child: Text('No trending movies found'),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.6,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: provider.trending.length,
          itemBuilder: (context, index) {
            final movie = provider.trending[index];
            return MovieCard(movie: movie);
          },
        );
      },
    );
  }
}

class _PopularTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MovieProvider>(
      builder: (context, provider, child) {
        if (provider.nowPlayingState == MovieLoadingState.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.popularMovies.isEmpty) {
          return const Center(
            child: Text('No popular movies found'),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.6,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: provider.popularMovies.length,
          itemBuilder: (context, index) {
            final movie = provider.popularMovies[index];
            return MovieCard(movie: movie);
          },
        );
      },
    );
  }
}

class _TopRatedTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MovieProvider>(
      builder: (context, provider, child) {
        if (provider.topRatedState == MovieLoadingState.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.topRatedMovies.isEmpty) {
          return const Center(
            child: Text('No top rated movies found'),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.6,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: provider.topRatedMovies.length,
          itemBuilder: (context, index) {
            final movie = provider.topRatedMovies[index];
            return MovieCard(movie: movie);
          },
        );
      },
    );
  }
}

class _UpcomingTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MovieProvider>(
      builder: (context, provider, child) {
        if (provider.upcomingState == MovieLoadingState.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.upcomingMovies.isEmpty) {
          return const Center(
            child: Text('No upcoming movies found'),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.6,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: provider.upcomingMovies.length,
          itemBuilder: (context, index) {
            final movie = provider.upcomingMovies[index];
            return MovieCard(movie: movie);
          },
        );
      },
    );
  }
}
