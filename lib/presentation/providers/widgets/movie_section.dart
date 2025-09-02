import 'package:flutter/material.dart';
import './movie_card.dart';
import './shimmer_loading.dart';
import './error_widget.dart';
import '../../../data/models/movie_model.dart';
import '../movie_provider.dart';
import '../../../core/constants/app_constants.dart';

class MovieSection extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
          ),
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),

        const SizedBox(height: AppConstants.smallPadding),

        // Content based on state
        SizedBox(
          height: 200,
          child: _buildContent(context),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (state) {
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
        return const Padding(
          padding: EdgeInsets.only(right: AppConstants.smallPadding),
          child: ShimmerLoading(
            width: 120,
            height: 180,
          ),
        );
      },
    );
  }

  Widget _buildMovieList(BuildContext context) {
    if (movies.isEmpty) {
      return Center(
        child: Text(
          'No movies found',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(right: AppConstants.smallPadding),
          child: MovieCard(
            movie: movies[index],
            width: 120,
            height: 180,
          ),
        );
      },
    );
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: CustomErrorWidget(
          message: errorMessage,
          onRetry: onRetry,
        ),
      ),
    );
  }
}
