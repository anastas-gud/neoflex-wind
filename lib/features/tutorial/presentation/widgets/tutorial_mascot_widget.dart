import 'package:flutter/material.dart';
import 'package:neoflex_quest/core/constants/colors.dart';
import 'package:neoflex_quest/shared/widgets/animated_text.dart';

class TutorialMascotWidget extends StatefulWidget {
  final String title;
  final String message;
  final double mascotSize;
  final double boxWidth;
  final Duration typingSpeed;
  final Widget? buttons;

  const TutorialMascotWidget({
    this.title = '',
    required this.message,
    this.mascotSize = 150,
    this.boxWidth = 420,
    this.typingSpeed = const Duration(milliseconds: 30),
    this.buttons,
    Key? key,
  }) : super(key: key);

  @override
  _TutorialMascotWidgetState createState() => _TutorialMascotWidgetState();
}

class _TutorialMascotWidgetState extends State<TutorialMascotWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _typingController;
  late Animation<int> _typingAnimation;
  String _displayedMessage = '';

  @override
  void initState() {
    super.initState();
    _typingController = AnimationController(
      duration: Duration(milliseconds: widget.message.length * 30),
      vsync: this,
    );

    _typingAnimation = IntTween(
      begin: 0,
      end: widget.message.length,
    ).animate(_typingController)..addListener(() {
      setState(() {
        _displayedMessage = widget.message.substring(0, _typingAnimation.value);
      });
    });

    _typingController.forward();
  }

  @override
  void dispose() {
    _typingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: widget.boxWidth, minHeight: 600),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                constraints: BoxConstraints(maxWidth: widget.boxWidth * 0.85),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppColors.softLavender,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.title.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkPurple,
                          ),
                        ),
                      ),
                    AnimatedText(
                      text: _displayedMessage,
                      style: const TextStyle(
                        fontSize: 20,
                        color: AppColors.darkPurple,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/tutorial.png',
                    width: widget.mascotSize,
                    height: widget.mascotSize,
                    errorBuilder:
                        (_, __, ___) =>
                            Icon(Icons.android, size: widget.mascotSize),
                  ),
                  SizedBox(width: 10),
                  Column(
                    children: [if (widget.buttons != null) widget.buttons!],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
