import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../../../core/constants/theme/app_theme.dart';
import '../theme_provider.dart';

class CustomAppBar extends StatefulWidget {
  final String title;
  final VoidCallback? onSearchPressed;
  final VoidCallback? onThemePressed;
  final bool showSearchButton;
  final bool showThemeToggle;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onSearchPressed,
    this.onThemePressed,
    this.showSearchButton = true,
    this.showThemeToggle = true,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? AppTheme.neonBlue.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            AppTheme.darkCardColor.withValues(alpha: 0.8),
                            AppTheme.darkBackground.withValues(alpha: 0.9),
                          ]
                        : [
                            Colors.white.withValues(alpha: 0.8),
                            Colors.white.withValues(alpha: 0.9),
                          ],
                  ),
                  border: Border.all(
                    color: isDark
                        ? AppTheme.neonBlue.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: SafeArea(
                  child: Row(
                    children: [
                      // App Icon and Title
                      Expanded(
                        child: Row(
                          children: [
                            // Animated Logo
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 1200),
                              curve: Curves.elasticOut,
                              builder: (context, value, child) {
                                return Transform.rotate(
                                  angle: (1 - value) * 2,
                                  child: Transform.scale(
                                    scale: value,
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: isDark
                                              ? [
                                                  AppTheme.neonBlue,
                                                  AppTheme.neonPurple
                                                ]
                                              : [
                                                  AppTheme.primaryColor,
                                                  AppTheme.secondaryColor
                                                ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: (isDark
                                                    ? AppTheme.neonBlue
                                                    : AppTheme.primaryColor)
                                                .withValues(alpha: 0.3),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.movie_filter_rounded,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 16),

                            // App Title with Gradient Text
                            ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: isDark
                                    ? [AppTheme.neonBlue, AppTheme.neonPurple]
                                    : [
                                        AppTheme.primaryColor,
                                        AppTheme.secondaryColor
                                      ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds),
                              child: Text(
                                widget.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Action Buttons
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Search Button
                          if (widget.showSearchButton)
                            _buildActionButton(
                              icon: Icons.search_rounded,
                              onPressed: widget.onSearchPressed,
                              tooltip: 'Search Movies',
                              isDark: isDark,
                            ),

                          if (widget.showSearchButton && widget.showThemeToggle)
                            const SizedBox(width: 8),

                          // Theme Toggle Button
                          if (widget.showThemeToggle)
                            Consumer<ThemeProvider>(
                              builder: (context, themeProvider, child) {
                                return _buildActionButton(
                                  icon: themeProvider.isDarkMode
                                      ? Icons.light_mode_rounded
                                      : Icons.dark_mode_rounded,
                                  onPressed: widget.onThemePressed,
                                  tooltip: themeProvider.isDarkMode
                                      ? 'Light Mode'
                                      : 'Dark Mode',
                                  isDark: isDark,
                                );
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required String tooltip,
    required bool isDark,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: isDark
                ? [
                    AppTheme.neonBlue.withValues(alpha: 0.1),
                    AppTheme.neonPurple.withValues(alpha: 0.1),
                  ]
                : [
                    AppTheme.primaryColor.withValues(alpha: 0.1),
                    AppTheme.secondaryColor.withValues(alpha: 0.1),
                  ],
          ),
          border: Border.all(
            color: (isDark ? AppTheme.neonBlue : AppTheme.primaryColor)
                .withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onPressed,
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Icon(
                icon,
                size: 22,
                color: isDark ? AppTheme.neonBlue : AppTheme.primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
