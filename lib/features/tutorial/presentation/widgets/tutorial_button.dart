import 'package:flutter/material.dart';
import 'package:neoflex_quest/core/constants/colors.dart';

class TutorialButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final double width;
  final double height;
  final Color borderColor;
  final Color backgroundColor;
  final Color textColor;

  const TutorialButton({
    Key? key,
    required this.onPressed,
    required this.text,
    this.width = 150,
    this.height = 50,
    this.borderColor = AppColors.blue,
    this.backgroundColor = AppColors.white,
    this.textColor = AppColors.blue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: borderColor,
          backgroundColor: backgroundColor,
          side: BorderSide(color: borderColor, width: 2.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
