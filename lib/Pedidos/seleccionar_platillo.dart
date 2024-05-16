// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealimetrics/Pedidos/estados/cuantos_platillos_quiere.dart';
import 'package:mealimetrics/Pedidos/formularios/seleccionar_cantidad_platillo.dart';
import 'package:mealimetrics/Styles/color_scheme.dart';
import 'package:mealimetrics/widgets/custom_alert.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class SeleccionarPlatillo extends ConsumerStatefulWidget {
  const SeleccionarPlatillo({super.key});

  @override
  _SeleccionarPlatilloState createState() => _SeleccionarPlatilloState();
}

class _SeleccionarPlatilloState extends ConsumerState<SeleccionarPlatillo> {
  final TextEditingController platilloController = TextEditingController();
  List<Map<String, dynamic>> platillos = [];
  List<Map<String, dynamic>> principios = [];
  List<Map<String, dynamic>> complementos = [];
  List<Map<String, dynamic>> platillosFiltrados = [];
  final HashSet<Map<String, dynamic>> _platillosSeleccionados = HashSet();

  @override
  void initState() {
    super.initState();

    /// con esta funcion vamos a la base de datos y
    /// hacemos "fetch" a la informacion sobre todos
    /// los platillos que el negocio tenga a la venta
    readPlatillosData();
  }

  // Para hacer read de los platillos en la bd
    Future<void> readPlatillosData() async {

      /// Primero, antes que nada, se añade una función para
      /// mostrar una barra circular de carga antes de mostrar 
      /// los pedidos en su respectiva lista de cards. Se usa
      /// "Widgets.Binding.instance.addPostFrameCallback" para
      /// asegurarse de que la función corra, inmediatamente
      /// después de que el widget sea construido/cargado
      WidgetsBinding.instance.addPostFrameCallback( (_) => showCircularProgressIndicator() );


      WidgetsFlutterBinding.ensureInitialized();

    final supabase = Supabase.instance.client;

    final dataPlatos = await supabase
                  .from('Platillo')
                  .select()
                  .eq('categoria_alimenticia', 'Seco')
                  .order('nombre', ascending: true);

    final dataPrinc = await supabase
                  .from('Platillo')
                  .select()
                  .or('categoria_alimenticia.eq.Principio, categoria_alimenticia.eq.Complemento')
                  .order('nombre', ascending: true);

    final dataComp = await supabase
                  .from('Platillo')
                  .select()
                  .or('categoria_alimenticia.eq.Bebida, categoria_alimenticia.eq.Sopa')
                  .order('categoria_alimenticia', ascending: true);
    
    setState(() {
      platillos = dataPlatos;
      principios = dataPrinc;
      complementos = dataComp;
        /// Finalmente, al final de toda la función, se hace
        /// "pop" del contexto en el que nos encontrabamos...
        /// es decir, de la barra circular de carga en la que
        /// nos encontrabamos anteriormente
        Navigator.pop( context );
    });
  }

  ///Esta es para hacer la lógica de la selección de
  ///los platillos. Si un platillo es seleccionado
  ///se añade al HashSet de platillos seleccionados
  ///pero esto, sólo, si no estaba previamente seleccionado
  void multiSeleccionarPlatillos(Map<String, dynamic> diccionarioPlatillo) {
    if (_platillosSeleccionados.contains(diccionarioPlatillo)) {
      _platillosSeleccionados.remove(diccionarioPlatillo);
    } else {
      _platillosSeleccionados.add(diccionarioPlatillo);
    }

    setState(() {
      for (var element in _platillosSeleccionados) {
        element.forEach((key, value) {
          print("El diccionario[$key] es igual a $value\n\n");
        });
      }
    });
  }

