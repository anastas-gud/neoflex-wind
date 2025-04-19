import 'package:flutter/material.dart';

class SecondaryButtonWidget extends StatelessWidget {
  final boxWidth;
  final String text;
  final Widget? child;
  final VoidCallback? onPressed;

  const SecondaryButtonWidget({
    this.text = "",
    this.boxWidth = 100,
    this.child,
    this.onPressed,
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
          child:
              child ??
              Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
        ),
      ),
    );
  }
}
