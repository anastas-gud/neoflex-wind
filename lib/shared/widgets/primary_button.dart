import 'package:flutter/material.dart';
import 'package:neoflex_quest/core/constants/colors.dart';

class PrimaryButtonWidget extends StatelessWidget {
  final double boxWidth;
  final String text;
  final Widget? child;
  final VoidCallback? onPressed;
  final Color borderColor;
  final Color backgroundColor;
  final Color textColor;

  const PrimaryButtonWidget({
    this.text = "",
    this.boxWidth = 100,
    this.child,
    this.onPressed,
    this.borderColor = AppColors.softOrange,
    this.backgroundColor = AppColors.softOrange,
    this.textColor = AppColors.delicatePink,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: boxWidth),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            side: BorderSide(color: borderColor),
            backgroundColor: backgroundColor,
            foregroundColor: textColor,
            padding: const EdgeInsets.symmetric(vertical: 19, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
              side: BorderSide(color: borderColor, width: 2),
            ),
            elevation: 0,
          ),
          child:
              child ??
              Text(
                text,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
        ),
      ),
    );
  }
}
