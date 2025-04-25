import 'dart:math';

import 'package:flutter/material.dart';
import 'package:neoflex_quest/core/constants/colors.dart';
import 'package:neoflex_quest/core/constants/strings.dart';
import 'package:neoflex_quest/shared/widgets/mascot_widget.dart';
import 'package:neoflex_quest/core/services/education_service.dart';
import 'package:neoflex_quest/shared/widgets/small_mascot_widget.dart';
import 'education_game_screen.dart';

class EducationScreen extends StatefulWidget {
  final int userId;
  final VoidCallback onUpdate;

  const EducationScreen({
    required this.userId,
    required this.onUpdate,
    Key? key,
  }) : super(key: key);

  @override
  _EducationScreenState createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  int _attemptsLeft = 3;
  bool _loadingAttempts = true;

  final EducationService _educationService = EducationService();

  @override
  void initState() {
    super.initState();
    _loadAttempts();
  }

  Future<void> _loadAttempts() async {
    final attemptsData = await _educationService.getUserEducationAttempts(
      widget.userId,
    );
    setState(() {
      _attemptsLeft = attemptsData.isNotEmpty ? 3 - attemptsData.length : 3;
      _loadingAttempts = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double _boxWidth = min(MediaQuery.of(context).size.width * 0.85, 400);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Образовательные миссии'.toUpperCase(),
          style: const TextStyle(
            fontSize: 25,
            color: AppColors.pink,
            fontWeight: FontWeight.bold,
            letterSpacing: -1.8,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.pink, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          _loadingAttempts
              ? Center(child: CircularProgressIndicator())
              : Center(
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(
                    context,
                  ).copyWith(scrollbars: false),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SmallMascotWidget(
                          message: AppStrings.educationDescription,
                          imagePath: 'assets/images/education_screen.png',
                          boxWidth: _boxWidth,
                          shift: 125,
                        ),
                        SizedBox(height: 20),
                        ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (Rect bounds) {
                            return AppColors.orangeGradient.createShader(
                              bounds,
                            );
                          },
                          child: Text(
                            'Осталось попыток: $_attemptsLeft'.toUpperCase(),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        if (_attemptsLeft > 0)
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => EducationGameScreen(
                                        userId: widget.userId,
                                        onUpdate: () {
                                          widget.onUpdate();
                                          _loadAttempts();
                                        },
                                      ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.pink,
                              side: BorderSide(color: AppColors.pink, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 15,
                              ),
                            ),
                            child: Text(
                              'Начать задание',
                              style: TextStyle(
                                fontSize: 20,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        if (_attemptsLeft <= 0)
                          Text(
                            'Вы использовали все доступные попытки',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppColors.deepPinkPurple,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        SizedBox(height: 25),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }
}
