import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';

class CustomTextFormField extends StatelessWidget {
  final double boxWidth;
  final TextEditingController? controller;
  final String? labelText;
  final IconData? prefixIcon;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;

  const CustomTextFormField({
    this.boxWidth = 300,
    this.controller,
    this.labelText,
    this.prefixIcon,
    this.obscureText = false,
    this.validator,
    this.keyboardType,
    this.onChanged,
    this.onSubmitted,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: boxWidth),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(color: AppColors.blue),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 15,
          ),
          // Исправленный вариант для labelStyle
          labelStyle: TextStyle(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          ),
          // Добавляем отступы вокруг всего label
          isDense: true,
        ),
        obscureText: obscureText,
        validator: validator,
        keyboardType: keyboardType,
        onChanged: onChanged,
        onFieldSubmitted: onSubmitted,
      ),
    );
  }
}