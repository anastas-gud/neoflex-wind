import 'package:neoflex_quest/core/models/user.dart';
import 'package:neoflex_quest/core/database/database_service.dart';
import 'package:postgres/postgres.dart';

class AuthService {
  final DatabaseService _databaseService;

  AuthService({required DatabaseService databaseService})
      : _databaseService = databaseService;

  // Аутентификация пользователя
  Future<User?> authenticate(String username, String password) async {
    final conn = await _databaseService.getConnection();
    try {
      final results = await conn.query(
        'SELECT id, username, email, points FROM users WHERE username = @username AND password = @password',
        substitutionValues: {
          'username': username,
          'password': password,
        },
      );

      if (results.isNotEmpty) {
        final row = results[0];
        return User(
          id: row[0] is int ? row[0] as int : int.parse(row[0].toString()),
          username: row[1] as String,
          email: row[2]?.toString() ?? '',
          points: row[3] is int ? row[3] as int : int.parse(row[3].toString()),
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

    final conn = await _databaseService.getConnection();
    try {
      await conn.execute(
        '''
      INSERT INTO users (username, email, password)
      VALUES (@username, @email, @password)
      ''',
        substitutionValues: {
          'username': username,
          'email': email,
          'password': password, // Пароль сохраняется в открытом виде!
        },
      );
      return true;
    } on PostgreSQLException catch (e) {
      if (e.message!.contains('unique constraint')) {
        throw Exception('Пользователь с таким именем или email уже существует');
      }
      throw Exception('Ошибка регистрации: ${e.message}');
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