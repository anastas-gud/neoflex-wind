import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:neoflex_quest/core/constants/colors.dart';
import 'animated_text.dart';

class MascotWidget extends StatefulWidget {
  final String title;
  final String message;
  final double mascotSize;
  final double boxWidth;
  final Duration typingSpeed;

  const MascotWidget({
    this.title = '',
    required this.message,
    this.mascotSize = 130,
    this.boxWidth = 350,
    this.typingSpeed = const Duration(milliseconds: 30),
    Key? key,
  }) : super(key: key);

  @override
  _MascotWidgetState createState() => _MascotWidgetState();
}

class _MascotWidgetState extends State<MascotWidget>
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
      constraints: BoxConstraints(maxWidth: widget.boxWidth),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                constraints: BoxConstraints(maxWidth: widget.boxWidth * 0.5),
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
                            color: AppColors.darkPurple
                          ),
                        ),
                      ),
                    AnimatedText(
                      text: _displayedMessage,
                      style: const TextStyle(fontSize: 16, color: AppColors.darkPurple),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 15),
              SvgPicture.asset(
                'assets/svg/neonchik.svg',
                width: widget.mascotSize,
                height: widget.mascotSize,
                placeholderBuilder:
                    (context) => Icon(Icons.android, size: widget.mascotSize),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
