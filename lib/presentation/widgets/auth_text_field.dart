// lib/presentation/widgets/auth_text_field.dart

import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class AuthTextField extends StatefulWidget {
  final String         label;
  final String?        hint;
  final bool           isPassword;
  final bool           enabled;
  final String?        errorText;
  final TextInputType  keyboardType;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final TextInputAction textInputAction;
  final IconData?      icon;
  final Color?         filledColor;
  final Color?         textColor;

  const AuthTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.isPassword      = false,
    this.enabled         = true,
    this.errorText,
    this.keyboardType    = TextInputType.text,
    this.validator,
    this.onChanged,
    this.textInputAction = TextInputAction.next,
    this.icon,
    this.filledColor,
    this.textColor,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller:     widget.controller,
      obscureText:    widget.isPassword && _obscure,
      keyboardType:   widget.keyboardType,
      textInputAction:widget.textInputAction,
      enabled:        widget.enabled,
      onChanged:      widget.onChanged,
      validator:      widget.validator,
      style:          TextStyle(color: widget.textColor ?? AppColors.textPrimary),
      decoration:     InputDecoration(
        labelText:  widget.label,
        labelStyle: TextStyle(color: widget.textColor?.withValues(alpha: 0.7) ?? AppColors.textSecondary),
        hintText:   widget.hint,
        errorText:  widget.errorText,
        prefixIcon: widget.icon != null ? Icon(widget.icon, color: widget.textColor?.withValues(alpha: 0.7) ?? AppColors.textSecondary) : null,
        filled:     widget.filledColor != null,
        fillColor:  widget.filledColor,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: widget.textColor?.withValues(alpha: 0.7) ?? AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : null,
        enabledBorder: widget.filledColor != null ? OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ) : null,
        focusedBorder: widget.filledColor != null ? OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ) : null,
      ),
    );
  }
}
