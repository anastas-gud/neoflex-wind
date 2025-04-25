import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:neoflex_quest/core/models/shop_item.dart';
import 'package:neoflex_quest/core/services/data_service.dart';

import '../constants/strings.dart';
import '../database/database_service.dart';

class ShopService {
  // Получаем все товары в магазине
  Future<List<ShopItem>> getShopItems() async {
    final response = await http.get(
      Uri.parse('${AppStrings.baseUrl}/shop/items'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      final List<dynamic> data = jsonDecode(responseBody);
      return data.map((item) => ShopItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load shop items: ${response.statusCode}');
    }
  }

  final http.Client _client;

  ShopService({http.Client? client}) : _client = client ?? http.Client();

  // Покупка товара
  Future<Map<String, dynamic>> purchaseItem(int userId, int itemId) async {
    final response = await _client.post(
      Uri.parse('${AppStrings.baseUrl}/shop/purchases/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'itemId': itemId,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Purchase failed');
    }
  }
  // todo методы не используются и не проверены, скорее всего не работают
  Future<List<Map<String, dynamic>>> getPurchaseHistory(int userId) async {
    final response = await _client.get(
      Uri.parse('${AppStrings.baseUrl}/shop/purchases?userId=$userId'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    throw Exception('Failed to load purchase history');
  }

  // Популярные товары
  Future<List<ShopItem>> getPopularItems({int limit = 5}) async {
    final response = await _client.get(
      Uri.parse('${AppStrings.baseUrl}/shop/items/popular?limit=$limit'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ShopItem.fromJson(json)).toList();
    }
    throw Exception('Failed to load popular items: ${response.statusCode}');
  }
}