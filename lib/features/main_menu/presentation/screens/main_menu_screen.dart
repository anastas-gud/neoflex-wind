import 'package:flutter/material.dart';
import 'package:neoflex_quest/core/models/user.dart';
import 'package:neoflex_quest/core/services/auth_service.dart';
import 'package:neoflex_quest/core/database/database_service.dart';
import 'package:neoflex_quest/shared/widgets/mascot_widget.dart';
import 'package:neoflex_quest/features/achievements/presentation/screens/achievements_screen.dart';
import 'package:neoflex_quest/features/education/presentation/screens/education_screen.dart';
import 'package:neoflex_quest/features/shop/presentation/screens/shop_screen.dart';
import 'package:neoflex_quest/features/time_machine/presentation/screens/time_machine_screen.dart';
import 'package:neoflex_quest/features/tutorial/presentation/screens/tutorial_screen.dart';

import '../../../../core/constants/colors.dart';
import '../../../../shared/widgets/game_button_with_animation.dart';

class MainMenuScreen extends StatefulWidget {
  final int userId;

  const MainMenuScreen({required this.userId, Key? key}) : super(key: key);

  @override
  _MainMenuScreenState createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  late Future<User?> _userFuture;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _userFuture = _loadUser();
  }

  Future<User?> _loadUser() async {
    final authService = AuthService(databaseService: DatabaseService());
    return await authService.getUserById(widget.userId);
  }

  Future<void> _refreshUser() async {
    setState(() {
      _userFuture = _loadUser();
    });
  }

  void _logout() async {
    final authService = AuthService(databaseService: DatabaseService());
    await authService.logout();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final user = snapshot.data;
        if (user == null) {
          return Scaffold(
            body: Center(child: Text('Ошибка загрузки пользователя')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            toolbarHeight: 90,
            backgroundColor: AppColors.softLavender,
            title: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(user.username, style: TextStyle(fontSize: 25)),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Image.asset('assets/images/tangerine.png', width: 40),
                      Text(' ${user.points}', style: TextStyle(fontSize: 23)),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.only(right: 0),
                  child: IconButton(
                    icon: Icon(Icons.help, size: 32),
                    onPressed:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => TutorialScreen(isFirstTime: false),
                          ),
                        ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: IconButton(
                    icon: Icon(Icons.exit_to_app, size: 32),
                    onPressed: _logout,
                  ),
                ),
              ),
            ],
          ),
          body: IndexedStack(
            index: _currentIndex,
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (Rect bounds) {
                        return AppColors.orangeGradient.createShader(bounds);
                      },
                      child: Text(
                        "NEOQUESTOPIA",
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    _buildGameButton(
                      'Машина времени',
                      'assets/images/time_machine.png',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TimeMachineScreen(
                            userId: user.id,
                            onUpdate: _refreshUser,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 60),
                    _buildGameButton(
                      'Образовательные миссии',
                      'assets/images/education.png',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EducationScreen(
                            userId: user.id,
                            onUpdate: _refreshUser,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ShopScreen(userId: user.id, onUpdate: _refreshUser),
              AchievementsScreen(userId: user.id),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главная'),
              BottomNavigationBarItem(icon: Icon(Icons.shop), label: 'Магазин'),
              BottomNavigationBarItem(
                icon: Icon(Icons.star),
                label: 'Достижения',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGameButton(String title, String imagePath, VoidCallback onTap) {
    return GameButtonWithAnimation(
      title: title,
      imagePath: imagePath,
      onTap: onTap,
    );
  }
}