import 'package:flutter/material.dart';
import 'package:neoflex_quest/core/models/shop_item.dart';
import 'package:neoflex_quest/core/services/shop_service.dart';

import '../../../../core/database/database_service.dart';
import '../../../../shared/widgets/mascot_widget.dart';

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
    final shopService = ShopService(databaseService: DatabaseService());
    return await shopService.getShopItems();
  }

  void _handleMandarinTap() {
    final now = DateTime.now();
    if (_lastTapTime == null || now.difference(_lastTapTime!) > Duration(seconds: 1)) {
      _tapCount = 0;
    }

    _tapCount++;
    _lastTapTime = now;

    if (_tapCount >= 5) {
      _tapCount = 0;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Секретное достижение разблокировано! +10 мандаринок')),
      );
    }
  }

  Future<void> _buyItem(ShopItem item) async {
    final shopService = ShopService(databaseService: DatabaseService());
    try {
      final success = await shopService.purchaseItem(widget.userId, item.id);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Покупка совершена!')),
        );
        setState(() {
          _itemsFuture = _loadItems(); // Обновляем список товаров
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: ${e.toString()}')),
      );
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

          return Column(
            children: [
              MascotWidget(
                message: 'Инициализация торгового протокола…\n\n'
                    'Внимание, юнит! Здесь циркулируют Мандаринки – валюта умных и быстрых. '
                    'Обменивай, трать, получай артефакты.\n\n'
                    'Рекомендация: действуйте без задержек!',
              ),
              Divider(),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      child: ListTile(
                        leading: Image.asset(
                          item.imagePath,
                          width: 50,
                          errorBuilder: (_, __, ___) => Icon(Icons.shopping_bag),
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
              ),
            ],
          );
        },
      ),
    );
  }
}