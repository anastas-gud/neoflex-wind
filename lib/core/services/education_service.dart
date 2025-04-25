import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:neoflex_quest/core/constants/strings.dart';
import 'package:neoflex_quest/core/models/education_attempt.dart';
import 'package:neoflex_quest/core/models/education_item.dart';
import 'package:neoflex_quest/core/services/user_service.dart';

class EducationService {
  UserService _userService = UserService();

  Future<List<EducationItem>> getEducationItems() async {
    final response = await http.get(
      Uri.parse('${AppStrings.baseUrl}/education/items'),
      headers: {'Accept-Charset': 'utf-8'},
    );
    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      final List<dynamic> data = jsonDecode(responseBody);
      return data.map((item) => EducationItem.fromJson(item)).toList();
    } else {
      throw Exception('Ошибка загрузки блока');
    }
  }

  Future<List<EducationAttempt>> getUserEducationAttempts(int userId) async {
    final response = await http.get(
      Uri.parse('${AppStrings.baseUrl}/education/attempts/$userId'),
      headers: {'Accept-Charset': 'utf-8'},
    );
    final String decodedBody = utf8.decode(response.bodyBytes);
    List<dynamic> data = jsonDecode(decodedBody);
    return data.map((item) => EducationAttempt.fromJson(item)).toList();
  }

  Future<void> incrementAttempts(int userId) async {
    final response = await http.post(
      Uri.parse('${AppStrings.baseUrl}/education/attempts/increment/$userId'),
      headers: {'Content-Type': 'application/json; charset=utf-8'},
    );
    if (response.statusCode != 200) {
      throw Exception('Не удалось зафиксировать попытку');
    }
  }

  Future<void> saveUserAnswers({
    required int userId,
    required List<EducationItem> topContainer,
    required List<EducationItem> bottomContainer,
  }) async {
    final answers = [
      ...topContainer.map((item) => _mapAnswer(userId, item, 'children')),
      ...bottomContainer.map((item) => _mapAnswer(userId, item, 'adults')),
    ];

    for (var answer in answers){
      final response = await http.post(
        Uri.parse('${AppStrings.baseUrl}/education/answers/'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode({
          'userId': userId,
          'itemId': answer['itemId'],
          'selectedCategory': answer['selectedCategory'],
          'isCorrect': answer['isCorrect'],
        }),
      );
      if (response.statusCode != 201) {
        throw Exception('Не удалось зафиксировать ответ');
      }
    }

    final correctAnswers =
        topContainer.where((i) => i.correctCategory == 'children').length +
        bottomContainer.where((i) => i.correctCategory == 'adults').length;
    final pointsEarned = correctAnswers * 2;
    _userService.updateUserPoints(userId, pointsEarned);
  }

  Map<String, dynamic> _mapAnswer(
    int userId,
    EducationItem item,
    String category,
  ) {
    return {
      'userId': userId,
      'itemId': item.id,
      'selectedCategory': category,
      'isCorrect': item.correctCategory == category,
    };
  }
}
