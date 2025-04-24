import 'package:flutter/material.dart';

class EraCard extends StatelessWidget {
  final BuildContext context;
  final String title;
  final String description;
  final int attemptsLeft;
  final VoidCallback onTap;

  const EraCard({
    super.key,
    required this.context,
    required this.title,
    required this.description,
    required this.attemptsLeft,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final canAttempt = attemptsLeft > 0;
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: canAttempt ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(description),
              Text(
                'Попыток: $attemptsLeft/3',
                style: TextStyle(
                  color: attemptsLeft > 0 ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: canAttempt ? onTap : null,
                  child: Text(canAttempt ? 'Начать' : 'Попытки исчерпаны'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canAttempt ? null : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
