import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../core/constants/theme/app_theme.dart';

class GlassmorphismAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final VoidCallback? onSearchPressed;
  final bool showSearchIcon;
  final Color? backgroundColor;
  final double elevation;
  final bool showGradientBorder;

  const GlassmorphismAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = false,
    this.onSearchPressed,
    this.showSearchIcon = true,
    this.backgroundColor,
    this.elevation = 0,
    this.showGradientBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppTheme.darkBackground.withValues(alpha: 0.8),
                  AppTheme.darkSurface.withValues(alpha: 0.6),
                ]
              : [
                  AppTheme.lightBackground.withValues(alpha: 0.8),
                  AppTheme.lightSurface.withValues(alpha: 0.9),
                ],
        ),
        border: showGradientBorder
            ? Border(
                bottom: BorderSide(
                  width: 1,
                  color: isDark
                      ? AppTheme.neonBlue.withValues(alpha: 0.1)
                      : AppTheme.secondaryColor.withValues(alpha: 0.1),
                ),
              )
            : null,
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: elevation,
            systemOverlayStyle:
                isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
            leading: leading,
            centerTitle: centerTitle,
            title: ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: isDark
                    ? [AppTheme.neonBlue, AppTheme.neonPurple]
                    : [AppTheme.primaryColor, AppTheme.secondaryColor],
              ).createShader(bounds),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                  shadows: [
                    Shadow(
                      color: isDark
                          ? AppTheme.neonBlue.withValues(alpha: 0.3)
                          : Colors.black.withValues(alpha: 0.1),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              if (showSearchIcon)
                _buildGlassButton(
                  context,
                  icon: Icons.search_rounded,
                  onPressed: onSearchPressed,
                  isDark: isDark,
                ),
              if (actions != null) ...actions!,
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback? onPressed,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppTheme.neonBlue.withValues(alpha: 0.2)
              : AppTheme.secondaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.white.withValues(alpha: 0.1),
                  Colors.white.withValues(alpha: 0.05),
                ]
              : [
                  Colors.white.withValues(alpha: 0.8),
                  Colors.white.withValues(alpha: 0.4),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppTheme.neonBlue.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(16),
              splashColor: isDark
                  ? AppTheme.neonBlue.withValues(alpha: 0.2)
                  : AppTheme.secondaryColor.withValues(alpha: 0.2),
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  color: isDark ? AppTheme.neonBlue : AppTheme.secondaryColor,
                  size: 22,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class AnimatedSearchBar extends StatefulWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;
  final TextEditingController? controller;
  final bool isExpanded;

  const AnimatedSearchBar({
    super.key,
    this.hintText = 'Search movies...',
    this.onChanged,
    this.onSubmitted,
    this.controller,
    this.isExpanded = false,
  });

  @override
  State<AnimatedSearchBar> createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<AnimatedSearchBar>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _widthAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _widthAnimation = Tween<double>(
      begin: 50,
      end: 280,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.5, 1.0),
    ));

    if (widget.isExpanded) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
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
        return Container(
          width: _widthAnimation.value,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark
                  ? AppTheme.neonBlue.withValues(alpha: 0.3)
                  : AppTheme.secondaryColor.withValues(alpha: 0.3),
              width: 1,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
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
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? AppTheme.neonBlue.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Icon(
                    Icons.search_rounded,
                    color: isDark ? AppTheme.neonBlue : AppTheme.secondaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Opacity(
                      opacity: _opacityAnimation.value,
                      child: TextField(
                        controller: widget.controller,
                        onChanged: widget.onChanged,
                        onSubmitted: (value) => widget.onSubmitted?.call(),
                        style: TextStyle(
                          color: isDark
                              ? AppTheme.darkOnSurface
                              : AppTheme.lightOnSurface,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: widget.hintText,
                          hintStyle: TextStyle(
                            color: isDark
                                ? AppTheme.darkOnSurface.withValues(alpha: 0.6)
                                : AppTheme.lightOnSurface
                                    .withValues(alpha: 0.6),
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
