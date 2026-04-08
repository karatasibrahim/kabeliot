import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

    try {
      await ref.read(authStateProvider.notifier).signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );
      // Başarılı → GoRouter redirect otomatik /home'a yönlendirir
    } on Exception catch (e) {
      if (!mounted) return;
      final raw = e.toString();
      debugPrint('LOGIN ERROR: $raw');
      final msg = _errorMessage(raw);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$msg\n\n$raw'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 10),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _errorMessage(String code) {
    if (code.contains('company-not-found')) return 'Hesabınız sisteme tanımlı değil.';
    if (code.contains('wrong-password') || code.contains('invalid-credential')) {
      return 'Hatalı e-posta veya şifre.';
    }
    if (code.contains('user-not-found')) return 'Bu e-posta ile kayıtlı hesap bulunamadı.';
    if (code.contains('network-request-failed')) return 'İnternet bağlantısı yok.';
    if (code.contains('too-many-requests')) return 'Çok fazla deneme. Lütfen bekleyin.';
    return 'Giriş başarısız. Lütfen tekrar deneyin.';
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

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
