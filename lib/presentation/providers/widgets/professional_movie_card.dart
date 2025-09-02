import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/movie_model.dart';
import '../../../core/constants/theme/app_theme.dart';
import 'shimmer_loading.dart';

class ProfessionalMovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback? onTap;
  final bool isLarge;
  final bool showGradientOverlay;

  const ProfessionalMovieCard({
    super.key,
    required this.movie,
    this.onTap,
    this.isLarge = false,
    this.showGradientOverlay = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: EdgeInsets.symmetric(
          horizontal: isLarge ? 0 : 8,
          vertical: 4,
        ),
        child: Hero(
          tag: 'movie-${movie.id}',
          child: Container(
            width: isLarge ? double.infinity : 180,
            height: isLarge ? 280 : 260,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? AppTheme.neonBlue.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
                if (isDark)
                  BoxShadow(
                    color: AppTheme.neonPurple.withValues(alpha: 0.05),
                    blurRadius: 40,
                    spreadRadius: 0,
                    offset: const Offset(0, 16),
                  ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // صورة الفيلم
                  CachedNetworkImage(
                    imageUrl: movie.fullPosterPath,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => ShimmerLoading(
                      width: double.infinity,
                      height: double.infinity,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    errorWidget: (context, url, error) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? AppTheme.darkGradient
                              : [Colors.grey[300]!, Colors.grey[400]!],
                        ),
                      ),
                      child: const Icon(
                        Icons.movie_outlined,
                        size: 48,
                        color: Colors.white70,
                      ),
                    ),
                  ),

                  // تدرج اللون والمعلومات
                  if (showGradientOverlay)
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                            Colors.black.withValues(alpha: 0.9),
                          ],
                          stops: const [0.0, 0.4, 0.8, 1.0],
                        ),
                      ),
                    ),

                  // تقييم الفيلم (في الأعلى)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [
                                  AppTheme.goldGradient[0],
                                  AppTheme.goldGradient[1]
                                ]
                              : [AppTheme.goldColor, AppTheme.accentColor],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.goldColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            spreadRadius: 0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            movie.formattedRating,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // معلومات الفيلم (في الأسفل)
                  if (showGradientOverlay)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              movie.title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isLarge ? 18 : 14,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.8),
                                    offset: const Offset(1, 1),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              movie.year,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: isLarge ? 14 : 12,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.8),
                                    offset: const Offset(1, 1),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // تأثير Glass عند الضغط
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onTap,
                      borderRadius: BorderRadius.circular(20),
                      splashColor: isDark
                          ? AppTheme.neonBlue.withValues(alpha: 0.2)
                          : AppTheme.secondaryColor.withValues(alpha: 0.2),
                      highlightColor: isDark
                          ? AppTheme.neonPurple.withValues(alpha: 0.1)
                          : AppTheme.primaryColor.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MovieCardShimmer extends StatelessWidget {
  final bool isLarge;

  const MovieCardShimmer({
    super.key,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isLarge ? double.infinity : 180,
      height: isLarge ? 280 : 260,
      margin: EdgeInsets.symmetric(
        horizontal: isLarge ? 0 : 8,
        vertical: 4,
      ),
      child: ShimmerLoading(
        width: double.infinity,
        height: double.infinity,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
