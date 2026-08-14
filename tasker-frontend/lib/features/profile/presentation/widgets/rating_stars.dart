import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final Color color;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 16,
    this.color = AppColors.warning,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        IconData iconData;
        if (rating >= index + 1) {
          iconData = Icons.star;
        } else if (rating > index && rating < index + 1) {
          iconData = Icons.star_half;
        } else {
          iconData = Icons.star_border;
        }
        return Icon(iconData, size: size, color: color);
      }),
    );
  }
}
