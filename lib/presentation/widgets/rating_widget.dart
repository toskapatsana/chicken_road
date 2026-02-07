
import 'package:flutter/material.dart';

class RatingWidget extends StatelessWidget {
  final int? rating;
  final ValueChanged<int>? onRatingChanged;
  final double size;
  final bool readOnly;

  const RatingWidget({
    super.key,
    this.rating,
    this.onRatingChanged,
    this.size = 32,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        final isSelected = rating != null && starIndex <= rating!;
        
        return GestureDetector(
          onTap: readOnly ? null : () => onRatingChanged?.call(starIndex),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
              color: isSelected ? Colors.amber : Colors.grey.shade400,
              size: size,
            ),
          ),
        );
      }),
    );
  }
}

class RatingDisplay extends StatelessWidget {
  final int? rating;
  final int timesCooked;

  const RatingDisplay({
    super.key,
    this.rating,
    this.timesCooked = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        if (rating != null) ...[
          Icon(
            Icons.star_rounded,
            color: Colors.amber,
            size: 18,
          ),
          const SizedBox(width: 4),
          Text(
            '$rating/5',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
        ],
        if (timesCooked > 0) ...[
          Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            'Made $timesCooked ${timesCooked == 1 ? 'time' : 'times'}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
