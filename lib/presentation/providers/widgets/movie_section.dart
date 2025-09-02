import 'package:flutter/material.dart';
import './modern_movie_card.dart';
import './shimmer_loading.dart';
import '../../widgets/error_widget.dart';
import '../../../data/models/movie_model.dart';
import '../movie_provider.dart';
import '../../../core/constants/app_constants.dart';

class MovieSection extends StatefulWidget {
  final String title;
  final List<Movie> movies;
  final MovieLoadingState state;
  final String errorMessage;
  final VoidCallback onRetry;
  final bool isHorizontal;

  const MovieSection({
    super.key,
    required this.title,
    required this.movies,
    required this.state,
    required this.errorMessage,
    required this.onRetry,
    this.isHorizontal = true,
  });

  @override
  State<MovieSection> createState() => _MovieSectionState();
}

class _MovieSectionState extends State<MovieSection>
    with TickerProviderStateMixin {
  late AnimationController _staggerController;
  late List<Animation<double>> _staggerAnimations;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _initializeStaggerAnimations();

    if (widget.state == MovieLoadingState.loaded && widget.movies.isNotEmpty) {
      _staggerController.forward();
    }
  }

  void _initializeStaggerAnimations() {
    const int maxItems = 10;
    _staggerAnimations = List.generate(
      maxItems,
      (index) => Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _staggerController,
        curve: Interval(
          (index * 0.1).clamp(0.0, 1.0),
          ((index * 0.1) + 0.6).clamp(0.0, 1.0),
          curve: Curves.easeOutBack,
        ),
      )),
    );
  }

  @override
  void didUpdateWidget(MovieSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state == MovieLoadingState.loaded &&
        widget.movies.isNotEmpty &&
        oldWidget.state != MovieLoadingState.loaded) {
      _staggerController.forward();
    }
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title (if provided)
        if (widget.title.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.defaultPadding,
            ),
            child: Text(
              widget.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
        ],

        // Content based on state
        SizedBox(
          height: 280, // Increased height for new card design
          child: _buildContent(context),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (widget.state) {
      case MovieLoadingState.loading:
        return _buildShimmerLoading();
      case MovieLoadingState.loaded:
        return _buildMovieList(context);
      case MovieLoadingState.error:
        return _buildError(context);
      case MovieLoadingState.initial:
        return const SizedBox.shrink();
    }
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
      ),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(right: 16),
          child: ShimmerLoading(
            width: 160,
            height: 240,
            borderRadius: BorderRadius.circular(20),
          ),
        );
      },
    );
  }

  Widget _buildMovieList(BuildContext context) {
    if (widget.movies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.movie_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No movies found',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
      );
    }

    return AnimatedBuilder(
      animation: _staggerController,
      builder: (context, child) {
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
          ),
          itemCount: widget.movies.length,
          itemBuilder: (context, index) {
            // Use index clamped to available animations
            final animIndex = index.clamp(0, _staggerAnimations.length - 1);

            return AnimatedBuilder(
              animation: _staggerAnimations[animIndex],
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    0,
                    50 * (1 - _staggerAnimations[animIndex].value),
                  ),
                  child: Opacity(
                    opacity: _staggerAnimations[animIndex].value,
                    child: Container(
                      margin: const EdgeInsets.only(right: 16),
                      child: ModernMovieCard(
                        movie: widget.movies[index],
                        width: 160,
                        height: 240,
                        heroTag:
                            '${widget.title}_${widget.movies[index].id}_$index',
                        showGradient: true,
                        showFavorite: true,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: CustomErrorWidget(
          message: widget.errorMessage,
          onRetry: widget.onRetry,
        ),
      ),
    );
  }
}
