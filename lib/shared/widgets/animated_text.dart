import 'package:flutter/material.dart';

class AnimatedText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const AnimatedText({required this.text, this.style});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: style, softWrap: true);
  }
}
