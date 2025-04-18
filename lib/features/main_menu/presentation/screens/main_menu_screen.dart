import 'package:flutter/material.dart';
import 'package:neoflex_quest/core/models/user.dart';
import 'package:neoflex_quest/core/services/auth_service.dart';

import '../../../../core/database/database_service.dart';
import '../../../../shared/widgets/mascot_widget.dart';
import '../../../achievements/presentation/screens/achievements_screen.dart';
import '../../../education/presentation/screens/education_screen.dart';
import '../../../shop/presentation/screens/shop_screen.dart';
import '../../../time_machine/presentation/screens/time_machine_screen.dart';
import '../../../tutorial/presentation/screens/tutorial_screen.dart';

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
          return Scaffold(body: Center(child: Text('Ошибка загрузки пользователя')));
        }

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Text(user.username),
                SizedBox(width: 8),
                Image.asset('assets/images/mandarin.png', width: 24),
                Text(' ${user.points}'),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.help),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TutorialScreen(isFirstTime: false),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.exit_to_app),
                onPressed: _logout,
              ),
            ],
          ),
          body: IndexedStack(
            index: _currentIndex,
            children: [
              // Главный экран
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MascotWidget(
                      message: 'Приветствую, ${user.username}!\n'
                          'Выбери один из игровых блоков для продолжения.',
                    ),
                    SizedBox(height: 40),
                    _buildGameButton(
                      'Машина времени',
                      'assets/images/time_machine.png',
                          () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TimeMachineScreen(userId: user.id),
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                    _buildGameButton(
                      'Образовательные миссии',
                      'assets/images/education.png',
                          () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EducationScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Магазин
              ShopScreen(userId: user.id),
              // Достижения
              AchievementsScreen(userId: user.id),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Главная',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shop),
                label: 'Магазин',
              ),
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
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Image.asset(
            imagePath,
            width: 150,
            errorBuilder: (_, __, ___) => Icon(Icons.question_mark, size: 100),
          ),
          SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}