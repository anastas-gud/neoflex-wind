import 'dart:math';

import 'package:flutter/material.dart';
import 'package:neoflex_quest/core/constants/strings.dart';
import 'package:neoflex_quest/core/models/achievement.dart';
import 'package:neoflex_quest/core/models/user_achievement.dart';
import 'package:neoflex_quest/core/services/achievement_service.dart';
import 'package:neoflex_quest/core/services/data_service.dart';
import 'package:neoflex_quest/core/services/user_service.dart';
import 'package:neoflex_quest/shared/widgets/mascot_widget.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/database/database_service.dart';
import '../../../../core/services/data_service.dart';
import '../../../../shared/widgets/small_mascot_widget.dart';

class AchievementsScreen extends StatefulWidget {
  final int userId;

  AchievementsScreen({required this.userId});

  @override
  _AchievementsScreenState createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  late Future<List<Achievement>> _achievementsFuture;
  late Future<List<UserAchievement>> _userAchievementsFuture;

  @override
  void initState() {
    super.initState();
    final achievementService = AchievementService(userService: UserService());

    _achievementsFuture = achievementService.getAchievements();
    _userAchievementsFuture = achievementService.getUserAchievements(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: Future.wait([_achievementsFuture, _userAchievementsFuture]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Ошибка загрузки данных'));
          }

          final achievements = snapshot.data![0] as List<Achievement>;
          final userAchievements = snapshot.data![1] as List<UserAchievement>;

          double _boxWidth = min(MediaQuery.of(context).size.width * 0.9, 450);

          return SingleChildScrollView(
            padding: EdgeInsets.only(top: 16), // Добавили отступ сверху
            child: Column(
              children: [
                SizedBox(height: 15),
                Text(
                  'Галактика достижений'.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 25,
                    color: AppColors.pink,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1.8,
                  ),
                ),
                SmallMascotWidget(
                  message: AppStrings.achievementDescription,
                  imagePath: 'assets/images/achievement.png',
                  boxWidth: _boxWidth,
                  shift: 110,
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: achievements.map((achievement) {
                      final isUnlocked = userAchievements.any((ua) => ua.achievementId == achievement.id);

                      return Card(
                        color: isUnlocked ? Colors.orange[50] : Colors.grey[200],
                        margin: EdgeInsets.only(bottom: 16),
                        child: ListTile(
                          leading: achievement.isSecret && !isUnlocked
                              ? Icon(Icons.question_mark, size: 40) // Иконка "?" для секретных
                              : Image.asset(
                            achievement.iconPath,
                            width: 40,
                            height: 40,
                            errorBuilder: (_, __, ___) => Icon(Icons.star, size: 40),
                          ),
                          title: Text(
                            achievement.name, // Название показывается всегда
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isUnlocked ? Colors.black : Colors.grey,
                            ),
                          ),
                          subtitle: Text(
                            achievement.isSecret && !isUnlocked
                                ? "Разблокируйте, чтобы узнать описание"
                                : achievement.description,
                            style: TextStyle(
                              color: isUnlocked ? Colors.black87 : Colors.grey,
                            ),
                          ),
                          trailing: isUnlocked
                              ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle, color: Colors.green),
                              Text(
                                '+${achievement.pointsReward}',
                                style: TextStyle(color: Colors.green),
                              ),
                            ],
                          )
                              : Icon(Icons.lock, color: Colors.red),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}