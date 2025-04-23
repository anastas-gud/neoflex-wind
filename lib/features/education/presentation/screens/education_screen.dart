import 'package:flutter/material.dart';
import 'package:neoflex_quest/shared/widgets/mascot_widget.dart';
import 'education_game_screen.dart';
import 'package:neoflex_quest/core/database/database_service.dart';

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

  @override
  void initState() {
    super.initState();
    _loadAttempts();
  }

  Future<void> _loadAttempts() async {
    final connection = await DatabaseService().getConnection();
    try {
      final results = await connection.query(
        'SELECT attempts_used, max_attempts FROM education_attempts WHERE user_id = @userId',
        substitutionValues: {'userId': widget.userId},
      );

      setState(() {
        if (results.isNotEmpty) {
          final attemptsUsed = results[0][0] as int;
          final maxAttempts = results[0][1] as int;
          _attemptsLeft = maxAttempts - attemptsUsed;
        }
        _loadingAttempts = false;
      });
    } finally {
      await connection.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Образовательные миссии'),
        centerTitle: true,
      ),
      body: _loadingAttempts
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            MascotWidget(
              message: 'Инициализация модуля знаний... Обнаружено 2 направления: '
                  '[Офицерский состав] и [Молодые рекруты]...\n\n'
                  'Здравствуй, юнит! Добро пожаловать в блок "Образовательные миссии". '
                  'Компания Neoflex не только разрабатывает цифровые решения, но и проводит '
                  'различные просветительские программы. Давай познакомимся с ними ближе.\n\n'
                  'Предупреждение! Системное уведомление: Обнаружена ошибка категоризации…\n\n'
                  'Перед тобой – образовательные модули Neoflex. Но произошел... небольшой '
                  'системный сбой. База данных подверглась несанкционированному перемешиванию. '
                  'Все курсы были экстренно помещены в карантинную зону, твоя задача – '
                  'проанализировать описания и отсортировать модули по контейнерам. Помоги '
                  'восстановить порядок в академической вселенной.\n\n'
                  'Рекомендация: для успешного прохождения испытания необходимо перенести модули '
                  'в соответствующий им контейнер: синий сектор для программ, созданных для '
                  'студентов и молодых специалистов, зеленый – инициативы для детей.\n\n'
                  'Осталось попыток: $_attemptsLeft\n\n'
                  'Ожидание действий юнита для начала калибровки…',
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Описание задания:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Вам необходимо правильно распределить образовательные программы по двум '
                        'категориям: для детей (школьников) и для взрослых (студентов и специалистов). '
                        'Для этого прочитайте описание каждой программы и перетащите её в '
                        'соответствующий контейнер.',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: _attemptsLeft > 0
                          ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EducationGameScreen(
                              userId: widget.userId,
                              onUpdate: () {
                                widget.onUpdate();
                                _loadAttempts();
                              },
                            ),
                          ),
                        );
                      }
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32.0,
                          vertical: 16.0,
                        ),
                        child: Text(
                          _attemptsLeft > 0 ? 'Начать задание' : 'Попытки исчерпаны',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                  if (_attemptsLeft <= 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        'Вы использовали все доступные попытки',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}