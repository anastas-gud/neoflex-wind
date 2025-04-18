import 'package:neoflex_quest/core/models/user.dart';
import 'package:neoflex_quest/core/database/database_service.dart';

class AuthService {
  final DatabaseService _databaseService;

  AuthService({required DatabaseService databaseService})
      : _databaseService = databaseService;

  // Аутентификация пользователя
  Future<User?> authenticate(String username, String password) async {
    final conn = await _databaseService.getConnection();
    try {
      final results = await conn.query(
        'SELECT id, username, email, points FROM users WHERE username = @username AND password = crypt(@password, password)',
        substitutionValues: {
          'username': username,
          'password': password,
        },
      );

      if (results.isNotEmpty) {
        return User(
          id: results[0][0] as int,
          username: results[0][1] as String,
          email: results[0][2] as String,
          points: results[0][3] as int,
        );
      }
      return null;
    } finally {
      await conn.close();
    }
  }

  // Регистрация нового пользователя
  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (password != confirmPassword) {
      throw Exception('Пароли не совпадают');
    }

    if (password.length < 6) {
      throw Exception('Пароль должен содержать минимум 6 символов');
    }

    final conn = await _databaseService.getConnection();
    try {
      await conn.query(
        'INSERT INTO users (username, email, password) VALUES (@username, @email, crypt(@password, gen_salt(\'bf\')))',
        substitutionValues: {
          'username': username,
          'email': email,
          'password': password,
        },
      );
      return true;
    } catch (e) {
      if (e.toString().contains('unique constraint')) {
        throw Exception('Пользователь с таким именем или email уже существует');
      }
      throw Exception('Ошибка регистрации: $e');
    } finally {
      await conn.close();
    }
  }

  // Выход из системы
  Future<void> logout() async {
    // В этом случае просто очищаем состояние, так как нет токенов
    return;
  }

  // Проверка существования пользователя
  Future<bool> userExists(String username) async {
    final conn = await _databaseService.getConnection();
    try {
      final results = await conn.query(
        'SELECT 1 FROM users WHERE username = @username',
        substitutionValues: {'username': username},
      );
      return results.isNotEmpty;
    } finally {
      await conn.close();
    }
  }

  // Получение пользователя по ID
  Future<User?> getUserById(int userId) async {
    final conn = await _databaseService.getConnection();
    try {
      final results = await conn.query(
        'SELECT id, username, email, points FROM users WHERE id = @userId',
        substitutionValues: {'userId': userId},
      );

      if (results.isNotEmpty) {
        return User(
          id: results[0][0] as int,
          username: results[0][1] as String,
          email: results[0][2] as String,
          points: results[0][3] as int,
        );
      }
      return null;
    } finally {
      await conn.close();
    }
  }
}