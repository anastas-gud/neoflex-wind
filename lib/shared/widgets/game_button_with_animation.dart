import 'package:flutter/material.dart';
import 'package:neoflex_quest/core/constants/colors.dart';

class GameButtonWithAnimation extends StatefulWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;

  const GameButtonWithAnimation({
    required this.title,
    required this.imagePath,
    required this.onTap,
  });

  @override
  _GameButtonWithAnimationState createState() =>
      _GameButtonWithAnimationState();
}

class _GameButtonWithAnimationState extends State<GameButtonWithAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 0.1),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SlideTransition(
            position: _offsetAnimation,
            child: Image.asset(
              widget.imagePath,
              width: 200,
              errorBuilder:
                  (_, __, ___) => Icon(Icons.question_mark, size: 100),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 24,
              color: AppColors.pink,
              fontWeight: FontWeight.bold,
              letterSpacing: -1.8,
            ),
          ),
        ],
      ),
    );
  }
}
