import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MascotWidget extends StatelessWidget {
  final String title;
  final String message;
  final double mascotSize;
  final double boxWidth;

  const MascotWidget({
    this.title = '',
    required this.message,
    this.mascotSize = 150,
    this.boxWidth = 350,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: boxWidth),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                constraints: BoxConstraints(maxWidth: boxWidth * 0.5),
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
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    Text(
                      message,
                      style: const TextStyle(fontSize: 16),
                      softWrap: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 15),
              SvgPicture.asset(
                'assets/svg/neonchik.svg',
                width: mascotSize,
                height: mascotSize,
                placeholderBuilder: (context) => CircularProgressIndicator(),
                errorBuilder:
                    (_, __, ___) => Icon(Icons.android, size: mascotSize),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
