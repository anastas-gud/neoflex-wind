class ShopItem {
  final int id;
  final String name;
  final String description;
  final int price;
  final int? stock;
  final String imagePath;
  final DateTime? purchasedAt; // Для истории покупок
  final int? popularity;       // Для популярных товаров

  ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.stock,
    required this.imagePath,
    this.purchasedAt,
    this.popularity,
  });
}