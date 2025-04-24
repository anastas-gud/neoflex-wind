import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';

class SecondaryButtonWidget extends StatelessWidget {
  final double boxWidth;
  final String text;
  final Widget? child;
  final VoidCallback? onPressed;
  final Color borderColor; // Новый параметр: цвет границы
  final Color backgroundColor; // Новый параметр: цвет фона
  final Color textColor; // Новый параметр: цвет текста

  const SecondaryButtonWidget({
    this.text = "",
    this.boxWidth = 100,
    this.child,
    this.onPressed,
    this.borderColor = AppColors.blue,
    this.backgroundColor = AppColors.blue,
    this.textColor = Colors.black45,
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
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
            ),
            elevation: 0,
          ),
          child: child ??
              Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textColor, // Убедитесь, что цвет текста применяется
                ),
              ),
        ),
      ),
    );
  }
}
