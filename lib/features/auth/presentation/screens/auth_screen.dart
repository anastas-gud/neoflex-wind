import 'package:flutter/material.dart';
import 'package:neoflex_quest/core/services/auth_service.dart';
import 'package:neoflex_quest/core/database/database_service.dart';
import 'package:neoflex_quest/features/auth/presentation/screens/registration_screen.dart';
import 'package:neoflex_quest/features/auth/presentation/screens/registration_screen.dart';
import 'package:neoflex_quest/shared/widgets/mascot_widget.dart';

import '../../../../core/database/database_service.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  final AuthService _authService = AuthService(
    databaseService: DatabaseService(),
  );

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _authService.authenticate(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (user != null) {
        Navigator.pushReplacementNamed(context, '/main', arguments: user);
      } else {
        setState(() {
          _errorMessage = 'Неверное имя пользователя или пароль';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка входа: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 40),
                MascotWidget(
                  message: 'Обнаружен новый пользовательский профиль...\n'
                      'Сканирование... Загрузка данных...',
                ),
                SizedBox(height: 40),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Логин',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите логин';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Пароль',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите пароль';
                    }
                    if (value.length < 6) {
                      return 'Пароль должен содержать минимум 6 символов';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Войти'),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegistrationScreen()),
                    );
                  },
                  child: Text('Еще нет аккаунта? Зарегистрируйтесь'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}