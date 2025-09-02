import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../core/constants/theme/app_theme.dart';

class AnimatedBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavItem> items;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? unselectedColor;

  const AnimatedBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
  });

  @override
  State<AnimatedBottomNavBar> createState() => _AnimatedBottomNavBarState();
}

class _AnimatedBottomNavBarState extends State<AnimatedBottomNavBar>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _slideAnimation = Tween<double>(
      begin: -20,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
  }

  @override
  void didUpdateWidget(AnimatedBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      _animationController.reset();
      _animationController.forward();

      // Haptic feedback
      HapticFeedback.lightImpact();
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

    final backgroundColor = widget.backgroundColor ??
        (isDark ? AppTheme.darkSurface : AppTheme.lightSurface);
    final selectedColor = widget.selectedColor ??
        (isDark ? AppTheme.neonBlue : AppTheme.secondaryColor);
    final unselectedColor = widget.unselectedColor ??
        (isDark
            ? AppTheme.darkOnSurface.withValues(alpha: 0.6)
            : AppTheme.lightOnSurface.withValues(alpha: 0.6));

    return Container(
      height: 90,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  backgroundColor.withValues(alpha: 0.9),
                  AppTheme.darkBackground.withValues(alpha: 0.8),
                ]
              : [
                  backgroundColor.withValues(alpha: 0.95),
                  Colors.white.withValues(alpha: 0.9),
                ],
        ),
        border: Border.all(
          color: isDark
              ? AppTheme.neonBlue.withValues(alpha: 0.2)
              : selectedColor.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppTheme.neonBlue.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
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
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            children: widget.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == widget.currentIndex;

              return Expanded(
                child: GestureDetector(
                  onTap: () => widget.onTap(index),
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: isSelected
                            ? Offset(0, _slideAnimation.value)
                            : Offset.zero,
                        child: Transform.scale(
                          scale: isSelected ? _scaleAnimation.value : 1.0,
                          child: Container(
                            height: 70,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // الأيقونة مع التأثير المتحرك
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: isSelected
                                        ? LinearGradient(
                                            colors: isDark
                                                ? [
                                                    AppTheme.neonBlue,
                                                    AppTheme.neonPurple
                                                  ]
                                                : [
                                                    selectedColor,
                                                    selectedColor.withValues(
                                                        alpha: 0.7)
                                                  ],
                                          )
                                        : null,
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: selectedColor.withValues(
                                                  alpha: 0.3),
                                              blurRadius: 12,
                                              spreadRadius: 0,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Icon(
                                    isSelected ? item.selectedIcon : item.icon,
                                    color: isSelected
                                        ? Colors.white
                                        : unselectedColor,
                                    size: isSelected ? 26 : 24,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                // النص مع التأثير المتحرك
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 200),
                                  style: TextStyle(
                                    color: isSelected
                                        ? selectedColor
                                        : unselectedColor,
                                    fontSize: isSelected ? 12 : 11,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    fontFamily: 'Poppins',
                                  ),
                                  child: Text(
                                    item.label,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const BottomNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

// Floating Action Button احترافي
class ProfessionalFloatingActionButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const ProfessionalFloatingActionButton({
    super.key,
    this.onPressed,
    required this.icon,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  State<ProfessionalFloatingActionButton> createState() =>
      _ProfessionalFloatingActionButtonState();
}

class _ProfessionalFloatingActionButtonState
    extends State<ProfessionalFloatingActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = widget.backgroundColor ??
        (isDark ? AppTheme.neonPurple : AppTheme.secondaryColor);
    final foregroundColor = widget.foregroundColor ?? Colors.white;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [AppTheme.neonBlue, AppTheme.neonPurple]
                      : [
                          backgroundColor,
                          backgroundColor.withValues(alpha: 0.8)
                        ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: backgroundColor.withValues(alpha: 0.3),
                    blurRadius: 16,
                    spreadRadius: 0,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: backgroundColor.withValues(alpha: 0.2),
                    blurRadius: 32,
                    spreadRadius: 0,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (widget.onPressed != null) {
                      _controller.forward().then((_) {
                        _controller.reverse();
                      });
                      HapticFeedback.mediumImpact();
                      widget.onPressed!();
                    }
                  },
                  onTapDown: (_) => _controller.forward(),
                  onTapUp: (_) => _controller.reverse(),
                  onTapCancel: () => _controller.reverse(),
                  borderRadius: BorderRadius.circular(32),
                  child: Container(
                    alignment: Alignment.center,
                    child: Icon(
                      widget.icon,
                      color: foregroundColor,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
