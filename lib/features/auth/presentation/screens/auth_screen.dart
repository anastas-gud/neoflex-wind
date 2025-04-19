import 'dart:math';

import 'package:flutter/material.dart';
import 'package:neoflex_quest/core/services/auth_service.dart';
import 'package:neoflex_quest/core/database/database_service.dart';
import 'package:neoflex_quest/features/auth/presentation/screens/registration_screen.dart';
import 'package:neoflex_quest/shared/widgets/mascot_widget.dart';
import 'package:neoflex_quest/shared/widgets/secondary_button.dart';

import '../../../../core/models/user.dart';

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
      //todo раскомментить и удалить тестового пользователя
      // final user = await _authService.authenticate(
      //   _usernameController.text.trim(),
      //   _passwordController.text,
      // );
      final user = User(id: 1, username: "test", email: "test", points: 50);
      if (user != null) {
        Navigator.pushNamed(context, '/main', arguments: user.id);
      } else {
        setState(() {
          _errorMessage = 'Неверный логин или пароль';
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
    double _boxWidth = min(MediaQuery.of(context).size.width * 0.75, 400);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MascotWidget(
                    boxWidth: _boxWidth,
                    mascotSize: _boxWidth * 0.35,
                    title: "Бип-бип!",
                    message:
                        'Для прохождения квеста введите свой логин и пароль...',
                  ),
                  SizedBox(height: 30),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: _boxWidth),
                    child: TextFormField(
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
                  ),
                  SizedBox(height: 15),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: _boxWidth),
                    child: TextFormField(
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
                  ),
                  SizedBox(height: 30),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  SecondaryButtonWidget(
                    boxWidth: _boxWidth,
                    text: "Войти",
                    onPressed: _isLoading ? null : _login,
                    child:
                        _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : null,
                  ),
                  SizedBox(height: 30),
                  Text("Еще нет аккаунта?"),
                  SizedBox(height: 30),
                  SecondaryButtonWidget(
                    boxWidth: _boxWidth,
                    text: "Создать аккаунт",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegistrationScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
