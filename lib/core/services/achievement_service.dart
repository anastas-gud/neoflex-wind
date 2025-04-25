import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:neoflex_quest/core/models/achievement.dart';
import 'package:neoflex_quest/core/models/user_achievement.dart';
import 'package:neoflex_quest/core/services/data_service.dart';
import 'package:neoflex_quest/core/services/user_service.dart';

import '../constants/strings.dart';
import '../database/database_service.dart';

class AchievementService {
  final http.Client _client;
  final UserService _userService;

  AchievementService({http.Client? client, required UserService userService})
      : _client = client ?? http.Client(),
        _userService = userService;

  // Получаем все возможные достижения
  Future<List<Achievement>> getAchievements() async {
    final response = await http.get(
      Uri.parse('${AppStrings.baseUrl}/achievement'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      final List<dynamic> data = jsonDecode(responseBody);
      return data.map((item) => Achievement.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load achievements: ${response.statusCode}');
    }
  }

  // Получаем достижения конкретного пользователя
  Future<List<UserAchievement>> getUserAchievements(int userId) async {
    final response = await _client.get(
      Uri.parse('${AppStrings.baseUrl}/achievement/user/$userId'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => UserAchievement(
        id: item['id'] as int,
        userId: item['userId'] as int,
        achievementId: item['achievementId'] as int,
        earnedAt: DateTime.parse(item['earnedAt'] as String),
      )).toList();
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to load user achievements');
    }
  }

  Future<bool> hasAchievement(int userId, int achievementId) async {
    final response = await _client.get(
      Uri.parse('${AppStrings.baseUrl}/achievement/has?userId=$userId&achievementId=$achievementId'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['hasAchievement'] as bool;
    }
    throw Exception('Failed to check achievement');
  }

  Future<bool> unlockAchievement(int userId, int achievementId) async {
    final response = await _client.post(
      Uri.parse('${AppStrings.baseUrl}/achievement/unlock'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'achievementId': achievementId,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final points = data['pointsReward'] as int;

      // Начисляем мандаринки через UserService
      await _userService.updateUserPoints(userId, points);

      return true;
    }
    throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to unlock achievement');
  }

  // Разблокируем достижение для пользователя
  // Future<bool> unlockAchievement({
  //   required int userId,
  //   required int achievementId,
  // }) async {
  //   final conn = await _databaseService.getConnection();
  //   try {
  //     // Проверяем, не получено ли уже достижение
  //     final existing = await conn.query(
  //       'SELECT 1 FROM user_achievements WHERE user_id = @userId AND achievement_id = @achievementId',
  //       substitutionValues: {
  //         'userId': userId,
  //         'achievementId': achievementId,
  //       },
  //     );
  //
  //     if (existing.isNotEmpty) return false;
  //
  //     // Получаем информацию о достижении
  //     final achievement = (await getAllAchievements())
  //         .firstWhere((a) => a.id == achievementId);
  //
  //     // Добавляем запись о получении достижения
  //     await conn.query(
  //       'INSERT INTO user_achievements (user_id, achievement_id) VALUES (@userId, @achievementId)',
  //       substitutionValues: {
  //         'userId': userId,
  //         'achievementId': achievementId,
  //       },
  //     );
  //
  //     // Начисляем баллы
  //     await conn.query(
  //       'UPDATE users SET points = points + @points WHERE id = @userId',
  //       substitutionValues: {
  //         'userId': userId,
  //         'points': achievement.pointsReward,
  //       },
  //     );
  //
  //     return true;
  //   } catch (e) {
  //     print('Error unlocking achievement: $e');
  //     return false;
  //   } finally {
  //     await conn.close();
  //   }
  // }

  // Проверяем и разблокируем достижения автоматически
  // Future<bool> checkAndUnlockAchievements(int userId) async {
  //   bool anyUnlocked = false;
  //   final conn = await _databaseService.getConnection();
  //   try {
  //     // Проверяем достижение "Хронозавр" (все вопросы в Машине времени отвечены правильно)
  //     final timeMachineComplete = await conn.query(
  //       '''SELECT COUNT(*) = 0 FROM time_machine_questions q
  //          WHERE NOT EXISTS (
  //            SELECT 1 FROM user_answers ua
  //            WHERE ua.user_id = @userId AND ua.question_id = q.id AND ua.is_correct = true
  //          )''',
  //       substitutionValues: {'userId': userId},
  //     );
  //
  //     if ((timeMachineComplete[0][0] as bool) == true) {
  //       anyUnlocked = await unlockAchievement(
  //         userId: userId,
  //         achievementId: 2, // ID "Хронозавр"
  //       ) || anyUnlocked;
  //     }
  //
  //     // Проверяем достижение "Неопедия" (все образовательные элементы правильно отсортированы)
  //     final educationComplete = await conn.query(
  //       '''SELECT COUNT(*) = 0 FROM education_items ei
  //          WHERE NOT EXISTS (
  //            SELECT 1 FROM education_answers ea
  //            WHERE ea.user_id = @userId AND ea.item_id = ei.id AND ea.is_correct = true
  //          )''',
  //       substitutionValues: {'userId': userId},
  //     );
  //
  //     if ((educationComplete[0][0] as bool) == true) {
  //       anyUnlocked = await unlockAchievement(
  //         userId: userId,
  //         achievementId: 3, // ID "Неопедия"
  //       ) || anyUnlocked;
  //     }
  //
  //     // Проверяем достижение "Аномалия" (все эпохи в Машине времени пройдены)
  //     final allErasComplete = await conn.query(
  //       '''SELECT COUNT(DISTINCT era) = (SELECT COUNT(DISTINCT era) FROM time_machine_questions)
  //          FROM user_answers ua
  //          JOIN time_machine_questions q ON ua.question_id = q.id
  //          WHERE ua.user_id = @userId AND ua.is_correct = true''',
  //       substitutionValues: {'userId': userId},
  //     );
  //
  //     if ((allErasComplete[0][0] as bool) == true) {
  //       anyUnlocked = await unlockAchievement(
  //         userId: userId,
  //         achievementId: 4, // ID "Аномалия"
  //       ) || anyUnlocked;
  //     }
  //
  //     return anyUnlocked;
  //   } finally {
  //     await conn.close();
  //   }
  // }
}