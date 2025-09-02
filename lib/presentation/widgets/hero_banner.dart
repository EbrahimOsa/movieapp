import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'dart:math';

import '../../data/models/movie_model.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/theme/app_theme.dart';

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
          // Main Banner Content
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: widget.movies.length,
            itemBuilder: (context, index) {
              final movie = widget.movies[index];
              return _buildBannerItem(movie);
            },
          ),

          // Page Indicators
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: _buildPageIndicators(),
          ),

          // Navigation Buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildBannerItem(Movie movie) {
    return GestureDetector(
      onTap: () {
        context.push('/movie/${movie.id}', extra: movie);
      },
      child: Container(
        decoration: BoxDecoration(
          image: movie.backdropPath != null
              ? DecorationImage(
                  image: CachedNetworkImageProvider(
                    '${AppConstants.tmdbBackdropBaseUrl}${movie.backdropPath}',
                  ),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.7),
                Colors.black.withValues(alpha: 0.9),
              ],
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FadeTransition(
                opacity: _fadeController,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(-0.3, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _slideController,
                    curve: Curves.easeOut,
                  )),
                  child: Text(
                    movie.title,
                    style: const TextStyle(
                      fontSize: 24, // تقليل حجم الخط قليلاً
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          offset: Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FadeTransition(
                opacity: _fadeController,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(-0.2, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _slideController,
                    curve: Curves.easeOut,
                  )),
                  child: Text(
                    movie.overview,
                    style: const TextStyle(
                      fontSize: 14, // تقليل حجم الخط
                      color: Colors.white70,
                    ),
                    maxLines: 2, // تقليل عدد الأسطر
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                // إضافة Flexible لتجنب overflow
                child: Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 18, // تقليل حجم الأيقونة
                    ),
                    const SizedBox(width: 4),
                    Text(
                      movie.voteAverage.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14, // إضافة حجم خط محدد
                      ),
                    ),
                    const SizedBox(width: 20),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Watch Now',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.movies.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: index == _currentIndex ? 24 : 8,
          decoration: BoxDecoration(
            color: index == _currentIndex
                ? AppTheme.secondaryColor
                : Colors.white.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(4),
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
