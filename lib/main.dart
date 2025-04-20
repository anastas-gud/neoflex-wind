import 'package:flutter/material.dart';

import 'core/database/database_service.dart';
import 'features/auth/presentation/screens/auth_screen.dart';
import 'features/main_menu/presentation/screens/main_menu_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация базы данных
  final dbService = DatabaseService();
  await dbService.initDatabase();
  await dbService.initializeTimeMachineQuestions();

  runApp(
    MaterialApp(
      title: 'NeoQuestopia',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AuthScreen(),
      routes: {
        '/main': (context) => MainMenuScreen(
          userId: ModalRoute.of(context)!.settings.arguments as int,
        ),
      },
      debugShowCheckedModeBanner: false,
    ),
  );
}