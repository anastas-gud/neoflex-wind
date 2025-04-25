import 'dart:math';

import 'package:flutter/material.dart';
import 'package:neoflex_quest/core/constants/strings.dart';
import 'package:neoflex_quest/core/models/shop_item.dart';
import 'package:neoflex_quest/core/services/shop_service.dart';
import 'package:neoflex_quest/core/services/data_service.dart';
import 'package:neoflex_quest/shared/widgets/small_mascot_widget.dart';

import '../../../../core/constants/colors.dart';
import '../../../../shared/widgets/mascot_widget.dart';
import '../../../../core/database/database_service.dart';

class ShopScreen extends StatefulWidget {
  final int userId;
  final VoidCallback onUpdate;

  const ShopScreen({required this.userId, required this.onUpdate, Key? key})
    : super(key: key);

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
    final shopService = ShopService();
    return await shopService.getShopItems();
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
    final shopService = ShopService();
    try {
      final response = await shopService.purchaseItem(widget.userId, item.id);

      // Проверяем статус код вместо поля 'success'
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Покупка совершена успешно!'),
          duration: const Duration(seconds: 2),
        ),
      );

      // Обновляем состояние
      widget.onUpdate();
      setState(() {
        _itemsFuture = _loadItems();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
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
                    'Торговая точка'.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 25,
                      color: AppColors.pink,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1.8,
                    ),
                  ),
                  SmallMascotWidget(
                    message: AppStrings.shopDescription,
                    imagePath: 'assets/images/shop.png',
                    boxWidth: _boxWidth,
                    shift: 110,
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
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Image.asset(
                                item.imagePath,
                                width: 50,
                                height: 50,
                                errorBuilder:
                                    (_, __, ___) => Icon(
                                      Icons.shopping_bag,
                                      size: 50,
                                      color: AppColors.lightPurple,
                                    ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.middlePurple,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      item.description,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.darkPurple,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '${item.price} мандаринок',
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 12),
                              SizedBox(
                                height: 40, // Фиксированная высота кнопки
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.softOrange,
                                  ),
                                  onPressed: () => _buyItem(item),
                                  child: Text(
                                    'Купить'.toUpperCase(),
                                    style: TextStyle(
                                      color: AppColors.delicatePink,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
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
