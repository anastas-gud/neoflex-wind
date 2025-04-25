import 'package:flutter/material.dart';
import 'package:neoflex_quest/core/constants/colors.dart';

class SmallMascotWidget extends StatelessWidget {
  final String message;
  final double mascotSize;
  final double boxWidth;
  final String? imagePath;
  final double? shift;

  const SmallMascotWidget({
    required this.message,
    this.mascotSize = 150,
    this.boxWidth = 400,
    this.imagePath,
    this.shift,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: boxWidth),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            margin: EdgeInsets.only(top: shift ?? mascotSize * 0.75, right: 5),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AppColors.lightLavender,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.middlePurple,
                  ),
                  softWrap: true,
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Image.asset(
              imagePath.toString(),
              width: mascotSize,
              height: mascotSize,
              errorBuilder:
                  (_, __, ___) => Icon(
                    Icons.android,
                    size: mascotSize,
                    color: AppColors.pink,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
