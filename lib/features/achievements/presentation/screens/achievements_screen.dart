import 'package:flutter/material.dart';
import 'package:neoflex_quest/core/models/achievement.dart';
import 'package:neoflex_quest/core/models/user_achievement.dart';
import 'package:neoflex_quest/core/services/achievement_service.dart';
import 'package:neoflex_quest/core/services/data_service.dart';
import 'package:neoflex_quest/shared/widgets/mascot_widget.dart';

import '../../../../core/database/database_service.dart';
import '../../../../core/services/data_service.dart';

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
    final achievementService = AchievementService(
      databaseService: DatabaseService(),
    );

    _achievementsFuture = achievementService.getAllAchievements();
    _userAchievementsFuture = achievementService.getUserAchievements(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Галактика достижений'),
        centerTitle: true,
      ),
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

          return Column(
            children: [
              MascotWidget(
                message: 'Загрузка миссионного модуля...\n\n'
                    'Юнит, перед тобой карта твоих прошлых и будущих триумфов. '
                    'Каждое достижение – вызов, который сделает тебя сильнее. '
                    'Собери все, и возможно, откроешь то, что скрыто в тени…\n\n'
                    'Готов к новым победам?',
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: achievements.length,
                  itemBuilder: (context, index) {
                    final achievement = achievements[index];
                    final isUnlocked = userAchievements
                        .any((ua) => ua.achievementId == achievement.id);

                    return Card(
                      color: isUnlocked ? Colors.orange[50] : Colors.grey[200],
                      margin: EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        leading: Image.asset(
                          achievement.iconPath,
                          width: 40,
                          height: 40,
                          errorBuilder: (_, __, ___) => Icon(Icons.star, size: 40),
                        ),
                        title: Text(
                          achievement.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isUnlocked ? Colors.black : Colors.grey,
                          ),
                        ),
                        subtitle: Text(
                          achievement.description,
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
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}