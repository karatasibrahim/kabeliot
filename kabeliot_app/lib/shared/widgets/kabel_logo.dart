import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Kabel Teknoloji marka logo widget'ı.
/// [size] ile boyut ayarlanabilir. [animate] ile açılış animasyonu eklenebilir.
class KabelLogo extends StatelessWidget {
  const KabelLogo({
    super.key,
    this.size = LogoSize.medium,
    this.animate = false,
    this.showTagline = false,
  });

  final LogoSize size;
  final bool animate;
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    final iconSize = switch (size) {
      LogoSize.small => 32.r,
      LogoSize.medium => 48.r,
      LogoSize.large => 64.r,
    };

    final titleStyle = switch (size) {
      LogoSize.small => AppTextStyles.headingSmall,
      LogoSize.medium => AppTextStyles.headingLarge,
      LogoSize.large => AppTextStyles.displayLarge,
    };

    Widget logo = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // İkon — devre kartı simgesi
        Container(
          width: iconSize * 1.5,
          height: iconSize * 1.5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryGlow,
            border: Border.all(color: AppColors.primary, width: 1.5),
          ),
          child: Icon(
            Icons.developer_board_rounded,
            color: AppColors.primary,
            size: iconSize,
          ),
        ),
        SizedBox(height: 12.h),
        // İsim
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'KABEL',
                style: titleStyle.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
              TextSpan(
                text: ' IoT',
                style: titleStyle.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
        if (showTagline) ...[
          SizedBox(height: 6.h),
          Text(
            'Akıllı Cihaz Yönetimi',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.accent,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ],
    );

    if (animate) {
      logo = logo
          .animate()
          .fadeIn(duration: 600.ms, delay: 300.ms)
          .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: 300.ms, curve: Curves.easeOutCubic);
    }

    return logo;
  }
}

enum LogoSize { small, medium, large }
