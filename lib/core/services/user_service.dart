import 'package:http/http.dart' as http;
import 'package:neoflex_quest/core/constants/strings.dart';
import 'dart:convert';
import 'package:neoflex_quest/core/models/user.dart';

class UserService {
  // Вход в систему
  Future<User?> authenticate(String username, String password) async {
    final response = await http.post(
      Uri.parse('${AppStrings.baseUrl}/users/login'),
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  // Регистрация нового пользователя
  Future<User?> register({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (password != confirmPassword) {
      throw Exception('Пароли не совпадают');
    }
    if (!RegExp(r'^[\p{L}0-9@.+-]+$', unicode: true).hasMatch(username)) {
      throw Exception('Имя пользователя содержит недопустимые символы');
    }
    final response = await http.post(
      Uri.parse('${AppStrings.baseUrl}/users/register'),
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );
    if (response.statusCode == 201) {
      return User.fromJson(jsonDecode(response.body));
    }
    throw Exception('Юнит с такими данными уже существует');
  }

  // Выход из системы
  Future<void> logout() async {
    return;
  }

  // Получение пользователя по ID
  Future<User?> getUserById(int userId) async {
    final response = await http.get(
      Uri.parse('${AppStrings.baseUrl}/users/$userId'),
      headers: {'Accept-Charset': 'utf-8'},
    );
    if (response.statusCode == 200) {
      final String decodedBody = utf8.decode(response.bodyBytes);
      return User.fromJson(jsonDecode(decodedBody));
    }
    return null;
  }

  Future<void> updateUserPoints(int userId, int points) async {
    final response = await http.post(
      Uri.parse('${AppStrings.baseUrl}/users/updatePoints'),
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode({'userId': userId, 'points': points}),
    );
    if (response.statusCode != 200) {
      throw Exception('Не удалось изменить кол-во мандаринок');
    }
  }
}
