import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../core/constants/theme/app_theme.dart';

class SuperFloatingActionButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isExpanded;
  final List<FloatingActionItem>? items;

  const SuperFloatingActionButton({
    super.key,
    this.onPressed,
    required this.icon,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.isExpanded = false,
    this.items,
  });

  @override
  State<SuperFloatingActionButton> createState() =>
      _SuperFloatingActionButtonState();
}

class _SuperFloatingActionButtonState extends State<SuperFloatingActionButton>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _rotationController;
  late AnimationController _pulseController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<Color?> _colorAnimation;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: math.pi / 4,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _colorAnimation = ColorTween(
      begin: widget.backgroundColor ?? AppTheme.neonPurple,
      end: AppTheme.neonBlue,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));

    // Start pulse animation loop
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.items != null && widget.items!.isNotEmpty) {
      _toggleExpanded();
    } else if (widget.onPressed != null) {
      _animatePress();
      widget.onPressed!();
    }
    HapticFeedback.mediumImpact();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _rotationController.forward();
    } else {
      _rotationController.reverse();
    }
  }

  void _animatePress() {
    _controller.forward().then((_) {
      _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _controller,
        _rotationController,
        _pulseController,
      ]),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.bottomRight,
          children: [
            // Expanded items
            if (widget.items != null && _isExpanded)
              ..._buildExpandedItems(isDark),

            // Main FAB
            Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.scale(
                scale: _pulseAnimation.value * 0.05 + 0.95,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _colorAnimation.value ?? AppTheme.neonPurple,
                        AppTheme.neonBlue,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (_colorAnimation.value ?? AppTheme.neonPurple)
                            .withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 0,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: AppTheme.neonBlue.withValues(alpha: 0.3),
                        blurRadius: 40,
                        spreadRadius: 0,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _handleTap,
                          onTapDown: (_) => _controller.forward(),
                          onTapUp: (_) => _controller.reverse(),
                          onTapCancel: () => _controller.reverse(),
                          borderRadius: BorderRadius.circular(32),
                          splashColor: Colors.white.withValues(alpha: 0.3),
                          child: Container(
                            alignment: Alignment.center,
                            child: Transform.rotate(
                              angle: _rotationAnimation.value,
                              child: Icon(
                                widget.icon,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildExpandedItems(bool isDark) {
    final items = widget.items ?? [];
    List<Widget> widgets = [];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final offset = (i + 1) * 80.0;

      widgets.add(
        Positioned(
          bottom: offset,
          right: 0,
          child: TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 200 + (i * 50)),
            tween: Tween(begin: 0.0, end: _isExpanded ? 1.0 : 0.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Transform.translate(
                  offset: Offset(0, (1 - value) * 20),
                  child: Opacity(
                    opacity: value,
                    child: _buildFloatingItem(item, isDark),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    return widgets;
  }

  Widget _buildFloatingItem(FloatingActionItem item, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.darkSurface.withValues(alpha: 0.9)
                : Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? AppTheme.neonBlue.withValues(alpha: 0.3)
                  : Colors.grey.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            item.label,
            style: TextStyle(
              color: isDark ? AppTheme.darkOnSurface : AppTheme.lightOnSurface,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Button
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                item.backgroundColor ?? AppTheme.neonPurple,
                AppTheme.neonBlue,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: (item.backgroundColor ?? AppTheme.neonPurple)
                    .withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                _toggleExpanded();
                item.onPressed();
              },
              borderRadius: BorderRadius.circular(24),
              child: Icon(
                item.icon,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class FloatingActionItem {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;

  const FloatingActionItem({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
  });
}
