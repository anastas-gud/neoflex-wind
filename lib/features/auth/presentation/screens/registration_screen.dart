import 'dart:math';
import 'package:flutter/material.dart';
import 'package:neoflex_quest/core/constants/strings.dart';
import 'package:neoflex_quest/core/services/user_service.dart';
import 'package:neoflex_quest/shared/widgets/mascot_widget.dart';
import 'package:neoflex_quest/shared/widgets/secondary_button.dart';
import 'package:neoflex_quest/shared/widgets/text_field_widget.dart';
import 'package:neoflex_quest/features/tutorial/presentation/screens/tutorial_screen.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  final UserService _userService = UserService();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _userService.register(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
      );

      // Показываем сообщение об успешной регистрации
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Регистрация успешна! Рекомендация: пройдите обучение.',
          ),
        ),
      );
      // Показываем экран обучения перед переходом на главный экран
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TutorialScreen(isFirstTime: true),
        ),
      );

      // После завершения обучения переходим на главный экран
      Navigator.pushReplacementNamed(context, '/main', arguments: user?.id);
    } on Exception catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
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
    final RegExp _emailRegExp = RegExp(AppStrings.emailRegExp);
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
                  children: [
                    MascotWidget(
                      boxWidth: _boxWidth,
                      mascotSize: _boxWidth * 0.35,
                      title: 'Обнаружена попытка регистрации нового юнита...',
                      message: 'Введите параметры...',
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
                        if (value.length < 4) {
                          return 'Логин должен содержать минимум 4 символа';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    CustomTextFormField(
                      boxWidth: _boxWidth,
                      controller: _emailController,
                      labelText: 'Email',
                      prefixIcon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите email';
                        }
                        if (!_emailRegExp.hasMatch(value)) {
                          return 'Введите корректный email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
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
                    SizedBox(height: 16),
                    CustomTextFormField(
                      boxWidth: _boxWidth,
                      controller: _confirmPasswordController,
                      labelText: 'Подтверждение пароля',
                      prefixIcon: Icons.lock_outline,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Подтвердите пароль';
                        }
                        if (value != _passwordController.text) {
                          return 'Пароли не совпадают';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 30),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    SecondaryButtonWidget(
                      boxWidth: _boxWidth,
                      text: 'Создать аккаунт',
                      onPressed: _register,
                      child:
                          _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : null,
                    ),
                    SizedBox(height: 30),
                    Text("или"),
                    SizedBox(height: 30),
                    SecondaryButtonWidget(
                      boxWidth: _boxWidth,
                      text: 'Вернуться ко входу',
                      onPressed: () => Navigator.pop(context),
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
