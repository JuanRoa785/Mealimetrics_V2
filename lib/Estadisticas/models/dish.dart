class Dish {
  final int id;
  final String name;
  final double unitPrice;

  Dish({required this.id, required this.name, required this.unitPrice});

  factory Dish.fromMap(Map<String, dynamic> map) {
    return Dish(
      id: map['id'],
      name: map['nombre'],
      unitPrice: (map['precio_unitario'] as num).toDouble(),
    );
  }
}
