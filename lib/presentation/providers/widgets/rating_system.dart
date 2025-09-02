import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RatingWidget extends StatefulWidget {
  final double currentRating;
  final Function(double) onRatingChanged;
  final double size;
  final bool readOnly;
  final Color? activeColor;
  final Color? inactiveColor;

  const RatingWidget({
    super.key,
    this.currentRating = 0.0,
    required this.onRatingChanged,
    this.size = 24,
    this.readOnly = false,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  State<RatingWidget> createState() => _RatingWidgetState();
}

class _RatingWidgetState extends State<RatingWidget>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _colorController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  double _currentRating = 0.0;
  int _hoveredStar = -1;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.currentRating;

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _colorController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _colorAnimation = ColorTween(
      begin: widget.activeColor ?? Colors.amber,
      end: Colors.orange,
    ).animate(CurvedAnimation(
      parent: _colorController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  void _handleTap(int starIndex) {
    if (widget.readOnly) return;

    setState(() {
      _currentRating = (starIndex + 1).toDouble();
    });

    // Trigger animation
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });

    _colorController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _colorController.reverse();
      });
    });

    widget.onRatingChanged(_currentRating);

    // Haptic feedback
    HapticFeedback.lightImpact();
  }

  void _handleHover(int starIndex) {
    if (widget.readOnly) return;

    setState(() {
      _hoveredStar = starIndex;
    });
  }

  void _handleHoverExit() {
    if (widget.readOnly) return;

    setState(() {
      _hoveredStar = -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.activeColor ?? Colors.amber;
    final inactiveColor = widget.inactiveColor ?? Colors.grey[300]!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final isFilled = index < _currentRating;
        final isHovered = index <= _hoveredStar;
        final shouldHighlight = _hoveredStar >= 0 ? isHovered : isFilled;

        return MouseRegion(
          onEnter: (_) => _handleHover(index),
          onExit: (_) => _handleHoverExit(),
          child: GestureDetector(
            onTap: () => _handleTap(index),
            child: AnimatedBuilder(
              animation: Listenable.merge([_scaleAnimation, _colorAnimation]),
              builder: (context, child) {
                final scale = isFilled ? _scaleAnimation.value : 1.0;
                final color = isFilled
                    ? (_colorAnimation.value ?? activeColor)
                    : inactiveColor;

                return Transform.scale(
                  scale: scale,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      shouldHighlight ? Icons.star : Icons.star_border,
                      size: widget.size,
                      color: shouldHighlight ? color : inactiveColor,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }),
    );
  }
}

class ReviewCard extends StatelessWidget {
  final String authorName;
  final String? avatarUrl;
  final double rating;
  final String review;
  final DateTime date;
  final int likesCount;
  final bool isLiked;
  final VoidCallback? onLike;

  const ReviewCard({
    super.key,
    required this.authorName,
    this.avatarUrl,
    required this.rating,
    required this.review,
    required this.date,
    this.likesCount = 0,
    this.isLiked = false,
    this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author info and rating
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 20,
                  backgroundImage:
                      avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                  child: avatarUrl == null
                      ? Text(authorName.isNotEmpty
                          ? authorName[0].toUpperCase()
                          : 'U')
                      : null,
                ),

                const SizedBox(width: 12),

                // Name and date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authorName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        _formatDate(date),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                            ),
                      ),
                    ],
                  ),
                ),

                // Rating
                RatingWidget(
                  currentRating: rating,
                  onRatingChanged: (_) {}, // Read-only
                  readOnly: true,
                  size: 16,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Review text
            Text(
              review,
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 12),

            // Like button
            Row(
              children: [
                const Spacer(),
                TextButton.icon(
                  onPressed: onLike,
                  icon: Icon(
                    isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                    size: 18,
                    color:
                        isLiked ? Theme.of(context).colorScheme.primary : null,
                  ),
                  label: Text(
                    '$likesCount',
                    style: TextStyle(
                      color: isLiked
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}

class WriteReviewDialog extends StatefulWidget {
  final Function(double rating, String review) onSubmit;

  const WriteReviewDialog({
    super.key,
    required this.onSubmit,
  });

  @override
  State<WriteReviewDialog> createState() => _WriteReviewDialogState();
}

class _WriteReviewDialogState extends State<WriteReviewDialog> {
  double _rating = 0.0;
  final _reviewController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _submitReview() async {
    if (_rating == 0.0 || _reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a rating and review'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await Future.delayed(
          const Duration(milliseconds: 500)); // Simulate API call
      widget.onSubmit(_rating, _reviewController.text.trim());
      Navigator.of(context).pop();
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Write a Review'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rating section
          Text(
            'Your Rating',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          RatingWidget(
            currentRating: _rating,
            onRatingChanged: (rating) {
              setState(() {
                _rating = rating;
              });
            },
            size: 28,
          ),

          const SizedBox(height: 16),

          // Review text field
          Text(
            'Your Review',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _reviewController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Share your thoughts about this movie...',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting
              ? null
              : () {
                  Navigator.of(context).pop();
                },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitReview,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Submit'),
        ),
      ],
    );
  }
}
