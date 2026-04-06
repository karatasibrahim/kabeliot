import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/providers/auth_state_provider.dart';
import '../../../../shared/widgets/gradient_scaffold.dart';
import '../../../../shared/widgets/kabel_button.dart';
import '../../../../shared/widgets/kabel_logo.dart';
import '../../../../shared/widgets/kabel_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    // TODO: Gerçek API çağrısı buraya gelecek
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;
    // Oturumu aç → GoRouter redirect otomatik /home'a yönlendirir
    ref.read(authStateProvider.notifier).setAuthenticated(true);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 48.h),
              const KabelLogo(size: LogoSize.medium, animate: true),
              SizedBox(height: 40.h),

              // Giriş kartı
              Container(
                padding: EdgeInsets.all(24.r),
                decoration: AppDecorations.cardElevated,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hoş Geldiniz', style: AppTextStyles.headingLarge),
                      SizedBox(height: 4.h),
                      Text(
                        'IoT kontrol panelinize giriş yapın',
                        style: AppTextStyles.bodyMedium,
                      ),
                      SizedBox(height: 28.h),

                      KabelTextField(
                        label: 'E-posta',
                        hint: 'ornek@kabel.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        prefixIcon: Icons.email_outlined,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'E-posta gerekli';
                          if (!v.contains('@')) return 'Geçerli e-posta girin';
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),

                      KabelTextField(
                        label: 'Şifre',
                        controller: _passwordController,
                        isObscure: true,
                        textInputAction: TextInputAction.done,
                        prefixIcon: Icons.lock_outline,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Şifre gerekli';
                          if (v.length < 6) return 'En az 6 karakter';
                          return null;
                        },
                        onFieldSubmitted: (_) => _onLogin(),
                      ),
                      SizedBox(height: 8.h),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            'Şifremi Unuttum',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),

                      KabelButton(
                        label: 'Giriş Yap',
                        onPressed: _isLoading ? null : _onLogin,
                        isLoading: _isLoading,
                        icon: Icons.login_rounded,
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideY(
                    begin: 0.1,
                    end: 0,
                    duration: 500.ms,
                    delay: 200.ms,
                    curve: Curves.easeOutCubic,
                  ),

              SizedBox(height: 24.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Hesabınız yok mu? ', style: AppTextStyles.bodyMedium),
                  TextButton(
                    onPressed: () => context.push(AppRoutes.register),
                    child: const Text('Kayıt Ol'),
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms, delay: 400.ms),

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
