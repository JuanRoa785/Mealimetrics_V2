import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/dish.dart';
import '../models/order.dart';
import '../models/order_dish.dart';

class SupabaseService {
  final client = Supabase.instance.client;
  
  Future<List<Dish>> getDishes(String filtro) async {
    final PostgrestList response;
    switch (filtro) {
      case 'especiales':
        response = await client
            .from('Platillo')
            .select()
            .eq('categoria_alimenticia', 'Especial')
            .order('nombre', ascending: true);   
        final data = response as List<dynamic>;
        return data.map((map) => Dish.fromMap(map)).toList();     
      case 'seco':
         response = await client
            .from('Platillo')
            .select()
            .eq('categoria_alimenticia', 'Seco')
            .order('nombre', ascending: true);   
        final data = response as List<dynamic>;
        return data.map((map) => Dish.fromMap(map)).toList();
      case 'principios':
        response = await client
              .from('Platillo')
              .select()
              .or('categoria_alimenticia.eq.Principio, categoria_alimenticia.eq.Complemento')
              .order('nombre', ascending: true);   
          final data = response as List<dynamic>;
          return data.map((map) => Dish.fromMap(map)).toList();
      case 'bebidas':
        response = await client
            .from('Platillo')
            .select()
            .or('categoria_alimenticia.eq.Bebida, categoria_alimenticia.eq.Sopa')
            .order('nombre', ascending: true);   
        final data = response as List<dynamic>;
        return data.map((map) => Dish.fromMap(map)).toList();
      default:
        response = await client
            .from('Platillo')
            .select();  
        final data = response as List<dynamic>;
        return data.map((map) => Dish.fromMap(map)).toList();
    }
  }

  Future<List<Order>> getOrders() async {
    final response = await client.from('Pedido').select();
    final data = response as List<dynamic>;
    return data.map((map) => Order.fromMap(map)).toList();
  }

  Future<List<OrderDish>> getOrderDishes() async {
    final response = await client.from('Relacion_Pedido_Platillo').select();
    final data = response as List<dynamic>;
    return data.map((map) => OrderDish.fromMap(map)).toList();
  }
}
