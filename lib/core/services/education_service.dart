import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/strings.dart';
import '../models/education_item.dart';

class EducationService{
  Future<Map<String, int>> getEducationAttempts(int userId) async {
    final response = await http.get(
      Uri.parse('${AppStrings.baseUrl}/education/attempts/$userId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return {
        'attemptsUsed': data['attemptsUsed'] as int,
        'maxAttempts': data['maxAttempts'] as int,
      };
    } else if (response.statusCode == 404) {
      return{
        'attemptsUsed': 0,
        'maxAttempts': 3,
      };
    } else {
      throw Exception('Failed to load education attempts');
    }
  }

  Future<List<EducationItem>> getEducationItems() async {
    final response = await http.get(
      Uri.parse('${AppStrings.baseUrl}/education/items'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      final List<dynamic> data = jsonDecode(responseBody);
      return data.map((item) => EducationItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load education items');
    }
  }
  //todo
  Future<void> incrementAttempts(int userId) async {
    final response = await http.post(
      Uri.parse('${AppStrings.baseUrl}/education/attempts/increment'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to increment attempts');
    }
  }
  final http.Client _client;

  EducationService({http.Client? client}) : _client = client ?? http.Client();

  Future<void> saveUserAnswers({
    required int userId,
    required List<EducationItem> topContainer,
    required List<EducationItem> bottomContainer,
  }) async {
    final answers = [
      ...topContainer.map((item) => _mapAnswer(userId, item, 'children')),
      ...bottomContainer.map((item) => _mapAnswer(userId, item, 'adults')),
    ];

    final correctAnswers = topContainer.where((i) => i.correctCategory == 'children').length +
        bottomContainer.where((i) => i.correctCategory == 'adults').length;
    final pointsEarned = correctAnswers * 2;

    final response = await _client.post(
      Uri.parse('${AppStrings.baseUrl}/education/answers'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'answers': answers,
        'pointsEarned': pointsEarned,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to save answers: ${response.body}');
    }
  }

  Map<String, dynamic> _mapAnswer(int userId, EducationItem item, String category) {
    return {
      'userId': userId,
      'itemId': item.id,
      'selectedCategory': category,
      'isCorrect': item.correctCategory == category,
    };
  }
}
