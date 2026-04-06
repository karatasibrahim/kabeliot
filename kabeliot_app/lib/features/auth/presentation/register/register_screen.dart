import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/gradient_scaffold.dart';
import '../../../../shared/widgets/kabel_button.dart';
import '../../../../shared/widgets/kabel_logo.dart';
import '../../../../shared/widgets/kabel_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  int _passwordStrength = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onPasswordChanged(String value) {
    int strength = 0;
    if (value.length >= 8) strength++;
    if (value.contains(RegExp(r'[A-Z]'))) strength++;
    if (value.contains(RegExp(r'[0-9]'))) strength++;
    if (value.contains(RegExp(r'[!@#\$%^&*]'))) strength++;
    setState(() => _passwordStrength = strength);
  }

  void _onRegister() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    // TODO: Auth implementasyonu eklenecek
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isLoading = false);
        context.go(AppRoutes.login);
      }
    });
  }

  Color _strengthColor(int index) {
    if (_passwordStrength == 0) return AppColors.border;
    if (index >= _passwordStrength) return AppColors.border;
    return switch (_passwordStrength) {
      1 => AppColors.error,
      2 => AppColors.warning,
      3 => AppColors.accent,
      _ => AppColors.success,
    };
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 32.h),
              const KabelLogo(size: LogoSize.small, animate: true),
              SizedBox(height: 32.h),

              Container(
                padding: EdgeInsets.all(24.r),
                decoration: AppDecorations.cardElevated,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hesap Oluştur', style: AppTextStyles.headingLarge),
                      SizedBox(height: 4.h),
                      Text('IoT platformuna katılın', style: AppTextStyles.bodyMedium),
                      SizedBox(height: 28.h),

                      KabelTextField(
                        label: 'Ad Soyad',
                        controller: _nameController,
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        prefixIcon: Icons.person_outline,
                        validator: (v) => (v == null || v.isEmpty) ? 'Ad Soyad gerekli' : null,
                      ),
                      SizedBox(height: 16.h),

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
                        textInputAction: TextInputAction.next,
                        prefixIcon: Icons.lock_outline,
                        onChanged: _onPasswordChanged,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Şifre gerekli';
                          if (v.length < 6) return 'En az 6 karakter';
                          return null;
                        },
                      ),
                      SizedBox(height: 8.h),

                      // Şifre güç göstergesi
                      Row(
                        children: List.generate(4, (i) => Expanded(
                          child: Container(
                            margin: EdgeInsets.only(right: i < 3 ? 4.w : 0),
                            height: 4.h,
                            decoration: BoxDecoration(
                              color: _strengthColor(i),
                              borderRadius: BorderRadius.circular(2.r),
                            ),
                          ),
                        )),
                      ),
                      SizedBox(height: 16.h),

                      KabelTextField(
                        label: 'Şifre Tekrar',
                        controller: _confirmController,
                        isObscure: true,
                        textInputAction: TextInputAction.done,
                        prefixIcon: Icons.lock_outline,
                        validator: (v) {
                          if (v != _passwordController.text) return 'Şifreler eşleşmiyor';
                          return null;
                        },
                        onFieldSubmitted: (_) => _onRegister(),
                      ),
                      SizedBox(height: 24.h),

                      KabelButton(
                        label: 'Kayıt Ol',
                        onPressed: _isLoading ? null : _onRegister,
                        isLoading: _isLoading,
                        icon: Icons.person_add_outlined,
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 500.ms, delay: 150.ms).slideY(
                    begin: 0.1, end: 0, duration: 500.ms, delay: 150.ms, curve: Curves.easeOutCubic,
                  ),

              SizedBox(height: 24.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Zaten hesabınız var mı? ', style: AppTextStyles.bodyMedium),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Giriş Yap'),
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms, delay: 350.ms),

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
