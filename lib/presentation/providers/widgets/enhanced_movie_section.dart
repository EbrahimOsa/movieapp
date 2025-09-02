import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/movie_model.dart';
import '../../../core/constants/theme/app_theme.dart';
import '../movie_provider.dart' show MovieLoadingState;
import 'professional_movie_card.dart';
import '../../widgets/error_widget.dart';

class EnhancedMovieSection extends StatefulWidget {
  final String title;
  final List<Movie> movies;
  final MovieLoadingState state;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final bool isHorizontal;
  final bool showViewAll;
  final String? subtitle;
  final IconData? titleIcon;

  const EnhancedMovieSection({
    super.key,
    required this.title,
    required this.movies,
    required this.state,
    this.errorMessage,
    this.onRetry,
    this.isHorizontal = true,
    this.showViewAll = true,
    this.subtitle,
    this.titleIcon,
  });

  @override
  State<EnhancedMovieSection> createState() => _EnhancedMovieSectionState();
}

class _EnhancedMovieSectionState extends State<EnhancedMovieSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 50),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Transform.translate(
            offset: _slideAnimation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // العنوان المحسن مع التدرجات
                  _buildSectionHeader(context, isDark),

                  const SizedBox(height: 16),

                  // المحتوى حسب الحالة
                  _buildContent(context, isDark),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // أيقونة القسم
          if (widget.titleIcon != null)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [AppTheme.neonBlue, AppTheme.neonPurple]
                      : [AppTheme.secondaryColor, AppTheme.primaryColor],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color:
                        (isDark ? AppTheme.neonBlue : AppTheme.secondaryColor)
                            .withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                widget.titleIcon,
                color: Colors.white,
                size: 20,
              ),
            ),

          if (widget.titleIcon != null) const SizedBox(width: 12),

          // العنوان الرئيسي
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: isDark
                        ? [AppTheme.neonBlue, AppTheme.neonPurple]
                        : [AppTheme.primaryColor, AppTheme.secondaryColor],
                  ).createShader(bounds),
                  child: Text(
                    widget.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                  ),
                ),

                // العنوان الفرعي
                if (widget.subtitle != null)
                  Text(
                    widget.subtitle!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? AppTheme.darkOnSurface.withValues(alpha: 0.7)
                              : AppTheme.lightOnSurface.withValues(alpha: 0.7),
                        ),
                  ),
              ],
            ),
          ),

          // زر عرض الكل
          if (widget.showViewAll && widget.movies.isNotEmpty)
            _buildViewAllButton(context, isDark),
        ],
      ),
    );
  }

  Widget _buildViewAllButton(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  Colors.white.withValues(alpha: 0.1),
                  Colors.white.withValues(alpha: 0.05),
                ]
              : [
                  Colors.white.withValues(alpha: 0.9),
                  Colors.white.withValues(alpha: 0.7),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppTheme.neonBlue.withValues(alpha: 0.3)
              : AppTheme.secondaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppTheme.neonBlue.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // التنقل إلى صفحة عرض المزيد
            context.push('/browse', extra: {
              'category': widget.title,
              'movies': widget.movies,
            });
          },
          borderRadius: BorderRadius.circular(20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'View All',
                style: TextStyle(
                  color: isDark ? AppTheme.neonBlue : AppTheme.secondaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: isDark ? AppTheme.neonBlue : AppTheme.secondaryColor,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isDark) {
    switch (widget.state) {
      case MovieLoadingState.initial:
      case MovieLoadingState.loading:
        return _buildLoadingState();
      case MovieLoadingState.loaded:
        return _buildLoadedState(context);
      case MovieLoadingState.error:
        return _buildErrorState(context, isDark);
    }
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: widget.isHorizontal ? 260 : null,
      child: widget.isHorizontal
          ? ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 5,
              itemBuilder: (context, index) {
                return const MovieCardShimmer();
              },
            )
          : const Column(
              children: [
                MovieCardShimmer(isLarge: true),
                SizedBox(height: 8),
                MovieCardShimmer(isLarge: true),
                SizedBox(height: 8),
                MovieCardShimmer(isLarge: true),
              ],
            ),
    );
  }

  Widget _buildLoadedState(BuildContext context) {
    if (widget.movies.isEmpty) {
      return _buildEmptyState(context);
    }

    return SizedBox(
      height: widget.isHorizontal ? 260 : null,
      child: widget.isHorizontal
          ? ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: widget.movies.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final movie = widget.movies[index];
                return ProfessionalMovieCard(
                  movie: movie,
                  onTap: () => context.push('/movie/${movie.id}', extra: movie),
                );
              },
            )
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: widget.movies.length,
              itemBuilder: (context, index) {
                final movie = widget.movies[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ProfessionalMovieCard(
                    movie: movie,
                    isLarge: true,
                    onTap: () =>
                        context.push('/movie/${movie.id}', extra: movie),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildErrorState(BuildContext context, bool isDark) {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  AppTheme.darkSurface.withValues(alpha: 0.8),
                  AppTheme.darkBackground.withValues(alpha: 0.6),
                ]
              : [
                  Colors.white.withValues(alpha: 0.9),
                  Colors.grey[50]!.withValues(alpha: 0.8),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppTheme.accentColor.withValues(alpha: 0.3)
              : AppTheme.accentColor.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppTheme.accentColor.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CustomErrorWidget(
        message: widget.errorMessage ?? 'Something went wrong',
        onRetry: widget.onRetry,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  AppTheme.darkSurface.withValues(alpha: 0.8),
                  AppTheme.darkBackground.withValues(alpha: 0.6),
                ]
              : [
                  Colors.white.withValues(alpha: 0.9),
                  Colors.grey[50]!.withValues(alpha: 0.8),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppTheme.neonBlue.withValues(alpha: 0.2)
              : AppTheme.secondaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.movie_outlined,
              size: 48,
              color: isDark
                  ? AppTheme.darkOnSurface.withValues(alpha: 0.5)
                  : AppTheme.lightOnSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No movies available',
              style: theme.textTheme.titleMedium?.copyWith(
                color: isDark
                    ? AppTheme.darkOnSurface.withValues(alpha: 0.7)
                    : AppTheme.lightOnSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
