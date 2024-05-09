// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
//import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:mealimetrics/styles/color_scheme.dart';
import 'package:mealimetrics/widgets/custom_alert.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GestionMenu extends StatefulWidget {
  const GestionMenu({super.key});
  @override
  State<GestionMenu> createState() => _GestionMenuState();
}

class _GestionMenuState extends State<GestionMenu>{
  final supabase = Supabase.instance.client;
  final TextEditingController platilloController = TextEditingController();
  List<Map<String, dynamic>> platillos = [];
  List<Map<String, dynamic>> principios = [];
  List<Map<String, dynamic>> complementos = [];

  @override
  void initState() {
    super.initState();
    cargarPlatillos();
  }

  Future<void> cargarPlatillos() async {
    final dataPlatos = await supabase
                  .from('Platillo')
                  .select()
                  .eq('categoria_alimenticia', 'Seco');

    final dataPrinc = await supabase
                  .from('Platillo')
                  .select()
                  .eq('categoria_alimenticia', 'Principio');

    final dataComp = await supabase
                  .from('Platillo')
                  .select()
                  .or('categoria_alimenticia.eq.Bebida, categoria_alimenticia.eq.Sopa');
    
    setState(() {
      platillos = dataPlatos;
      principios = dataPrinc;
      complementos = dataComp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, 
      child: Scaffold(
      appBar: AppBar(
        backgroundColor: EsquemaDeColores.backgroundSecondary,
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(0), // Eliminar espacio adicional
            child: Container(
              color: EsquemaDeColores.backgroundSecondary,
              child: const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.rice_bowl)),
                  Tab(icon: Icon(Icons.local_dining)),
                  Tab(icon: Icon(Icons.local_drink)),
                ],
              ),
            ),
          ),
        ),
      body: TabBarView(
          children: [
            _buildTabContent(principios, 'principios'),
            _buildTabContent(platillos, 'seco'),
            _buildTabContent(complementos, 'complementos')
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(List<Map<String, dynamic>> platos, String filtro) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(left: 10, right: 15.0, top: 10),
          child: 
          Row(
            children: [
              Expanded(child: 
                TextField(
                    controller: platilloController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.abc),
                      hintText: "Buscar Platillo",
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 3),
                    ),
                    onChanged: (value) {},
                  ),
              ),
              Padding(
              padding: const EdgeInsets.only(left: 10),
              child: ElevatedButton(
                onPressed: () async {
                  final String nombre = platilloController.text.trim();
                  if (nombre == '') {
                    showCustomErrorDialog(context, '¡Digite una palabra clave en el buscador!');
                    cargarPlatillos();
                    return;
                  }
                  List<Map<String, dynamic>> platillosFiltrados;
                   switch (filtro) {
                     case 'principios':
                        platillosFiltrados = await supabase
                          .from('Platillo')
                          .select()
                          .eq('categoria_alimenticia', 'Principio')
                          .ilike('nombre', '%$nombre%');
                        
                        if(platillosFiltrados.isEmpty){
                          showCustomErrorDialog(context, "¡No hay ningun plato que tenga en su nombre: '$nombre'!");
                          cargarPlatillos();
                          platilloController.clear();
                          return;
                        }

                        setState(() {
                           principios = platillosFiltrados;
                        });
                        break;

                      case 'seco':
                        platillosFiltrados = await supabase
                          .from('Platillo')
                          .select()
                          .eq('categoria_alimenticia', 'Seco')
                          .ilike('nombre', '%$nombre%');
                        
                        if(platillosFiltrados.isEmpty){
                          showCustomErrorDialog(context, "¡No hay ningun plato que tenga en su nombre: '$nombre'!");
                          cargarPlatillos();
                          platilloController.clear();
                          return;
                        }

                        setState(() {
                           platillos = platillosFiltrados; 
                        });
                        break; 

                     case 'complementos':
                        platillosFiltrados = await supabase
                          .from('Platillo')
                          .select()
                          .or('categoria_alimenticia.eq.Bebida, categoria_alimenticia.eq.Sopa')
                          .ilike('nombre', '%$nombre%');
                        
                        if(platillosFiltrados.isEmpty){
                          showCustomErrorDialog(context, "¡No hay ningun plato que tenga en su nombre: '$nombre'!");
                          cargarPlatillos();
                          platilloController.clear();
                          return;
                        }

                        setState(() {
                           complementos = platillosFiltrados; // Actualizar la lista de platillos
                        });  
                        break; 
                     default:
                   }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: EsquemaDeColores.background,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Icon(Icons.search, color: Colors.black),
              ),
            ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Lógica para crear un nuevo platillo
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text(
                    'Agregar',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20), // Espacio entre los botones
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Lógica para eliminar un platillo
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text(
                    'Eliminar',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _buildPlatillosList(platos),
        ),
      ],
    );
  }

  Widget _buildPlatillosList(List<Map<String, dynamic>> platillos) {
    return ListView.builder(
      itemCount: platillos.length,
      itemBuilder: (context, index) {
        final platillo = platillos[index];
        return buildPlatilloCard(platillo); // Construye la tarjeta de cada platillo
      },
    );
  }

  Card buildPlatilloCard(Map<String, dynamic> platillo) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.all(10),
      child: Row(
        children: [
          Padding(
            padding:const EdgeInsets.only(left: 8.0, right: 4.0, top: 5.0),
            child: SizedBox(
                width: 120,
                height: 120,
                child: Image.network(
                  platillo['imagen'],
                  fit: BoxFit.cover,
                ),
              ),
            ),
          // Columna derecha (Nombre, Descripción, Precio)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 15.0, top: 10.0, bottom: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Text(
                        platillo['nombre'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    platillo['descripcion'],
                    style: const TextStyle(fontSize: 17),
                    textAlign: TextAlign.justify
                  ),
                  const SizedBox(height: 5),
                  // Precio del platillo
                  RichText(
                  text: TextSpan(
                    text: 'Precio: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: EsquemaDeColores.onSecondary,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: '\$${platillo['precio_unitario']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 19,
                          color: Colors.green // Puedes personalizar el estilo aquí
                        ),
                      ),
                    ],
                  ),
                ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


}

