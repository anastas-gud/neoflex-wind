import 'dart:math';

import 'package:flutter/material.dart';
import 'package:neoflex_quest/core/models/shop_item.dart';
import 'package:neoflex_quest/core/services/shop_service.dart';
import 'package:neoflex_quest/core/database/database_service.dart';
import 'package:neoflex_quest/shared/widgets/small_mascot_widget.dart';

class ShopScreen extends StatefulWidget {
  final int userId;

  const ShopScreen({required this.userId, Key? key}) : super(key: key);

  @override
  _ShopScreenState createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  late Future<List<ShopItem>> _itemsFuture;
  int _tapCount = 0;
  DateTime? _lastTapTime;

  @override
  void initState() {
    super.initState();
    _itemsFuture = _loadItems();
  }

  Future<List<ShopItem>> _loadItems() async {
    // todo расскоментить, убрать тестовые
    // final shopService = ShopService(databaseService: DatabaseService());
    // return await shopService.getShopItems();
    final List<List<dynamic>> results = [
      [
        1,
        'Оригинальный худи NeoFlex',
        'Мягкий худи с логотипом квеста',
        1500,
        10,
        'assets/shop_items/hoodie.png',
      ],
      [
        2,
        'Эксклюзивный брелок',
        'Металлический брелок в форме мандаринки',
        500,
        null, // Нет данных о количестве
        'assets/shop_items/keychain.png',
      ],
      [
        3,
        'Коллекционная кружка',
        'Керамическая кружка с дизайном машины времени',
        800,
        5,
        'assets/shop_items/mug.png',
      ],
      [
        4,
        'Набор стикеров',
        '8 виниловых стикеров с персонажами квеста',
        300,
        20,
        'assets/shop_items/stickers.png',
      ],
      [
        5,
        'Ограниченная футболка',
        'Хлопковая футболка с принтом образовательных миссий',
        1200,
        3,
        'assets/shop_items/tshirt.png',
      ],
    ];

    return results
        .map(
          (row) => ShopItem(
            id: row[0] as int,
            name: row[1] as String,
            description: row[2] as String,
            price: row[3] as int,
            stock: row[4] as int?,
            imagePath: row[5] as String,
          ),
        )
        .toList();
  }

  void _handleMandarinTap() {
    final now = DateTime.now();
    if (_lastTapTime == null ||
        now.difference(_lastTapTime!) > Duration(seconds: 1)) {
      _tapCount = 0;
    }

    _tapCount++;
    _lastTapTime = now;

    if (_tapCount >= 5) {
      _tapCount = 0;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Секретное достижение разблокировано! +10 мандаринок'),
        ),
      );
    }
  }

  Future<void> _buyItem(ShopItem item) async {
    final shopService = ShopService(databaseService: DatabaseService());
    try {
      final success = await shopService.purchaseItem(widget.userId, item.id);

      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Покупка совершена!')));
        setState(() {
          _itemsFuture = _loadItems(); // Обновляем список товаров
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<ShopItem>>(
        future: _itemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Ошибка загрузки магазина'));
          }

          final items = snapshot.data!;

          double _boxWidth = min(MediaQuery.of(context).size.width * 0.9, 450);
          return ScrollConfiguration(
            behavior: ScrollConfiguration.of(
              context,
            ).copyWith(scrollbars: false),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 15),
                  Text(
                    "Торговая точка",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  SmallMascotWidget(
                    boxWidth: _boxWidth,
                    message:
                        'Инициализация торгового протокола…\n'
                        'Внимание, юнит! Здесь циркулируют Мандаринки – валюта умных и быстрых. '
                        'Обменивай, трать, получай артефакты.\n'
                        'Рекомендация: действуйте без задержек!',
                  ),
                  SizedBox(height: 15),
                  Divider(),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.all(15),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Card(
                        child: ListTile(
                          leading: Image.asset(
                            item.imagePath,
                            width: 50,
                            errorBuilder:
                                (_, __, ___) => Icon(Icons.shopping_bag),
                          ),
                          title: Text(item.name),
                          subtitle: Text(item.description),
                          trailing: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${item.price} мандаринок'),
                              ElevatedButton(
                                onPressed: () => _buyItem(item),
                                child: Text('Купить'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
