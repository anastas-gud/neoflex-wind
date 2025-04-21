import 'package:flutter/material.dart';
import 'package:neoflex_quest/core/models/education_item.dart';
import 'package:neoflex_quest/core/database/database_service.dart';
import 'package:neoflex_quest/shared/widgets/mascot_widget.dart';

class EducationGameScreen extends StatefulWidget {
  final int userId;
  final VoidCallback onUpdate;

  const EducationGameScreen({
    required this.userId,
    required this.onUpdate,
    Key? key,
  }) : super(key: key);

  @override
  _EducationGameScreenState createState() => _EducationGameScreenState();
}

class _EducationGameScreenState extends State<EducationGameScreen> {
  late Future<List<EducationItem>> _itemsFuture;
  List<EducationItem> _leftItems = [];
  List<EducationItem> _topContainer = [];
  List<EducationItem> _bottomContainer = [];
  EducationItem? _selectedItem;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _itemsFuture = _loadItems();
  }

  Future<List<EducationItem>> _loadItems() async {
    final connection = await DatabaseService().getConnection();
    try {
      final results = await connection.query('SELECT * FROM education_items');
      return results.map((row) => EducationItem(
        id: row[0] as int,
        title: row[1] as String,
        shortDescription: row[2] as String,
        fullDescription: row[3] as String,
        correctCategory: row[4] as String,
        points: row[5] as int,
      )).toList();
    } finally {
      await connection.close();
    }
  }

  Future<void> _saveUserAnswers() async {
    final connection = await DatabaseService().getConnection();
    try {
      // Сохраняем ответы пользователя
      for (var item in _topContainer) {
        await connection.query(
          'INSERT INTO education_answers (user_id, item_id, selected_category, is_correct) '
              'VALUES (@userId, @itemId, @category, @isCorrect) '
              'ON CONFLICT (user_id, item_id) DO UPDATE '
              'SET selected_category = @category, is_correct = @isCorrect',
          substitutionValues: {
            'userId': widget.userId,
            'itemId': item.id,
            'category': 'children',
            'isCorrect': item.correctCategory == 'children',
          },
        );
      }

      for (var item in _bottomContainer) {
        await connection.query(
          'INSERT INTO education_answers (user_id, item_id, selected_category, is_correct) '
              'VALUES (@userId, @itemId, @category, @isCorrect) '
              'ON CONFLICT (user_id, item_id) DO UPDATE '
              'SET selected_category = @category, is_correct = @isCorrect',
          substitutionValues: {
            'userId': widget.userId,
            'itemId': item.id,
            'category': 'adults',
            'isCorrect': item.correctCategory == 'adults',
          },
        );
      }

      // Обновляем баланс пользователя
      final correctAnswers = _topContainer.where((item) => item.correctCategory == 'children').length +
          _bottomContainer.where((item) => item.correctCategory == 'adults').length;

      final pointsEarned = correctAnswers * 10;

      await connection.query(
        'UPDATE users SET points = points + @points WHERE id = @userId',
        substitutionValues: {
          'points': pointsEarned,
          'userId': widget.userId,
        },
      );
    } finally {
      await connection.close();
    }
  }

  void _onItemSelected(EducationItem item) {
    setState(() {
      _selectedItem = item;
    });
  }

  void _onItemDropped(EducationItem item, String targetCategory) {
    setState(() {
      _leftItems.remove(item);
      _topContainer.remove(item);
      _bottomContainer.remove(item);

      if (targetCategory == 'children') {
        _topContainer.add(item);
      } else {
        _bottomContainer.add(item);
      }
    });
  }

  void _removeFromContainer(EducationItem item, String sourceCategory) {
    setState(() {
      if (sourceCategory == 'children') {
        _topContainer.remove(item);
      } else {
        _bottomContainer.remove(item);
      }
      _leftItems.add(item);
    });
  }

  Future<void> _checkAnswers() async {
    setState(() => _isChecking = true);

    await _saveUserAnswers();
    widget.onUpdate(); // Вызываем callback для обновления главного экрана

    setState(() => _isChecking = false);

    final correct = _topContainer.where((item) => item.correctCategory == 'children').length +
        _bottomContainer.where((item) => item.correctCategory == 'adults').length;
    final total = _topContainer.length + _bottomContainer.length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Результаты'),
        content: Text('Вы правильно отсортировали $correct из $total элементов.\n\n'
            'Начислено ${correct * 10} мандаринок.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Сортировка программ'),
        actions: [
          IconButton(
            icon: Icon(Icons.help),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Помощь'),
                content: Text('Перетащите элементы в соответствующие контейнеры:\n\n'
                    '🔵 Синий - программы для детей\n'
                    '🟢 Зеленый - программы для взрослых'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Понятно'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<EducationItem>>(
        future: _itemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Ошибка загрузки данных'));
          }

          if (_leftItems.isEmpty && _topContainer.isEmpty && _bottomContainer.isEmpty) {
            _leftItems = List.from(snapshot.data!);
          }

          return Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        color: Colors.grey[100],
                        child: ListView.builder(
                          itemCount: _leftItems.length,
                          itemBuilder: (context, index) => _buildDraggableItem(_leftItems[index]),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.symmetric(
                            vertical: BorderSide(color: Colors.grey),
                          ),
                        ),
                        child: _selectedItem != null
                            ? SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedItem!.title,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(_selectedItem!.fullDescription),
                            ],
                          ),
                        )
                            : Center(
                          child: Text(
                            'Выберите элемент для просмотра описания',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          Expanded(
                            child: _buildContainer(
                              'children',
                              'Для детей',
                              Colors.blue[50]!,
                              Icons.child_care,
                            ),
                          ),
                          Divider(height: 1),
                          Expanded(
                            child: _buildContainer(
                              'adults',
                              'Для взрослых',
                              Colors.green[50]!,
                              Icons.work,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_topContainer.isEmpty && _bottomContainer.isEmpty) || _isChecking
                        ? null
                        : _checkAnswers,
                    child: _isChecking
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Проверить'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDraggableItem(EducationItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Draggable<EducationItem>(
        data: item,
        feedback: Material(
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              item.shortDescription,
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
        childWhenDragging: Container(),
        child: InkWell(
          onTap: () => _onItemSelected(item),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _selectedItem == item ? Colors.orange[200]! : Colors.orange[50]!,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _selectedItem == item ? Colors.orange : Colors.transparent,
                width: 2,
              ),
            ),
            child: Text(
              item.shortDescription,
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContainer(String category, String title, Color color, IconData icon) {
    final items = category == 'children' ? _topContainer : _bottomContainer;

    return DragTarget<EducationItem>(
      builder: (context, candidateData, rejectedData) {
        return Container(
          padding: EdgeInsets.all(8),
          color: color,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: Colors.grey[700]),
                    SizedBox(width: 8),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Dismissible(
                        key: Key('${item.id}_$category'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red[100],
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 20),
                          child: Icon(Icons.delete, color: Colors.red),
                        ),
                        onDismissed: (direction) => _removeFromContainer(item, category),
                        child: InkWell(
                          onTap: () => _onItemSelected(item),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 2,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Text(
                              item.shortDescription,
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
      onWillAccept: (data) => true,
      onAccept: (item) => _onItemDropped(item, category),
    );
  }
}