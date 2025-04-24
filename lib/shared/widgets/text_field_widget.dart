import 'package:flutter/material.dart';
import 'package:neoflex_quest/core/constants/colors.dart';

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
        style: TextStyle(
          color: AppColors.lightPurple,
          fontWeight: FontWeight.w600,
          fontSize: 17,
        ),
        decoration: InputDecoration(
          labelText: labelText,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          prefixIcon:
              prefixIcon != null
                  ? Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: Icon(prefixIcon, color: AppColors.lightPurple),
                  )
                  : null,
          contentPadding: const EdgeInsets.only(
            top: 16,
            bottom: 16,
            left: 10,
            right: 15,
          ),
          labelStyle: TextStyle(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: AppColors.lightPurple,
          ),
          isDense: true,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.lightPurple, width: 2),
            borderRadius: BorderRadius.circular(25.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.blue, width: 2),
            borderRadius: BorderRadius.circular(25.0),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 3),
            borderRadius: BorderRadius.circular(25.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.blue, width: 2),
            borderRadius: BorderRadius.circular(25.0),
          ),
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
