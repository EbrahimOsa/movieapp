import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/movie_model.dart';
import '../../core/constants/theme/app_theme.dart';
import '../providers/movie_provider.dart' show MovieLoadingState;
import '../providers/widgets/professional_movie_card.dart';
import 'error_widget.dart';

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

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
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
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(context),
              const SizedBox(height: 16),
              _buildContent(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (widget.titleIcon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [AppTheme.neonBlue, AppTheme.neonPurple]
                      : [AppTheme.secondaryColor, AppTheme.accentColor],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color:
                        (isDark ? AppTheme.neonBlue : AppTheme.secondaryColor)
                            .withValues(alpha: 0.3),
                    blurRadius: 8,
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
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle!,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.7)
                          : Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (widget.showViewAll) ...[
            TextButton(
              onPressed: () {
                // Navigate to category screen based on section title
                String category = 'trending';
                String title = widget.title;

                if (widget.title.toLowerCase().contains('trending')) {
                  category = 'trending';
                } else if (widget.title.toLowerCase().contains('now playing')) {
                  category = 'now_playing';
                } else if (widget.title.toLowerCase().contains('top rated')) {
                  category = 'top_rated';
                } else if (widget.title.toLowerCase().contains('upcoming') ||
                    widget.title.toLowerCase().contains('coming soon')) {
                  category = 'upcoming';
                }

                context.push('/category/$category?title=$title');
              },
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View All',
                    style: TextStyle(
                      color:
                          isDark ? AppTheme.neonBlue : AppTheme.secondaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: isDark ? AppTheme.neonBlue : AppTheme.secondaryColor,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (widget.state) {
      case MovieLoadingState.loading:
        return _buildLoadingState();
      case MovieLoadingState.error:
        return _buildErrorState(context);
      case MovieLoadingState.loaded:
        if (widget.movies.isEmpty) {
          return _buildEmptyState(context);
        }
        return widget.isHorizontal
            ? _buildHorizontalList()
            : _buildVerticalList();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildHorizontalList() {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: widget.movies.length,
        itemBuilder: (context, index) {
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 12),
            child: ProfessionalMovieCard(
              movie: widget.movies[index],
              onTap: () {
                context.push('/movie/${widget.movies[index].id}',
                    extra: widget.movies[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildVerticalList() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.6,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: widget.movies.length,
      itemBuilder: (context, index) {
        return ProfessionalMovieCard(
          movie: widget.movies[index],
          onTap: () {
            context.push('/movie/${widget.movies[index].id}',
                extra: widget.movies[index]);
          },
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 12),
            child: const ShimmerMovieCard(),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: CustomErrorWidget(
        message: widget.errorMessage ?? 'Failed to load movies',
        onRetry: widget.onRetry,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.movie_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No movies found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new content',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

class ShimmerMovieCard extends StatelessWidget {
  const ShimmerMovieCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: double.infinity,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 80,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
