class Purchase {
  final int id;
  final int userId;
  final int itemId;
  final DateTime purchasedAt;
  final String status;

  Purchase({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.purchasedAt,
    required this.status,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['id'],
      userId: json['userId'],
      itemId: json['itemId'],
      purchasedAt: DateTime.parse(json['purchasedAt']),
      status: json['status'] ?? 'pending',
    );
  }
}