import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class DynamicBackground extends StatelessWidget {
  final Widget child;
  final String? categoryName;
  final bool isHome;

  const DynamicBackground({
    super.key,
    required this.child,
    this.categoryName,
    this.isHome = false,
  });

  String get _imagePath {
    if (isHome) return 'assets/images/home_bg.jpg';
    if (categoryName != null) {
      final name = categoryName!.toLowerCase();
      if (name.contains('plumb')) return 'assets/images/plumbing_bg.jpg';
      if (name.contains('clean')) return 'assets/images/cleaning_bg.jpg';
      if (name.contains('electric')) return 'assets/images/electrical_bg.jpg';
    }
    return 'assets/images/home_bg.jpg'; // fallback
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundPrimary,
        image: DecorationImage(
          image: AssetImage(_imagePath),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            AppColors.backgroundPrimary.withOpacity(0.85),
            BlendMode.srcOver,
          ),
        ),
      ),
      child: child,
    );
  }
}
