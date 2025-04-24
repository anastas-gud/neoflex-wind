import 'package:flutter/material.dart';
import 'package:neoflex_quest/core/models/education_item.dart';
import 'package:neoflex_quest/core/services/education_service.dart';

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
  int _attemptsLeft = 3;
  bool _attemptsExceeded = false;

  final EducationService _educationService = EducationService();

  @override
  void initState() {
    super.initState();
    _loadAttempts();
    _itemsFuture = _loadItems().then((items) {
      if (items.length != 10) {
        debugPrint('Warning: Expected 10 items, got ${items.length}');
      }
      return items;
    });
  }

  Future<List<EducationItem>> _loadItems() async {
    return await _educationService.getEducationItems();
  }

  Future<void> _loadAttempts() async {
    final attemptsData = await _educationService.getUserEducationAttempts(
      widget.userId,
    );
    setState(() {
      _attemptsLeft = attemptsData.isNotEmpty ? 3 - attemptsData.length : 3;
      _attemptsExceeded = 3 <= (attemptsData.isNotEmpty ? attemptsData.length : 0);
    });
  }

  Future<void> _incrementAttempts() async {
    try {
      await _educationService.incrementAttempts(widget.userId);
      setState(() {
        _attemptsLeft--;
        _attemptsExceeded = _attemptsLeft <= 0;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при обновлении попыток: $e')),
      );
    }
  }

  Future<void> _saveUserAnswers() async {
    try {
      await _educationService.saveUserAnswers(
        userId: widget.userId,
        topContainer: _topContainer,
        bottomContainer: _bottomContainer,
      );
      widget.onUpdate();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка сохранения: $e')));
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

      _selectedItem = item;
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
    if (_attemptsExceeded) return;

    setState(() => _isChecking = true);

    await _saveUserAnswers();
    await _incrementAttempts();
    widget.onUpdate();

    setState(() => _isChecking = false);

    final correct =
        _topContainer
            .where((item) => item.correctCategory == 'children')
            .length +
        _bottomContainer
            .where((item) => item.correctCategory == 'adults')
            .length;
    final total = _topContainer.length + _bottomContainer.length;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Text('Результаты'),
            content: Text(
              'Вы правильно отсортировали $correct из $total элементов.\n\n'
              'Начислено ${correct * 2} мандаринок.\n\n'
              'Осталось попыток: $_attemptsLeft',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (_attemptsLeft <= 0) {
                    Navigator.pop(context);
                  }
                },
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
            onPressed:
                () => showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: Text('Помощь'),
                        content: Text(
                          'Перетащите элементы в соответствующие контейнеры:\n\n'
                          '🔵 Синий - программы для детей\n'
                          '🟢 Зеленый - программы для взрослых\n\n'
                          'Осталось попыток: $_attemptsLeft',
                        ),
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
      body:
          _attemptsExceeded
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Вы исчерпали все попытки',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text('Максимальное количество попыток: 3'),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Вернуться назад'),
                    ),
                  ],
                ),
              )
              : FutureBuilder<List<EducationItem>>(
                future: _itemsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Ошибка загрузки данных'));
                  }

                  if (_leftItems.isEmpty &&
                      _topContainer.isEmpty &&
                      _bottomContainer.isEmpty) {
                    _leftItems = List.from(snapshot.data!);
                  }

                  return Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Container(
                                padding: EdgeInsets.all(8),
                                color: Colors.grey[100],
                                child: ListView.builder(
                                  itemCount: _leftItems.length,
                                  itemBuilder:
                                      (context, index) => _buildDraggableItem(
                                        _leftItems[index],
                                      ),
                                ),
                              ),
                            ),
                            // Центральный блок с описанием
                            Expanded(
                              flex: 4, // Сделал немного уже
                              child: Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.symmetric(
                                    vertical: BorderSide(color: Colors.grey),
                                  ),
                                ),
                                child:
                                    _selectedItem != null
                                        ? SingleChildScrollView(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _selectedItem!.title,
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 16),
                                              Text(
                                                _selectedItem!.fullDescription,
                                              ),
                                            ],
                                          ),
                                        )
                                        : Center(
                                          child: Text(
                                            'Выберите элемент для просмотра описания',
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
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
                            onPressed:
                                (_topContainer.isEmpty &&
                                            _bottomContainer.isEmpty) ||
                                        _isChecking ||
                                        _attemptsExceeded
                                    ? null
                                    : _checkAnswers,
                            child:
                                _isChecking
                                    ? CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                    : Text(
                                      'Проверить (Осталось попыток: $_attemptsLeft)',
                                    ),
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
      child: LongPressDraggable<EducationItem>(
        data: item,
        feedback: Material(
          elevation: 4,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.25,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(item.title, style: TextStyle(fontSize: 12)),
          ),
        ),
        childWhenDragging: Opacity(opacity: 0.4, child: _buildItemCard(item)),
        onDragStarted: () => _onItemSelected(item),
        child: _buildItemCard(item),
      ),
    );
  }

  Widget _buildItemCard(EducationItem item) {
    return InkWell(
      onTap: () => _onItemSelected(item),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _selectedItem == item ? Colors.orange[200] : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _selectedItem == item ? Colors.orange : Colors.grey[300]!,
          ),
        ),
        child: Text(
          item.title,
          style: TextStyle(fontSize: 12),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ),
    );
  }

  Widget _buildContainer(
    String category,
    String title,
    Color color,
    IconData icon,
  ) {
    final items = category == 'children' ? _topContainer : _bottomContainer;

    return DragTarget<EducationItem>(
      builder: (context, candidateData, rejectedData) {
        return Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border:
                candidateData.isNotEmpty
                    ? Border.all(color: Colors.blue, width: 2)
                    : null,
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 16),
                    SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.visible,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child:
                    items.isEmpty
                        ? Center(
                          child: Text(
                            'Перетащите сюда',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        )
                        : ReorderableListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return Padding(
                              key: ValueKey('${item.id}_$category'),
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                              ),
                              child: Dismissible(
                                key: Key('${item.id}_$category'),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  color: Colors.red[100],
                                  alignment: Alignment.centerRight,
                                  padding: EdgeInsets.only(right: 20),
                                  child: Icon(Icons.delete, color: Colors.red),
                                ),
                                onDismissed:
                                    (direction) =>
                                        _removeFromContainer(item, category),
                                child: InkWell(
                                  onTap: () => _onItemSelected(item),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      item.title,
                                      style: TextStyle(fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          onReorder: (oldIndex, newIndex) {
                            setState(() {
                              if (oldIndex < newIndex) newIndex--;
                              final item = items.removeAt(oldIndex);
                              items.insert(newIndex, item);
                            });
                          },
                        ),
              ),
            ],
          ),
        );
      },
      onWillAccept: (data) => true,
      onAccept: (item) {
        if (!items.contains(item)) {
          _onItemDropped(item, category);
        }
      },
    );
  }
}
