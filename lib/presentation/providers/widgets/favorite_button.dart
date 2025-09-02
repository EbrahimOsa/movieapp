import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../data/models/movie_model.dart';
import '../favorites_provider.dart';

class FavoriteButton extends StatefulWidget {
  final Movie movie;
  final Color? iconColor;
  final double size;
  final bool showToast;

  const FavoriteButton({
    super.key,
    required this.movie,
    this.iconColor,
    this.size = 24.0,
    this.showToast = true,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    // تهيئة الـ Animation Controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // تهيئة Scale Animation
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    // تهيئة Color Animation
    _colorAnimation = ColorTween(
      begin: Colors.grey.shade400,
      end: Colors.red.shade600,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // تهيئة حالة المفضلة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final favoritesProvider = context.read<FavoritesProvider>();
        final isFavorite = favoritesProvider.isFavorite(widget.movie.id);
        if (isFavorite) {
          _animationController.value = 1.0;
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onPressed() async {
    final favoritesProvider = context.read<FavoritesProvider>();
    final bool currentFavoriteStatus =
        favoritesProvider.isFavorite(widget.movie.id);

    try {
      // إضافة Haptic Feedback
      HapticFeedback.lightImpact();

      // تشغيل الأنيميشن حسب الحالة الجديدة
      if (currentFavoriteStatus) {
        _animationController.reverse();
      } else {
        _animationController.forward();
      }

      // تبديل حالة المفضلة
      await favoritesProvider.toggleFavorite(widget.movie);

      // التحقق من أن الـ Widget ما زال موجوداً
      if (!mounted) return;

      if (widget.showToast) {
        final bool newFavoriteStatus =
            favoritesProvider.isFavorite(widget.movie.id);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newFavoriteStatus
                  ? 'تم إضافة "${widget.movie.title}" للمفضلة'
                  : 'تم حذف "${widget.movie.title}" من المفضلة',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: newFavoriteStatus
                ? Colors.green.shade600
                : Colors.orange.shade600,
            action: SnackBarAction(
              label: 'تراجع',
              textColor: Colors.white,
              onPressed: () async {
                try {
                  HapticFeedback.lightImpact();
                  await favoritesProvider.toggleFavorite(widget.movie);

                  if (mounted) {
                    final bool undoFavoriteStatus =
                        favoritesProvider.isFavorite(widget.movie.id);
                    if (undoFavoriteStatus) {
                      _animationController.forward();
                    } else {
                      _animationController.reverse();
                    }
                  }
                } catch (e) {
                  debugPrint('خطأ في التراجع: $e');
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('خطأ في تبديل المفضلة: $e');
      // إرجاع الأنيميشن للحالة الأصلية في حالة الخطأ
      if (mounted) {
        if (currentFavoriteStatus) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, child) {
        final bool isFavorite = favoritesProvider.isFavorite(widget.movie.id);

        // تحديث الأنيميشن حسب الحالة الحالية
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            if (isFavorite && _animationController.value < 0.5) {
              _animationController.forward();
            } else if (!isFavorite && _animationController.value > 0.5) {
              _animationController.reverse();
            }
          }
        });

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (_scaleAnimation.value - 1.0) * 0.3,
              child: Container(
                decoration: BoxDecoration(
                  color: isFavorite
                      ? Colors.red.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: isFavorite
                      ? Border.all(
                          color: Colors.red.withValues(alpha: 0.3),
                          width: 1,
                        )
                      : null,
                ),
                child: IconButton(
                  onPressed: _onPressed,
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite
                        ? _colorAnimation.value
                        : (widget.iconColor ??
                            Theme.of(context)
                                .iconTheme
                                .color
                                ?.withValues(alpha: 0.7)),
                    size: widget.size,
                  ),
                  tooltip: isFavorite ? 'حذف من المفضلة' : 'إضافة للمفضلة',
                  style: IconButton.styleFrom(
                    splashFactory: InkRipple.splashFactory,
                    highlightColor: Colors.red.withValues(alpha: 0.2),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
