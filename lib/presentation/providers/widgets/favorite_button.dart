import 'package:flutter/material.dart';
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
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _colorAnimation = ColorTween(
      begin: Colors.grey,
      end: Colors.red,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Initialize favorite status from provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final favoritesProvider = context.read<FavoritesProvider>();
      _isFavorite = favoritesProvider.isFavorite(widget.movie.id);
      if (_isFavorite) {
        _animationController.value = 1.0;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _onPressed() async {
    final favoritesProvider = context.read<FavoritesProvider>();

    // Trigger scale animation
    await _scaleController.forward();
    _scaleController.reverse();

    // Toggle favorite status in provider
    await favoritesProvider.toggleFavorite(widget.movie);

    // Update local state
    setState(() {
      _isFavorite = favoritesProvider.isFavorite(widget.movie.id);
    });

    // Update animations
    if (_isFavorite) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }

    if (widget.showToast) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              _isFavorite ? 'Added to favorites' : 'Removed from favorites'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () async {
              // Undo the action
              await favoritesProvider.toggleFavorite(widget.movie);
              setState(() {
                _isFavorite = favoritesProvider.isFavorite(widget.movie.id);
              });
              if (_isFavorite) {
                _animationController.forward();
              } else {
                _animationController.reverse();
              }
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _colorAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              color: _isFavorite
                  ? Colors.red.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              onPressed: _onPressed,
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite
                    ? _colorAnimation.value
                    : (widget.iconColor ??
                        Theme.of(context).iconTheme.color?.withOpacity(0.7)),
                size: widget.size,
              ),
              tooltip:
                  _isFavorite ? 'Remove from favorites' : 'Add to favorites',
              style: IconButton.styleFrom(
                splashFactory: InkRipple.splashFactory,
                highlightColor: Colors.red.withOpacity(0.1),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Helper class to track favorite movies globally
class FavoriteMoviesManager {
  static final Set<int> _favoriteIds = <int>{};

  static bool isFavorite(int movieId) {
    return _favoriteIds.contains(movieId);
  }

  static void toggleFavorite(int movieId) {
    if (_favoriteIds.contains(movieId)) {
      _favoriteIds.remove(movieId);
    } else {
      _favoriteIds.add(movieId);
    }
  }

  static Set<int> get favoriteIds => Set.from(_favoriteIds);

  static int get favoriteCount => _favoriteIds.length;
}
