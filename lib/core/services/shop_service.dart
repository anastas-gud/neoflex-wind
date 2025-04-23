import 'package:neoflex_quest/core/models/shop_item.dart';
import 'package:neoflex_quest/core/services/data_service.dart';

import '../database/database_service.dart';

class ShopService {
  final DatabaseService _databaseService;

  ShopService({required DatabaseService databaseService})
      : _databaseService = databaseService;

  // Получаем все товары в магазине
  Future<List<ShopItem>> getShopItems() async {
    final conn = await _databaseService.getConnection();
    try {
      final results = await conn.query(
        'SELECT id, name, description, price, stock, image_path FROM shop_items WHERE stock > 0 OR stock IS NULL',
      );

      return results.map((row) => ShopItem(
        id: row[0] as int,
        name: row[1] as String,
        description: row[2] as String,
        price: row[3] as int,
        stock: row[4] as int?,
        imagePath: row[5] as String,
      )).toList();
    } finally {
      await conn.close();
    }
  }

  // Покупка товара
  Future<bool> purchaseItem(int userId, int itemId) async {
    final conn = await _databaseService.getConnection();
    try {
      await conn.transaction((ctx) async {
        // Проверяем наличие товара
        final stock = await ctx.query(
          'SELECT stock, price FROM shop_items WHERE id = @itemId FOR UPDATE',
          substitutionValues: {'itemId': itemId},
        );

        if (stock.isEmpty) {
          throw Exception('Товар не найден');
        }

        final currentStock = stock[0][0] as int?;
        final price = stock[0][1] as int;

        if (currentStock != null && currentStock <= 0) {
          throw Exception('Товар закончился');
        }

        // Проверяем баланс пользователя
        final userBalance = await ctx.query(
          'SELECT points FROM users WHERE id = @userId FOR UPDATE',
          substitutionValues: {'userId': userId},
        );

        if (userBalance.isEmpty || (userBalance[0][0] as int) < price) {
          throw Exception('Недостаточно мандаринок');
        }

        // Уменьшаем количество товара (если не null)
        if (currentStock != null) {
          await ctx.query(
            'UPDATE shop_items SET stock = stock - 1 WHERE id = @itemId',
            substitutionValues: {'itemId': itemId},
          );
        }

        // Списание средств
        await ctx.query(
          'UPDATE users SET points = points - @price WHERE id = @userId',
          substitutionValues: {
            'userId': userId,
            'price': price,
          },
        );

        // Создаем запись о покупке
        await ctx.query(
          'INSERT INTO purchases (user_id, item_id) VALUES (@userId, @itemId)',
          substitutionValues: {
            'userId': userId,
            'itemId': itemId,
          },
        );
      });
      return true;
    } catch (e) {
      print('Purchase error: $e');
      throw Exception('Ошибка при покупке: ${e.toString()}');
    } finally {
      await conn.close();
    }
  }

  // Получаем историю покупок пользователя
  Future<List<ShopItem>> getPurchaseHistory(int userId) async {
    final conn = await _databaseService.getConnection();
    try {
      final results = await conn.query(
        '''SELECT si.id, si.name, si.description, si.price, si.image_path, p.purchased_at 
           FROM purchases p
           JOIN shop_items si ON p.item_id = si.id
           WHERE p.user_id = @userId
           ORDER BY p.purchased_at DESC''',
        substitutionValues: {'userId': userId},
      );

      return results.map((row) => ShopItem(
        id: row[0] as int,
        name: row[1] as String,
        description: row[2] as String,
        price: row[3] as int,
        imagePath: row[4] as String,
        // Дополнительное поле для истории
        purchasedAt: DateTime.parse(row[5] as String),
      )).toList();
    } finally {
      await conn.close();
    }
  }

  // Получаем топ товаров
  Future<List<ShopItem>> getPopularItems({int limit = 5}) async {
    final conn = await _databaseService.getConnection();
    try {
      final results = await conn.query(
        '''SELECT si.id, si.name, si.description, si.price, si.stock, si.image_path, COUNT(p.id) as purchases_count
           FROM shop_items si
           LEFT JOIN purchases p ON si.id = p.item_id
           GROUP BY si.id
           ORDER BY purchases_count DESC
           LIMIT @limit''',
        substitutionValues: {'limit': limit},
      );

      return results.map((row) => ShopItem(
        id: row[0] as int,
        name: row[1] as String,
        description: row[2] as String,
        price: row[3] as int,
        stock: row[4] as int?,
        imagePath: row[5] as String,
        // Дополнительное поле для популярности
        popularity: row[6] as int,
      )).toList();
    } finally {
      await conn.close();
    }
  }
}