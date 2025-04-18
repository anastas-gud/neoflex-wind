import 'package:flutter/material.dart';

import '../../../../shared/widgets/mascot_widget.dart';

class TutorialScreen extends StatefulWidget {
  final bool isFirstTime;

  const TutorialScreen({required this.isFirstTime, Key? key}) : super(key: key);

  @override
  _TutorialScreenState createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  int _currentPage = 0;
  final List<String> _tutorialPages = [
    'Обнаружен новый пользовательский профиль... Сканирование... Загрузка данных...',
    'Приветствую, юнит! Я – ваш гид Неончик. Активировать инструктаж "Как тут все устроено"?',
    'Краткий брифинг: есть два игровых блока – Машина времени и Образовательные миссии, '
        'в каждом из них тематический квест, за прохождение которого начисляются '
        'ресурсные единицы (кодовое название: "Мандаринки").',
    'Для чего нужны Мандаринки? В блоке Торговая точка доступен обмен ресурсов на '
        'материальные артефакты Neoflex. Стоимость приза зависит от его ценности, '
        'запасы ограничены, приоритет – быстрейшему юниту!',
    'Рекомендация: при возникновении чувства тревоги из-за недостатка ресурсных '
        'единиц для получения желаемых артефактов загляните в блок Галактика достижений. '
        'За выполнение миссий блока назначена награда.',
    'Ориентационный протокол завершён… Приступим к игре!',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MascotWidget(
              message: _tutorialPages[_currentPage],
              mascotSize: 120,
            ),
            SizedBox(height: 20),

            if (_currentPage == 1 && widget.isFirstTime)
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () => setState(() => _currentPage++),
                    child: Text('Да'),
                  ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Режим самостоятельного изучения активирован')),
                      );
                    },
                    child: Text('Нет'),
                  ),
                ],
              )
            else if (_currentPage < _tutorialPages.length - 1)
              ElevatedButton(
                onPressed: () => setState(() => _currentPage++),
                child: Text('Далее'),
              )
            else
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Понятно'),
              ),
          ],
        ),
      ),
    );
  }
}