  Card platilloCard(Map<String, dynamic> diccionarioPlatillo) {
    return Card(
      elevation: 20,
      margin: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(13.0)
      ),
      color: EsquemaDeColores.secondary,
      child: Container(
        margin: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 12),
        //height: 140.0,
        child: buildPlatilloCardInnerData(diccionarioPlatillo),
      ),
    );
  }

  InkWell buildPlatilloCardInnerData(Map<String, dynamic> diccionarioPlatillo) {
    return InkWell(
      onTap: () async {
        if (!_platillosSeleccionados.contains(diccionarioPlatillo)) {
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return const SeleccionarCantidadPlatillos();
            },
          );
          diccionarioPlatillo['cantidad'] =
              ref.watch(riverpodCuantosPlatillosQuiere);
        }
        multiSeleccionarPlatillos(diccionarioPlatillo);
      },
      child: Stack(
        children: [
          Row(
            //crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(13.0),
                child: Align(
                  alignment: Alignment.center,
                  child: Image.network(
                    diccionarioPlatillo['imagen'],
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                )  
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Column(
                  //crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Ajuste aquí
                  children: <Widget>[
                    const SizedBox(height: 10),
                    Text(
                      diccionarioPlatillo['nombre'],
                      style: const TextStyle(
                        fontSize: 15,
                        color: EsquemaDeColores.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: Text(
                        diccionarioPlatillo['descripcion'],
                        style: const TextStyle(
                          fontSize: 15,
                          color: EsquemaDeColores.onPrimary,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                    children: [
                      const Text(
                        'Precio: ',
                        style: TextStyle(
                          fontSize: 15,
                          color: EsquemaDeColores.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${NumberFormat.decimalPattern("es_CO").format(diccionarioPlatillo['precio_unitario'])} COP',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: EsquemaDeColores.primary
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
          Visibility(
            visible: _platillosSeleccionados.contains(diccionarioPlatillo),
            child: const Icon(
              Icons.check_circle,
              size: 30,
              color: EsquemaDeColores.primary,
            ),
          ),
        ],
      ),
    );
  }


  void showCircularProgressIndicator() {

    showDialog(
      context: context, 
      builder: ((context) {
        
        /// Ponerle el absorbponiter permite
        /// que los taps que hayan encima de la
        /// pantalla serán absorbidos por el 
        /// AbsorbPointer en lugar de por la
        /// pantalla, lo que impide que el usuario
        /// se salga de la barra circular de 
        /// carga a propósito
        return const AbsorbPointer(
          child: Center(
            child: CircularProgressIndicator(),
          )
        );

      })
    );
  }


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            iconTheme: const IconThemeData(color: EsquemaDeColores.onPrimary),
            centerTitle: true,
            title: const Text(
              'Seleccionar Platillo',
              style: TextStyle(color: EsquemaDeColores.onPrimary),
            ),
            backgroundColor: EsquemaDeColores.primary,
            bottom: PreferredSize(
              preferredSize:
                  const Size.fromHeight(40), // Eliminar espacio adicional
              child: Container(
                color: EsquemaDeColores.primary,
                child: const TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.rice_bowl, color: EsquemaDeColores.onPrimary) ),
                    Tab(icon: Icon(Icons.local_dining, color: EsquemaDeColores.onPrimary)),
                    Tab(icon: Icon(Icons.local_drink, color: EsquemaDeColores.onPrimary)),
                  ],
                ),
              ),
            ),
          ),
          body: TabBarView(
            children: [
              _buildListView(principios, 'principios'),
              _buildListView(platillos, 'seco'),
              _buildListView(complementos, 'bebidas')
            ],
          ),
          bottomNavigationBar: Container(
            margin: const EdgeInsets.all(10),
            child: TextButton(
              onPressed: () {
                ref.read(riverpodPlatillosHashSet.notifier).state =
                    _platillosSeleccionados;

                Navigator.pop(context);
              },
              style: const ButtonStyle(
                backgroundColor:
                    MaterialStatePropertyAll(EsquemaDeColores.primary),
              ),
              child: const Text(
                'Listo',
                style: TextStyle(
                  color: EsquemaDeColores.onPrimary,
                ),
              ),
            ),
          ),
        ));
  }

  Widget _buildListView(List<Map<String, dynamic>> dataList, String filtro) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextField(
                  controller: platilloController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
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
                  onChanged: (value) {
                    if( value == '' )
                    {
                      setState(() {
                        platillosFiltrados = [];
                      });
                    }
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ElevatedButton(
                onPressed: () async {
                  final String nombre = platilloController.text.trim();
                  if (nombre == '') {
                    showCustomErrorDialog(
                        context, '¡Digite una palabra clave en el buscador!');
                    setState(() {
                      platillosFiltrados = [];
                    });
                    return;
                  }
                  List<Map<String, dynamic>> platillosConFiltros;
                  switch (filtro) {
                    case 'principios':
                      platillosConFiltros = principios.where((platillo) =>
                        platillo['nombre'].toString().toLowerCase().contains(nombre.toLowerCase())
                      ).toList();

                      if (platillosConFiltros.isEmpty) {
                        showCustomErrorDialog(context,
                            "¡No hay ningun plato que tenga en su nombre: '$nombre'!");
                        setState(() {
                          platillosFiltrados = [];
                        });
                        platilloController.clear();
                      }

                      setState(() {
                        platillosFiltrados = platillosConFiltros;
                      });
                      break;

                    case 'seco':
                      platillosConFiltros = platillos.where((platillo) =>
                        platillo['nombre'].toString().toLowerCase().contains(nombre.toLowerCase())
                      ).toList();

                      if (platillosConFiltros.isEmpty) {
                        showCustomErrorDialog(context,
                            "¡No hay ningun plato que tenga en su nombre: '$nombre'!");
                        setState(() {
                          platillosFiltrados = [];
                        });
                        platilloController.clear();
                        return;
                      }

                      setState(() {
                        platillosFiltrados = platillosConFiltros;
                      });
                      break;

                    case 'bebidas':
                      platillosConFiltros = complementos.where((platillo) =>
                        platillo['nombre'].toString().toLowerCase().contains(nombre.toLowerCase())
                      ).toList();

                      if (platillosConFiltros.isEmpty) {
                        showCustomErrorDialog(context,
                            "¡No hay ningun plato que tenga en su nombre: '$nombre'!");
                        setState(() {
                          platillosFiltrados = [];
                        });
                        platilloController.clear();
                        return;
                      }

                      setState(() {
                        platillosFiltrados = platillosConFiltros;
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
        Expanded(
          child: ListView(
            children: (platillosFiltrados.isEmpty ? dataList : platillosFiltrados)
                .map((platilloData) => platilloCard(platilloData))
                .toList(),
          ),
        ),
      ],
    );
  }
}
