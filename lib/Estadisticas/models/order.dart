class Order {
  final int id;
  final DateTime createdAt;
  final int totalPrice;

  Order({required this.id, required this.createdAt, required this.totalPrice});

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      createdAt: DateTime.parse(map['created_at']),
      totalPrice: map['precioTotal'],
    );
  }
}
