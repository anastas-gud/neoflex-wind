import 'package:flutter/material.dart';
import 'package:neoflex_quest/core/models/user.dart';
import 'package:neoflex_quest/core/services/user_service.dart';
import 'package:neoflex_quest/features/achievements/presentation/screens/achievements_screen.dart';
import 'package:neoflex_quest/features/education/presentation/screens/education_screen.dart';
import 'package:neoflex_quest/features/shop/presentation/screens/shop_screen.dart';
import 'package:neoflex_quest/features/time_machine/presentation/screens/time_machine_screen.dart';
import 'package:neoflex_quest/features/tutorial/presentation/screens/tutorial_screen.dart';
import 'package:neoflex_quest/core/constants/colors.dart';
import 'package:neoflex_quest/shared/widgets/game_button_with_animation.dart';

class MainMenuScreen extends StatefulWidget {
  final int userId;

  const MainMenuScreen({required this.userId, Key? key}) : super(key: key);

  @override
  _MainMenuScreenState createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  late Future<User?> _userFuture;
  int _currentIndex = 0;
  final _userService = UserService();

  @override
  void initState() {
    super.initState();
    _userFuture = _loadUser();
  }

  Future<User?> _loadUser() async {
    return await _userService.getUserById(widget.userId);
  }

  Future<void> _refreshUser() async {
    setState(() {
      _userFuture = _loadUser();
    });
  }

  void _logout() async {
    _userService.logout();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
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
            elevation: 0,
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
            toolbarHeight: 100,
            backgroundColor: AppColors.lightLavender,
            title: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user.username,
                    style: TextStyle(
                      fontSize: 32,
                      color: AppColors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/tangerine.png',
                        width: 40,
                        errorBuilder: (_, __, ___) => Icon(Icons.attach_money),
                      ),
                      Text(
                        ' ${user.points}',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: AppColors.softOrange,
                        ),
                      ),
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
                    icon: Icon(Icons.help, size: 32, color: AppColors.darkBlue),
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
                    icon: Icon(
                      Icons.exit_to_app,
                      size: 32,
                      color: AppColors.darkBlue,
                    ),
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
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(
                    context,
                  ).copyWith(scrollbars: false),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 15.0, bottom: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ShaderMask(
                            blendMode: BlendMode.srcIn,
                            shaderCallback: (Rect bounds) {
                              return AppColors.orangeGradient.createShader(
                                bounds,
                              );
                            },
                            child: Text(
                              "NEOQUESTOPIA",
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -1.8,
                              ),
                            ),
                          ),
                          SizedBox(height: 30),
                          _buildGameButton(
                            'Машина времени'.toUpperCase(),
                            'assets/images/time_machine.png',
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => TimeMachineScreen(
                                      userId: user.id,
                                      onUpdate: _refreshUser,
                                    ),
                              ),
                            ),
                          ),
                          SizedBox(height: 60),
                          _buildGameButton(
                            'Образовательные миссии'.toUpperCase(),
                            'assets/images/education.png',
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => EducationScreen(
                                      userId: user.id,
                                      onUpdate: _refreshUser,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              ShopScreen(userId: user.id, onUpdate: _refreshUser),
              AchievementsScreen(userId: user.id),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            selectedItemColor: AppColors.blue,
            unselectedItemColor: AppColors.darkBlue,
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
