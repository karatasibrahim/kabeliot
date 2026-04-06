import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Kabel IoT — Standart metin girişi.
/// Focused glow, prefix/suffix icon, obscure toggle desteği.
class KabelTextField extends StatefulWidget {
  const KabelTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.isObscure = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.enabled = true,
    this.maxLines = 1,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool isObscure;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final bool enabled;
  final int maxLines;

  @override
  State<KabelTextField> createState() => _KabelTextFieldState();
}

class _KabelTextFieldState extends State<KabelTextField> {
  late bool _obscured;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _obscured = widget.isObscure;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (focused) => setState(() => _isFocused = focused),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: _isFocused
              ? [
                  BoxShadow(
                    color: AppColors.primaryGlow,
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          obscureText: _obscured,
          enabled: widget.enabled,
          maxLines: widget.isObscure ? 1 : widget.maxLines,
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onFieldSubmitted,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, color: _isFocused ? AppColors.primary : AppColors.textSecondary, size: 20.r)
                : null,
            suffixIcon: widget.isObscure
                ? IconButton(
                    icon: Icon(
                      _obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.textSecondary,
                      size: 20.r,
                    ),
                    onPressed: () => setState(() => _obscured = !_obscured),
                  )
                : widget.suffixIcon,
          ),
        ),
      ),
    );
  }
}
