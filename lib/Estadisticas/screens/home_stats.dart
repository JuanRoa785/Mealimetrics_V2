import 'package:flutter/material.dart';
//import 'package:mealimetrics/Estadisticas/widgets/pie_chart_widget.dart';
import 'package:mealimetrics/styles/color_scheme.dart';
import '../models/dish.dart' as models;
import '../models/order.dart' as services;
import '../models/order_dish.dart' as services;
import '../services/supabase_service.dart' as services;
import '../widgets/bar_chart_widget.dart';

class HomeStats extends StatefulWidget {
  final String supabaseUrl;
  final String supabaseKey;
  const HomeStats({super.key, required this.supabaseUrl, required this.supabaseKey});

  @override
  // ignore: library_private_types_in_public_api
  _HomeStatsState createState() => _HomeStatsState();
}

class _HomeStatsState extends State<HomeStats> with SingleTickerProviderStateMixin{
  late services.SupabaseService supabaseService;
  //late Future<Map<String, int>> dishSalesFuture;
  //late Future<Map<DateTime, double>> salesByDateFuture;
  late TabController tabController;
  late String selectedPeriod = 'Semana';

  @override
  void initState() {
    super.initState();
    tabController = TabController(vsync: this, length: 4);
    supabaseService = services.SupabaseService();
    //dishSalesFuture = _loadDishSales(filtro);
    //print(dishSalesFuture);
    //salesByDateFuture = _loadSalesByDate(filtro);
  }

  Future<Map<String, int>> _loadDishSales(String filtro) async {
    final dishes = await supabaseService.getDishes(filtro);
    final orderDishes = await supabaseService.getOrderDishes();
    return getOrderedDishSales(dishes, orderDishes);
  }

  /*Future<Map<DateTime, double>> _loadSalesByDate(String filtro) async {
    final dishes = await supabaseService.getDishes(filtro);
    final orders = await supabaseService.getOrders();
    final orderDishes = await supabaseService.getOrderDishes();
    return calculateSalesByDate(dishes, orders, orderDishes);
  }*/

  Map<String, int> calculateDishSales(List<models.Dish> dishes, List<services.OrderDish> orderDishes) {
    Map<int, int> dishSales = {};

    for (var orderDish in orderDishes) {
      if (!dishSales.containsKey(orderDish.dishId)) {
        dishSales[orderDish.dishId] = 0;
      }
      dishSales[orderDish.dishId] = dishSales[orderDish.dishId]! + orderDish.quantity;
    }

    Map<String, int> dishSalesNamed = {};
    for (var dish in dishes) {
      dishSalesNamed[dish.name] = dishSales[dish.id] ?? 0;
    }

    return dishSalesNamed;
  }

  Map<DateTime, double> calculateSalesByDate(List<models.Dish> dishes, List<services.Order> orders, List<services.OrderDish> orderDishes) {
    Map<DateTime, double> salesByDate = {};

    for (var order in orders) {
      salesByDate[order.createdAt] = 0.0;
    }

    for (var orderDish in orderDishes) {
      var order = orders.firstWhere((o) => o.id == orderDish.orderId);
      var dish = dishes.firstWhere((d) => d.id == orderDish.dishId);
      double salesValue = dish.unitPrice * orderDish.quantity;
      salesByDate[order.createdAt] = salesByDate[order.createdAt]! + salesValue;
    }

    return salesByDate;
  }

  Map<String, int> getOrderedDishSales(List<models.Dish> dishes, List<services.OrderDish> orderDishes) {
      Map<String, int> dishSalesNamed = calculateDishSales(dishes, orderDishes);
      var sortedEntries = dishSalesNamed.entries.toList();
      sortedEntries.sort((a, b) => b.value.compareTo(a.value));
      Map<String, int> sortedDishSalesNamed = Map.fromEntries(sortedEntries.take(20));
      //print(sortedDishSalesNamed);
      return sortedDishSalesNamed;
    }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, 
      child: Scaffold(
      appBar: AppBar(
        backgroundColor: EsquemaDeColores.backgroundSecondary,
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(0), // Eliminar espacio adicional
            child: Container(
              color: EsquemaDeColores.backgroundSecondary,
              child: TabBar(
                controller: tabController,
                tabs: const [
                  Tab(icon: Icon(Icons.fastfood_sharp)),
                  Tab(icon: Icon(Icons.local_dining)),
                  Tab(icon: Icon(Icons.rice_bowl)),
                  Tab(icon: Icon(Icons.local_drink))
                ],
              ),
            ),
          ),
        ),
      body: TabBarView(
          controller: tabController,
          children: [
            _buildStatsView('especiales'),
            _buildStatsView('seco'),
            _buildStatsView('principios'),
            _buildStatsView('bebidas')
          ],
        ),
      ),
    );
  }

  Widget _buildStatsView(String filter) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400), // Limita el ancho máximo del contenedor
              child: Align(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Centra horizontalmente los elementos
                  children: [
                    const Text(
                      'Periodo de Tiempo:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: EsquemaDeColores.primary,
                      ),
                    ),
                    const SizedBox(width: 20),
                    DropdownButton<String>(
                      value: selectedPeriod,
                      onChanged: (newValue) {
                        setState(() {
                          selectedPeriod = newValue!;
                          // Aquí puedes implementar la lógica para actualizar los datos según el periodo seleccionado
                        });
                      },
                      items: <String>['Semana', 'Mes', 'Año'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          FutureBuilder<Map<String, int>>(
            future: _loadDishSales(filter),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No hay datos disponibles'));
              } else {
                return BarChartWidget(dishSales: snapshot.data!);
              }
            },
          ),
          /*
          FutureBuilder<Map<DateTime, double>>(
              future: _loadSalesByDate(filter),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No hay datos disponibles'));
                } else {
                  return PieChartWidget(salesByDate: snapshot.data!);
                }
              },
            ),*/
        ],
      ),
    );
  }
}
