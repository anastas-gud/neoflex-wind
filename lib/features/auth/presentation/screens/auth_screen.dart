import 'dart:math';
import 'package:flutter/material.dart';
import 'package:neoflex_quest/core/constants/colors.dart';
import 'package:neoflex_quest/core/constants/strings.dart';
import 'package:neoflex_quest/core/services/user_service.dart';
import 'package:neoflex_quest/features/auth/presentation/screens/registration_screen.dart';
import 'package:neoflex_quest/features/tutorial/presentation/widgets/tutorial_mascot_widget.dart';
import 'package:neoflex_quest/shared/widgets/mascot_widget.dart';
import 'package:neoflex_quest/shared/widgets/primary_button.dart';
import 'package:neoflex_quest/shared/widgets/secondary_button.dart';
import 'package:neoflex_quest/shared/widgets/text_field_widget.dart';

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

  final UserService _userService = UserService();

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
      final user = await _userService.authenticate(
        _usernameController.text.trim(),
        _passwordController.text,
      );
      if (user != null) {
        Navigator.pushNamed(context, '/main', arguments: user.id);
      } else {
        setState(() {
          _errorMessage = 'Неверный логин или пароль';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка входа';
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
                          return 'Пароль содержит мин 6 символов';
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
                    PrimaryButtonWidget(
                      boxWidth: _boxWidth,
                      text: "Войти",
                      onPressed: _isLoading ? null : _login,
                      child:
                          _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : null,
                    ),
                    SizedBox(height: 30),
                    Text(
                      "Еще нет аккаунта?",
                      style: TextStyle(
                        color: AppColors.darkPurple,
                        fontSize: 15,
                      ),
                    ),
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
      ),
    );
  }
}
