import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'dart:math';

import '../../../data/models/movie_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/theme/app_theme.dart';

class HeroBanner extends StatefulWidget {
  final List<Movie> movies;
  final bool autoPlay;

  const HeroBanner({
    super.key,
    required this.movies,
    this.autoPlay = true,
  });

  @override
  State<HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<HeroBanner> with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _fadeController;
  late AnimationController _slideController;

  int _currentIndex = 0;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeController.forward();
    _slideController.forward();

    if (widget.autoPlay && widget.movies.isNotEmpty) {
      _startAutoPlay();
    }
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(
      const Duration(seconds: 5),
      (timer) {
        if (mounted && widget.movies.isNotEmpty) {
          final nextIndex = (_currentIndex + 1) % widget.movies.length;
          _pageController.animateToPage(
            nextIndex,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        }
      },
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Restart animations for new content
    _fadeController.reset();
    _slideController.reset();
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.movies.isEmpty) {
      return const SizedBox(height: 400);
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final bannerHeight = min(screenHeight * 0.65, 500.0);

    return SizedBox(
      height: bannerHeight,
      child: Stack(
        children: [
          // Background Images Carousel
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: widget.movies.length,
            itemBuilder: (context, index) {
              return _buildBackgroundImage(widget.movies[index]);
            },
          ),

          // Gradient Overlays
          _buildGradientOverlay(),

          // Content
          _buildContent(),

          // Page Indicators
          _buildPageIndicators(),

          // Navigation Buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildBackgroundImage(Movie movie) {
    return SizedBox(
      width: double.infinity,
      child: CachedNetworkImage(
        imageUrl: movie.fullBackdropPath,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Theme.of(context).colorScheme.surface,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Theme.of(context).colorScheme.surface,
          child: const Icon(Icons.movie, size: 100),
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.3),
            Colors.black.withValues(alpha: 0.5),
            Colors.black.withValues(alpha: 0.8),
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (widget.movies.isEmpty) return const SizedBox.shrink();

    final currentMovie = widget.movies[_currentIndex];

    return Positioned.fill(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),

              // Movie Title
              AnimatedBuilder(
                animation: _fadeController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - _slideController.value)),
                    child: Opacity(
                      opacity: _fadeController.value,
                      child: Text(
                        currentMovie.title,
                        style:
                            Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                              color: Colors.black.withValues(alpha: 0.8),
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 8),

              // Movie Info
              AnimatedBuilder(
                animation: _fadeController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - _slideController.value)),
                    child: Opacity(
                      opacity: _fadeController.value * 0.9,
                      child: Row(
                        children: [
                          if (currentMovie.year != 'N/A') ...[
                            Text(
                              currentMovie.year,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          if (currentMovie.voteAverage > 0) ...[
                            const Icon(
                              Icons.star,
                              color: AppTheme.goldColor,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              currentMovie.formattedRating,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // Movie Overview
              AnimatedBuilder(
                animation: _fadeController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - _slideController.value)),
                    child: Opacity(
                      opacity: _fadeController.value * 0.8,
                      child: Text(
                        currentMovie.overview,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.5,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 2,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Action Buttons
              AnimatedBuilder(
                animation: _fadeController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - _slideController.value)),
                    child: Opacity(
                      opacity: _fadeController.value,
                      child: Row(
                        children: [
                          // Play Button
                          ElevatedButton.icon(
                            onPressed: () => context.push(
                                '/movie/${currentMovie.id}',
                                extra: currentMovie),
                            icon: const Icon(Icons.play_arrow,
                                color: Colors.black),
                            label: const Text('Watch Now',
                                style: TextStyle(color: Colors.black)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Add to List Button
                          IconButton(
                            onPressed: () {
                              // TODO: Add to favorites functionality
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Added to My List')),
                              );
                            },
                            icon: const Icon(Icons.add,
                                color: Colors.white, size: 28),
                            style: IconButton.styleFrom(
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Info Button
                          IconButton(
                            onPressed: () => context.push(
                                '/movie/${currentMovie.id}',
                                extra: currentMovie),
                            icon: const Icon(Icons.info_outline,
                                color: Colors.white, size: 28),
                            style: IconButton.styleFrom(
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicators() {
    if (widget.movies.length <= 1) return const SizedBox.shrink();

    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          widget.movies.length,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: _currentIndex == index ? 24 : 8,
            height: 4,
            decoration: BoxDecoration(
              color: _currentIndex == index
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    if (widget.movies.length <= 1) return const SizedBox.shrink();

    return Positioned.fill(
      child: Row(
        children: [
          // Previous Button
          Expanded(
            child: GestureDetector(
              onTap: () {
                final prevIndex = _currentIndex == 0
                    ? widget.movies.length - 1
                    : _currentIndex - 1;
                _pageController.animateToPage(
                  prevIndex,
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeInOut,
                );
              },
              child: Container(
                color: Colors.transparent,
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Icon(
                      Icons.chevron_left,
                      color: Colors.white54,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Next Button
          Expanded(
            child: GestureDetector(
              onTap: () {
                final nextIndex = (_currentIndex + 1) % widget.movies.length;
                _pageController.animateToPage(
                  nextIndex,
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeInOut,
                );
              },
              child: Container(
                color: Colors.transparent,
                child: const Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Icon(
                      Icons.chevron_right,
                      color: Colors.white54,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
