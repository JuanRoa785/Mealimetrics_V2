class OrderDish {
  final int id;
  final int orderId;
  final int dishId;
  final int quantity;

  OrderDish({
    required this.id,
    required this.orderId,
    required this.dishId,
    required this.quantity,
  });

  factory OrderDish.fromMap(Map<String, dynamic> map) {
    return OrderDish(
      id: map['id'],
      orderId: map['id_pedido'],
      dishId: map['id_platillo'],
      quantity: map['cantidad'],
    );
  }
}
