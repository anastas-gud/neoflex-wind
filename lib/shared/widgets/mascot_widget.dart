import 'package:flutter/material.dart';

class MascotWidget extends StatelessWidget {
  final String message;
  final double mascotSize;

  const MascotWidget({
    required this.message,
    this.mascotSize = 100,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Image.asset(
            'assets/images/mascot.png',
            width: mascotSize,
            height: mascotSize,
            errorBuilder: (_, __, ___) => Icon(Icons.android, size: mascotSize),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message,
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}