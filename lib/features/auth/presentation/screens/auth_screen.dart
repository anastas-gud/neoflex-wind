import 'dart:math';

import 'package:flutter/material.dart';
import 'package:neoflex_quest/core/constants/colors.dart';
import 'package:neoflex_quest/core/services/auth_service.dart';
import 'package:neoflex_quest/core/database/database_service.dart';
import 'package:neoflex_quest/features/auth/presentation/screens/registration_screen.dart';
import 'package:neoflex_quest/shared/widgets/mascot_widget.dart';
import 'package:neoflex_quest/shared/widgets/secondary_button.dart';
import 'package:neoflex_quest/shared/widgets/text_field_widget.dart';

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
      final user = await _authService.authenticate(
        _usernameController.text.trim(),
        _passwordController.text,
      );
      // final user = User(id: 1, username: "test", email: "test", points: 50);
      if (user != null) {
        //todo вернуть
        Navigator.pushNamed(context, '/main', arguments: user.id);
        // Navigator.pushNamed(context, '/main');
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
    double _boxWidth = min(MediaQuery.of(context).size.width * 0.75, 350);
    return Scaffold(
      body: Center(
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
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
                    CustomTextFormField(
                      boxWidth: _boxWidth,
                      controller: _usernameController,
                      labelText: 'Логин',
                      prefixIcon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите логин';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),
                    CustomTextFormField(
                      boxWidth: _boxWidth,
                      controller: _passwordController,
                      labelText: 'Пароль',
                      prefixIcon: Icons.lock,
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
                      backgroundColor: AppColors.orange,
                      borderColor: AppColors.orange,
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
                      backgroundColor: AppColors.white,
                      borderColor: AppColors.blue,
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
      ),
    );
  }
}
