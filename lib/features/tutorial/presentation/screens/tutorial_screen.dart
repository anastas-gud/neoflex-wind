import 'package:flutter/material.dart';
import 'package:neoflex_quest/core/constants/colors.dart';
import 'package:neoflex_quest/features/tutorial/presentation/widgets/tutorial_button.dart';
import 'package:neoflex_quest/features/tutorial/presentation/widgets/tutorial_mascot_widget.dart';
import 'package:neoflex_quest/shared/widgets/primary_button.dart';
import 'package:neoflex_quest/shared/widgets/secondary_button.dart';

class TutorialScreen extends StatefulWidget {
  final bool isFirstTime;

  const TutorialScreen({required this.isFirstTime, Key? key}) : super(key: key);

  @override
  _TutorialScreenState createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  int _currentPage = 0;
  final List<String> _tutorialPages = [
    'Обнаружен новый пользовательский профиль...\nСканирование... Загрузка данных...',
    'Приветствую, юнит!\nЯ – ваш гид Неончик.\nАктивировать инструктаж "Как тут все устроено"?',
    'Краткий брифинг: есть два игровых блока – Машина времени и Образовательные миссии, '
        'в каждом из них тематический квест, за прохождение которого начисляются '
        'ресурсные единицы (кодовое название: "Мандаринки").',
    'Для чего нужны Мандаринки?\nВ блоке Торговая точка доступен обмен ресурсов на '
        'материальные артефакты Neoflex.\nСтоимость приза зависит от его ценности, '
        'запасы ограничены, приоритет – быстрейшему юниту!',
    'Рекомендация: при возникновении чувства тревоги из-за недостатка ресурсных '
        'единиц для получения желаемых артефактов загляните в блок Галактика достижений.\n'
        'За выполнение миссий блока назначена награда.',
    'Ориентационный протокол завершён… Приступим к игре!',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TutorialMascotWidget(
                  key: ValueKey(_currentPage),
                  message: _tutorialPages[_currentPage],
                  buttons:
                      _currentPage == 1 && widget.isFirstTime
                          ? Column(
                            children: [
                              TutorialButton(
                                onPressed: () => setState(() => _currentPage++),
                                text: 'ДА',
                              ),
                              SizedBox(height: 20),
                              TutorialButton(
                                borderColor: AppColors.darkBlue,
                                textColor: AppColors.darkBlue,
                                onPressed: () => Navigator.pop(context),
                                text: 'НЕТ',
                              ),
                            ],
                          )
                          : TutorialButton(
                            onPressed:
                                () =>
                                    _currentPage < _tutorialPages.length - 1
                                        ? setState(() => _currentPage++)
                                        : Navigator.pop(context),
                            text:
                                _currentPage < _tutorialPages.length - 1
                                    ? 'Далее'.toUpperCase()
                                    : 'Понятно!'.toUpperCase(),
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
