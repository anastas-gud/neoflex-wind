import 'package:flutter/material.dart';

class SmallMascotWidget extends StatelessWidget {
  final String title;
  final String message;
  final double mascotSize;
  final double boxWidth;
  final double overlap;

  const SmallMascotWidget({
    this.title = '',
    required this.message,
    this.mascotSize = 60,
    this.boxWidth = 450,
    this.overlap = 60,
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
            margin: EdgeInsets.only(
              top: mascotSize / 3,
              right: mascotSize - overlap,
            ),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Text(
                  message,
                  style: const TextStyle(fontSize: 15),
                  softWrap: true,
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Image.asset(
              'assets/images/neon1.png',
              width: mascotSize,
              height: mascotSize,
              errorBuilder:
                  (_, __, ___) => Icon(Icons.android, size: mascotSize),
            ),
          ),
        ],
      ),
    );
  }
}
