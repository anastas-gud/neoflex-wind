import 'package:flutter/material.dart';
import 'package:neoflex_quest/core/constants/colors.dart';
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
      _attemptsExceeded =
          3 <= (attemptsData.isNotEmpty ? attemptsData.length : 0);
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
            title: Text(
              'Результаты'.toUpperCase(),
              style: TextStyle(color: AppColors.orange),
            ),
            content: Text(
              'Вы правильно отсортировали $correct из $total элементов.\n'
              'Начислено ${correct * 2} мандаринок.\n'
              'Осталось попыток: $_attemptsLeft',
              style: TextStyle(color: AppColors.purple, fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (_attemptsLeft <= 0) {
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  'OK',
                  style: TextStyle(color: AppColors.softOrange),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Сортировка модулей'.toUpperCase(),
          style: const TextStyle(
            fontSize: 25,
            color: AppColors.orange,
            fontWeight: FontWeight.bold,
            letterSpacing: -1.8,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.orange, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.help, color: AppColors.orange, size: 30),
            onPressed:
                () => showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: Text(
                          'Помощь'.toUpperCase(),
                          style: TextStyle(color: AppColors.orange),
                        ),
                        content: Text(
                          'Сверху предоставлен список из 10 модулей, необходимо определить для каждого из них контейнер.\n'
                          'Для прочтения описания модуля нажмите на него.\n'
                          'Для переноса модуля в контейнер: зажмите, дождитесь появления тени, перенесите в нужный контейнер.\n'
                          'При удаления модуля из контейнера смахните его влево.',
                          style: TextStyle(
                            color: AppColors.purple,
                            fontSize: 16,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Понятно'.toUpperCase(),
                              style: TextStyle(color: AppColors.softOrange),
                            ),
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
                        color: AppColors.middlePurple,
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Максимальное количество попыток: 3',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.lightPurple,
                      ),
                    ),
                    SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Вернуться назад'.toUpperCase(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.middlePurple,
                        ),
                      ),
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
                        child: Column(
                          children: [
                            Expanded(
                              flex: 4,
                              // Список модулей
                              child: Container(
                                padding: EdgeInsets.all(10),
                                color: AppColors.lightLavender,
                                child: ScrollConfiguration(
                                  behavior: ScrollConfiguration.of(
                                    context,
                                  ).copyWith(scrollbars: false),
                                  child: ListView.builder(
                                    itemCount: _leftItems.length,
                                    itemBuilder:
                                        (context, index) => _buildDraggableItem(
                                          _leftItems[index],
                                        ),
                                  ),
                                ),
                              ),
                            ),
                            // Центральный блок с описанием
                            Expanded(
                              flex: 3,
                              child: Container(
                                padding: EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  border: Border.symmetric(
                                    vertical: BorderSide(
                                      color: Colors.transparent,
                                    ),
                                  ),
                                ),
                                child:
                                    _selectedItem != null
                                        ? ScrollConfiguration(
                                          behavior: ScrollConfiguration.of(
                                            context,
                                          ).copyWith(scrollbars: false),
                                          child: SingleChildScrollView(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Модуль:\n${_selectedItem!.title}',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.softOrange,
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                                Text(
                                                  'Описание:\n${_selectedItem!.fullDescription}',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: AppColors.darkPurple,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                        : Center(
                                          child: Text(
                                            'Выберите модуль для просмотра описания',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: AppColors.darkPurple,
                                            ),
                                          ),
                                        ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Row(
                                children: [
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: _buildContainer(
                                      'children',
                                      'Для детей',
                                      AppColors.pink.withOpacity(0.15),
                                      Icons.child_care,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: _buildContainer(
                                      'adults',
                                      'Для взрослых',
                                      AppColors.blue.withOpacity(0.15),
                                      Icons.work,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: AppColors.orange,
                              backgroundColor: AppColors.white,
                              side: BorderSide(
                                color: AppColors.orange,
                                width: 2.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 15,
                              ),
                            ),
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
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.orange,
                                      ),
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
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Draggable<EducationItem>(
        data: item,
        feedback: Material(
          elevation: 4,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.25,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AppColors.softLavender,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              item.title,
              style: TextStyle(fontSize: 12),
              softWrap: true,
            ),
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
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color:
              _selectedItem == item
                  ? AppColors.softOrange.withOpacity(0.75)
                  : AppColors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          item.title,
          style: TextStyle(
            fontSize: 14,
            color:
                _selectedItem == item
                    ? AppColors.delicatePink
                    : AppColors.darkPurple,
          ),
          overflow: TextOverflow.ellipsis,
          softWrap: true,
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
                    ? Border.all(color: AppColors.softOrange, width: 2)
                    : null,
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.transparent)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 20, color: AppColors.middlePurple),
                    SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        title.toUpperCase(),
                        style: TextStyle(
                          color: AppColors.middlePurple,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
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
                            style: TextStyle(
                              color: AppColors.darkPurple,
                              fontSize: 12,
                            ),
                          ),
                        )
                        : ScrollConfiguration(
                          behavior: ScrollConfiguration.of(
                            context,
                          ).copyWith(scrollbars: false),
                          child: ListView.builder(
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
                                    color: AppColors.deepPinkPurple,
                                    alignment: Alignment.centerRight,
                                    padding: EdgeInsets.only(right: 20),
                                    child: Icon(
                                      Icons.delete,
                                      color: AppColors.middlePurple,
                                    ),
                                  ),
                                  onDismissed:
                                      (direction) =>
                                          _removeFromContainer(item, category),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width,
                                    ),
                                    child: InkWell(
                                      onTap: () => _onItemSelected(item),
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.white,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          item.title,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.darkPurple,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
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
