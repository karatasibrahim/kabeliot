import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/providers/auth_state_provider.dart';
import '../../../shared/widgets/gradient_scaffold.dart';
import '../../../shared/widgets/kabel_logo.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2800));
    if (!mounted) return;

    // Token kontrolü — şimdilik daima login'e yönlendir
    // Gerçek implementasyonda SecureStorageService ile token kontrol edilecek
    final isAuthenticated = ref.read(authStateProvider);
    if (mounted) {
      context.go(isAuthenticated ? AppRoutes.home : AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 3),
            // Logo
            const KabelLogo(
              size: LogoSize.large,
              animate: true,
              showTagline: true,
            ),
            const Spacer(flex: 2),
            // Alt bilgi + progress
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 48.w),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: LinearProgressIndicator(
                      minHeight: 3.h,
                      backgroundColor: AppColors.border,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Bağlanıyor...',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textDisabled,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 1200.ms),
            ),
            SizedBox(height: 48.h),
          ],
        ),
      ),
    );
  }
}
