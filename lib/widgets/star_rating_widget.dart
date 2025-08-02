import 'package:flutter/material.dart';

class StarRatingWidget extends StatefulWidget {
  final double initialRating;
  final double size;
  final Color? color;
  final Color? unratedColor;
  final bool allowHalfRating;
  final bool readOnly;
  final Function(double)? onRatingChanged;
  final int maxRating;

  const StarRatingWidget({
    super.key,
    this.initialRating = 0.0,
    this.size = 24.0,
    this.color,
    this.unratedColor,
    this.allowHalfRating = false,
    this.readOnly = false,
    this.onRatingChanged,
    this.maxRating = 5,
  });

  @override
  State<StarRatingWidget> createState() => _StarRatingWidgetState();
}

class _StarRatingWidgetState extends State<StarRatingWidget>
    with TickerProviderStateMixin {
  late double _rating;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onStarTap(double starRating) {
    if (widget.readOnly) return;

    setState(() {
      _rating = starRating;
    });

    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    widget.onRatingChanged?.call(_rating);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.color ?? theme.colorScheme.primary;
    final unratedColor = widget.unratedColor ?? theme.colorScheme.outline;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.maxRating, (index) {
        final starValue = index + 1.0;
        final isHalfStar =
            widget.allowHalfRating && _rating > index && _rating < starValue;
        final isFullStar = _rating >= starValue;

        return GestureDetector(
          onTap: () => _onStarTap(starValue),
          onTapDown: (_) {
            if (!widget.readOnly) {
              _animationController.forward();
            }
          },
          onTapUp: (_) {
            if (!widget.readOnly) {
              _animationController.reverse();
            }
          },
          onTapCancel: () {
            if (!widget.readOnly) {
              _animationController.reverse();
            }
          },
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: Icon(
                    isFullStar
                        ? Icons.star
                        : isHalfStar
                        ? Icons.star_half
                        : Icons.star_border,
                    size: widget.size,
                    color: isFullStar || isHalfStar ? color : unratedColor,
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

class StarRatingDisplay extends StatelessWidget {
  final double rating;
  final double size;
  final Color? color;
  final Color? unratedColor;
  final bool showRating;
  final TextStyle? ratingTextStyle;
  final int maxRating;

  const StarRatingDisplay({
    super.key,
    required this.rating,
    this.size = 20.0,
    this.color,
    this.unratedColor,
    this.showRating = false,
    this.ratingTextStyle,
    this.maxRating = 5,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = this.color ?? theme.colorScheme.primary;
    final unratedColor = this.unratedColor ?? theme.colorScheme.outline;
    final textStyle = ratingTextStyle ?? theme.textTheme.bodySmall;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(maxRating, (index) {
          final starValue = index + 1.0;
          final isHalfStar = rating > index && rating < starValue;
          final isFullStar = rating >= starValue;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 1.0),
            child: Icon(
              isFullStar
                  ? Icons.star
                  : isHalfStar
                  ? Icons.star_half
                  : Icons.star_border,
              size: size,
              color: isFullStar || isHalfStar ? color : unratedColor,
            ),
          );
        }),
        if (showRating) ...[
          const SizedBox(width: 4.0),
          Text(rating.toStringAsFixed(1), style: textStyle),
        ],
      ],
    );
  }
}

class StarRatingWithLabel extends StatelessWidget {
  final String label;
  final double rating;
  final double size;
  final Color? color;
  final Color? unratedColor;
  final bool showRating;
  final TextStyle? labelStyle;
  final TextStyle? ratingTextStyle;
  final int maxRating;

  const StarRatingWithLabel({
    super.key,
    required this.label,
    required this.rating,
    this.size = 20.0,
    this.color,
    this.unratedColor,
    this.showRating = false,
    this.labelStyle,
    this.ratingTextStyle,
    this.maxRating = 5,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = this.labelStyle ?? theme.textTheme.bodyMedium;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(width: 8.0),
        StarRatingDisplay(
          rating: rating,
          size: size,
          color: color,
          unratedColor: unratedColor,
          showRating: showRating,
          ratingTextStyle: ratingTextStyle,
          maxRating: maxRating,
        ),
      ],
    );
  }
}
