import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../data/models/movie_model.dart';
import '../providers/movie_provider.dart';
import '../providers/widgets/shimmer_loading.dart';
import '../providers/widgets/error_widget.dart';
import '../providers/widgets/favorite_button.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/theme/app_theme.dart';

class MovieDetailsScreen extends StatefulWidget {
  final int movieId;
  final Movie? movie;

  const MovieDetailsScreen({
    super.key,
    required this.movieId,
    this.movie,
  });

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  YoutubePlayerController? _youtubeController;
  String? _currentVideoKey;

  @override
  void initState() {
    super.initState();
    _loadMovieDetails();
  }

  @override
  void didUpdateWidget(MovieDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If movie ID changed, dispose old controller and reload details
    if (oldWidget.movieId != widget.movieId) {
      _disposeController();
      _currentVideoKey = null;
      // Clear previous movie details from provider
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<MovieProvider>().clearMovieDetails();
        _loadMovieDetails();
      });
    }
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  void _disposeController() {
    if (_youtubeController != null) {
      _youtubeController!.dispose();
      _youtubeController = null;
    }
  }

  void _loadMovieDetails() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieProvider>().getMovieDetails(widget.movieId);
    });
  }

  void _initializeYoutubePlayer(String videoKey) {
    // Only initialize if it's a different video key or no controller exists
    if (_currentVideoKey != videoKey || _youtubeController == null) {
      _disposeController();
      _currentVideoKey = videoKey;

      _youtubeController = YoutubePlayerController(
        initialVideoId: videoKey,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          hideControls: false,
          enableCaption: true,
        ),
      );

      // Force rebuild after controller is ready
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<MovieProvider>(
        builder: (context, movieProvider, child) {
          switch (movieProvider.detailsState) {
            case MovieLoadingState.loading:
              return _buildLoadingState();
            case MovieLoadingState.loaded:
              return _buildLoadedState(movieProvider);
            case MovieLoadingState.error:
              return _buildErrorState(movieProvider);
            case MovieLoadingState.initial:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 250,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: ShimmerLoading(
              width: double.infinity,
              height: 250,
              borderRadius: BorderRadius.zero,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoading(width: 200, height: 24),
                SizedBox(height: 8),
                ShimmerLoading(width: 150, height: 16),
                SizedBox(height: 16),
                ShimmerLoading(width: double.infinity, height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(MovieProvider movieProvider) {
    return Scaffold(
      appBar: AppBar(title: const Text('Movie Details')),
      body: Center(
        child: CustomErrorWidget(
          message: movieProvider.detailsError,
          onRetry: () => movieProvider.retryDetails(widget.movieId),
        ),
      ),
    );
  }

  Widget _buildLoadedState(MovieProvider movieProvider) {
    final movieDetails = movieProvider.movieDetails!;
    final trailer = movieProvider.getMainTrailer();

    // Initialize YouTube controller for the current movie's trailer
    if (trailer != null) {
      // Always check if we need to update the controller for this movie
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeYoutubePlayer(trailer.key);
      });
    } else {
      // If no trailer, dispose controller
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _disposeController();
        _currentVideoKey = null;
      });
    }

    return CustomScrollView(
      slivers: [
        // App Bar with Backdrop
        SliverAppBar(
          expandedHeight: 250,
          pinned: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FavoriteButton(
                movie: Movie(
                  id: movieDetails.id,
                  title: movieDetails.title,
                  overview: movieDetails.overview,
                  posterPath: movieDetails.posterPath,
                  backdropPath: movieDetails.backdropPath,
                  releaseDate: movieDetails.releaseDate,
                  voteAverage: movieDetails.voteAverage,
                  voteCount: movieDetails.voteCount,
                  popularity: movieDetails.popularity,
                  adult: movieDetails.adult,
                  video: movieDetails.video,
                  originalLanguage: movieDetails.originalLanguage,
                  originalTitle: movieDetails.originalTitle,
                  genreIds: movieDetails.genres.map((g) => g.id).toList(),
                ),
                iconColor: Colors.white,
                size: 28.0,
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: movieDetails.fullBackdropPath,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const ShimmerLoading(
                    width: double.infinity,
                    height: 250,
                    borderRadius: BorderRadius.zero,
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Theme.of(context).colorScheme.surface,
                    child: const Icon(Icons.movie, size: 64),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withAlpha((0.7 * 255).toInt()),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Movie Details Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Basic Info
                _buildTitleSection(movieDetails),

                const SizedBox(height: AppConstants.defaultPadding),

                // Overview
                _buildOverviewSection(movieDetails),

                const SizedBox(height: AppConstants.defaultPadding),

                // Trailer Section
                _buildTrailerSection(movieProvider),

                const SizedBox(height: AppConstants.defaultPadding),

                // Cast Section
                _buildCastSection(movieProvider.movieCast),

                const SizedBox(height: AppConstants.largePadding),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleSection(MovieDetails movieDetails) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          movieDetails.title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.goldColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    movieDetails.formattedRating,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(movieDetails.year),
            if (movieDetails.runtime != null && movieDetails.runtime! > 0) ...[
              const SizedBox(width: 12),
              Text(movieDetails.formattedRuntime),
            ],
          ],
        ),
        if (movieDetails.genres.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: movieDetails.genres.map((genre) {
              return Chip(
                label: Text(genre.name),
                backgroundColor:
                    Theme.of(context).colorScheme.secondaryContainer,
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildOverviewSection(MovieDetails movieDetails) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          movieDetails.overview.isNotEmpty
              ? movieDetails.overview
              : 'No overview available.',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }

  Widget _buildTrailerSection(MovieProvider movieProvider) {
    final trailer = movieProvider.getMainTrailer();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trailer',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        if (_youtubeController != null &&
            trailer != null &&
            _currentVideoKey == trailer.key)
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            child: YoutubePlayer(
              controller: _youtubeController!,
              showVideoProgressIndicator: true,
              progressIndicatorColor: AppTheme.secondaryColor,
            ),
          )
        else if (trailer == null)
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.video_library_outlined,
                    size: 48,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No trailer available',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.5),
                        ),
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  Widget _buildCastSection(List<Cast> cast) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cast',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: cast.length,
            itemBuilder: (context, index) {
              final actor = cast[index];
              return Container(
                width: 80,
                margin: const EdgeInsets.only(right: 8),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: actor.fullProfilePath,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const ShimmerLoading(
                          width: 60,
                          height: 60,
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 60,
                          height: 60,
                          color: Theme.of(context).colorScheme.surface,
                          child: const Icon(Icons.person),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      actor.name,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      actor.character,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
