// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
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
                  .or('categoria_alimenticia.eq.Principio, categoria_alimenticia.eq.Complemento');

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
            _buildTabContent(complementos, 'bebidas')
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
                          .or('categoria_alimenticia.eq.Principio, categoria_alimenticia.eq.Complemento')
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

                     case 'bebidas':
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
                    crearPlatillo();
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
                          color: Colors.green 
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Lógica para ACTUALIZAR un platillo
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: EsquemaDeColores.secondary,
                        ),
                        child: const Icon(Icons.update, color: Colors.white, size: 35,)
                      ),
                    ),
                    const SizedBox(width: 20), 
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          eliminarPlatillo(platillo);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Icon(Icons.delete_forever, color: Colors.white, size: 35,)
                      ),
                    ),
                  ],
                ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> crearPlatillo() async {
    String nombre = '';
    String descripcion = '';
    String precio = '';
    List<String> listaCategorias = ['Seco', 'Principio', 'Bebida', 'Sopa', 'Complemento'];
    String categoria = listaCategorias.first; // Categoría por defecto

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Crear Platillo",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 28,
                color: Colors.green,
              ),
              textAlign: TextAlign.center),
          contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child:  Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        labelStyle: TextStyle(
                          color: EsquemaDeColores.primary,
                          fontSize: 18,
                        ),
                      ),
                      onChanged: (value) {
                        nombre = value;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      maxLines: null, // Para permitir múltiples líneas
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        labelStyle: TextStyle(
                          color: EsquemaDeColores.primary,
                          fontSize: 18,
                        ),
                      ),
                      onChanged: (value) {
                        descripcion = value;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Precio',
                        labelStyle: TextStyle(
                          color: EsquemaDeColores.primary,
                          fontSize: 18,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        precio = value;
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text(
                          'Categoría:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: EsquemaDeColores.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        DropdownButton<String>(
                          value: categoria,
                          icon: const Icon(Icons.arrow_downward),
                          iconSize: 24,
                          elevation: 16,
                          style: const TextStyle(
                              color: Colors.deepPurple, fontSize: 18),
                          underline: Container(
                            height: 2,
                            color: Colors.deepPurpleAccent,
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              categoria = newValue!;
                            });
                          },
                          items: listaCategorias
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: EsquemaDeColores.primary,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ],
                )
              );
            },
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await supabase.from('Platillo').insert({
                        'nombre': nombre,
                        'descripcion': descripcion,
                        'precio_unitario':
                            int.parse(precio), // Convertir a entero
                        'categoria_alimenticia': categoria,
                      });
                      Navigator.of(context).pop();
                      cargarPlatillos();
                    } catch (e) {
                      showCustomErrorDialog(context, e.toString());
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Crear',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> eliminarPlatillo(Map<String, dynamic> platillo) async {
    await showDialog(
      context:context,
      builder: (BuildContext context){
        return AlertDialog(
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "¿Esta Seguro?",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: Colors.red,
                ),
              ),     
            ],
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          content: Column(
          mainAxisSize: MainAxisSize.min, 
          children: [
            const Text(
              "Eliminar este platillo es irreversible y su información no podrá ser recuperada.",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 21,
                color: EsquemaDeColores.onSecondary,
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 10), 
            ElevatedButton(
              onPressed: () async {
                try {
                  await supabase
                    .from('Platillo')
                    .delete()
                    .match({ 'id': platillo['id'] });
                  Navigator.of(context).pop();
                  setState(() {
                    cargarPlatillos();
                  });
                } catch (e) {
                  showCustomErrorDialog(context, e.toString());
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, 
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), 
                ),
              ),
              child: const Text(
                'Eliminar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: EsquemaDeColores.onPrimary
                ),
              ),
            ),
          ],
        ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      }
    );



  }

}

