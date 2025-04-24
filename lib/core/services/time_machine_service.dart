import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:neoflex_quest/core/models/question.dart';
import 'package:neoflex_quest/core/models/test_attempt.dart';
import '../constants/strings.dart';

class TimeMachineService {
  Future<List<TestAttempt>> findUsersTestAttempts(int userId) async {
    final response = await http.get(
      Uri.parse('${AppStrings.baseUrl}/time_machine/test_attempts/$userId'),
    );
    List<dynamic> data = jsonDecode(response.body);
    return data.map((item) => TestAttempt.fromJson(item)).toList();
  }

  Future<List<Question>> findQuestionsByEra(String era) async {
    final response = await http.get(
      Uri.parse('${AppStrings.baseUrl}/time_machine/questions/$era'),
    );
    List<dynamic> data = jsonDecode(response.body);
    return data.map((item) => Question.fromJson(item)).toList();
  }

  Future<void> incrementAttempt(int userId, String era) async {
    await http.post(
      Uri.parse('${AppStrings.baseUrl}/time_machine/test_attempts/increment'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'era': era}),
    );
  }
}
