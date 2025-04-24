import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:neoflex_quest/core/models/question.dart';
import 'package:neoflex_quest/core/models/test_attempt.dart';
import 'package:neoflex_quest/core/constants/strings.dart';

class TimeMachineService {
  Future<List<TestAttempt>> findUsersTestAttempts(int userId) async {
    final response = await http.get(
      Uri.parse('${AppStrings.baseUrl}/time_machine/test_attempts/$userId'),
      headers: {'Accept-Charset': 'utf-8'},
    );
    final String decodedBody = utf8.decode(response.bodyBytes);
    List<dynamic> data = jsonDecode(decodedBody);
    return data.map((item) => TestAttempt.fromJson(item)).toList();
  }

  Future<List<Question>> findQuestionsByEra(String era) async {
    final response = await http.get(
      Uri.parse('${AppStrings.baseUrl}/time_machine/questions/$era'),
      headers: {'Accept-Charset': 'utf-8'},
    );
    final String decodedBody = utf8.decode(response.bodyBytes);
    List<dynamic> data = jsonDecode(decodedBody);
    return data.map((item) => Question.fromJson(item)).toList();
  }

  Future<void> incrementAttempt(int userId, String era) async {
    final response = await http.post(
      Uri.parse('${AppStrings.baseUrl}/time_machine/test_attempts/increment/'),
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode({'userId': userId, 'era': era}),
    );
    if (response.statusCode != 200) {
      throw Exception('Не удалось зафиксировать попытку');
    }
  }

  Future<void> submitAnswer(
    int userId,
    int questionId,
    String answer,
    bool isCorrect,
  ) async {
    final response = await http.post(
      Uri.parse('${AppStrings.baseUrl}/time_machine/user_answers/'),
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode({
        'userId': userId,
        'questionId': questionId,
        'answer': answer,
        'isCorrect': isCorrect,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Не удалось зафиксировать ответ');
    }
  }
}
