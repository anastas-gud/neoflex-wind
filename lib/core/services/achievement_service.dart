import 'package:neoflex_quest/core/models/achievement.dart';
import 'package:neoflex_quest/core/models/user_achievement.dart';
import 'package:neoflex_quest/core/services/data_service.dart';

import '../database/database_service.dart';

class AchievementService {
  final DatabaseService _databaseService;

  AchievementService({required DatabaseService databaseService})
      : _databaseService = databaseService;

  // Получаем все возможные достижения
  Future<List<Achievement>> getAllAchievements() async {
    return [
      Achievement(
        id: 1,
        name: 'Фанат мандаринок',
        description: 'Попытаться снять кожуру с мандаринки в Торговой точке',
        pointsReward: 10,
        isSecret: true,
        iconPath: 'assets/images/achievements/mandarin_fan.png',
      ),
      Achievement(
        id: 2,
        name: 'Хронозавр',
        description: 'Пройти блок Машина времени на 100%',
        pointsReward: 50,
        iconPath: 'assets/images/achievements/time_master.png',
      ),
      Achievement(
        id: 3,
        name: 'Неопедия',
        description: 'Пройти блок Образовательные миссии на 100%',
        pointsReward: 50,
        iconPath: 'assets/images/achievements/neo_pedia.png',
      ),
      Achievement(
        id: 4,
        name: 'Аномалия',
        description: 'Пройти все временные точки в блоке Машина времени',
        pointsReward: 30,
        iconPath: 'assets/images/achievements/anomaly.png',
      ),
      Achievement(
        id: 5,
        name: 'Ответственный сортировщик',
        description: 'Расположить модули по контейнерам в блоке Образовательные миссии',
        pointsReward: 30,
        iconPath: 'assets/images/achievements/sorter.png',
      ),
    ];
  }

  // Получаем достижения конкретного пользователя
  Future<List<UserAchievement>> getUserAchievements(int userId) async {
    final conn = await _databaseService.getConnection();
    try {
      final results = await conn.query(
        'SELECT * FROM user_achievements WHERE user_id = @userId',
        substitutionValues: {'userId': userId},
      );

      return results.map((row) => UserAchievement(
        id: row[0] as int,
        userId: row[1] as int,
        achievementId: row[2] as int,
        earnedAt: DateTime.parse(row[3] as String),
      )).toList();
    } finally {
      await conn.close();
    }
  }

  // Разблокируем достижение для пользователя
  Future<bool> unlockAchievement({
    required int userId,
    required int achievementId,
  }) async {
    final conn = await _databaseService.getConnection();
    try {
      // Проверяем, не получено ли уже достижение
      final existing = await conn.query(
        'SELECT 1 FROM user_achievements WHERE user_id = @userId AND achievement_id = @achievementId',
        substitutionValues: {
          'userId': userId,
          'achievementId': achievementId,
        },
      );

      if (existing.isNotEmpty) return false;

      // Получаем информацию о достижении
      final achievement = (await getAllAchievements())
          .firstWhere((a) => a.id == achievementId);

      // Добавляем запись о получении достижения
      await conn.query(
        'INSERT INTO user_achievements (user_id, achievement_id) VALUES (@userId, @achievementId)',
        substitutionValues: {
          'userId': userId,
          'achievementId': achievementId,
        },
      );

      // Начисляем баллы
      await conn.query(
        'UPDATE users SET points = points + @points WHERE id = @userId',
        substitutionValues: {
          'userId': userId,
          'points': achievement.pointsReward,
        },
      );

      return true;
    } catch (e) {
      print('Error unlocking achievement: $e');
      return false;
    } finally {
      await conn.close();
    }
  }

  // Проверяем и разблокируем достижения автоматически
  Future<bool> checkAndUnlockAchievements(int userId) async {
    bool anyUnlocked = false;
    final conn = await _databaseService.getConnection();
    try {
      // Проверяем достижение "Хронозавр" (все вопросы в Машине времени отвечены правильно)
      final timeMachineComplete = await conn.query(
        '''SELECT COUNT(*) = 0 FROM time_machine_questions q
           WHERE NOT EXISTS (
             SELECT 1 FROM user_answers ua 
             WHERE ua.user_id = @userId AND ua.question_id = q.id AND ua.is_correct = true
           )''',
        substitutionValues: {'userId': userId},
      );

      if ((timeMachineComplete[0][0] as bool) == true) {
        anyUnlocked = await unlockAchievement(
          userId: userId,
          achievementId: 2, // ID "Хронозавр"
        ) || anyUnlocked;
      }

      // Проверяем достижение "Неопедия" (все образовательные элементы правильно отсортированы)
      final educationComplete = await conn.query(
        '''SELECT COUNT(*) = 0 FROM education_items ei
           WHERE NOT EXISTS (
             SELECT 1 FROM education_answers ea 
             WHERE ea.user_id = @userId AND ea.item_id = ei.id AND ea.is_correct = true
           )''',
        substitutionValues: {'userId': userId},
      );

      if ((educationComplete[0][0] as bool) == true) {
        anyUnlocked = await unlockAchievement(
          userId: userId,
          achievementId: 3, // ID "Неопедия"
        ) || anyUnlocked;
      }

      // Проверяем достижение "Аномалия" (все эпохи в Машине времени пройдены)
      final allErasComplete = await conn.query(
        '''SELECT COUNT(DISTINCT era) = (SELECT COUNT(DISTINCT era) FROM time_machine_questions)
           FROM user_answers ua
           JOIN time_machine_questions q ON ua.question_id = q.id
           WHERE ua.user_id = @userId AND ua.is_correct = true''',
        substitutionValues: {'userId': userId},
      );

      if ((allErasComplete[0][0] as bool) == true) {
        anyUnlocked = await unlockAchievement(
          userId: userId,
          achievementId: 4, // ID "Аномалия"
        ) || anyUnlocked;
      }

      return anyUnlocked;
    } finally {
      await conn.close();
    }
  }
}