import 'package:flutter/material.dart';
import 'core/services/data_service.dart';
import 'features/auth/presentation/screens/auth_screen.dart';
import 'features/error/presentation/screens/error_screen.dart';
import 'features/main_menu/presentation/screens/main_menu_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbService = DataService();
  final result = await dbService.initializeData();

  runApp(
    MaterialApp(
      title: 'NeoQuestopia',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: result ? AuthScreen() : ErrorScreen(),
      routes: {
        '/main':
            (context) => MainMenuScreen(
              userId: ModalRoute.of(context)!.settings.arguments as int,
            ),
        '/error': (context) => ErrorScreen(),
      },
      debugShowCheckedModeBanner: false,
    ),
  );
}
