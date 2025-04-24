import 'package:flutter/material.dart';
import 'package:neoflex_quest/core/constants/colors.dart';

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
      margin: EdgeInsets.only(bottom: 15),
      child: InkWell(
        onTap: canAttempt ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.orange,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Text(description),
              SizedBox(height: 5),
              Text(
                'Попыток: $attemptsLeft/3',
                style: TextStyle(
                  color:
                      attemptsLeft > 0
                          ? AppColors.softOrange
                          : AppColors.deepPinkPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: canAttempt ? onTap : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        canAttempt ? AppColors.pink : AppColors.white,
                    side: BorderSide(
                      color:
                          canAttempt
                              ? AppColors.pink
                              : AppColors.deepPinkPurple,
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  ),
                  child: Text(
                    canAttempt ? 'Начать' : 'Попытки исчерпаны',
                    style: TextStyle(
                      fontSize: 16,
                      color:
                          canAttempt
                              ? AppColors.white
                              : AppColors.deepPinkPurple,
                    ),
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
