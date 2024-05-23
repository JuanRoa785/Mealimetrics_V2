// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealimetrics/Pedidos/estados/cuantos_platillos_quiere.dart';
import 'package:mealimetrics/Styles/color_scheme.dart';
import 'package:mealimetrics/widgets/custom_alert.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class SeleccionarPlatillo extends ConsumerStatefulWidget {
  final int cantidad;
  const SeleccionarPlatillo({super.key, required this.cantidad});

  @override
  _SeleccionarPlatilloState createState() => _SeleccionarPlatilloState();
}

class _SeleccionarPlatilloState extends ConsumerState<SeleccionarPlatillo> with SingleTickerProviderStateMixin {
  int? cantidad;
  final TextEditingController platilloController = TextEditingController();
  List<Map<String, dynamic>> platillos = [];
  List<Map<String, dynamic>> principios = [];
  List<Map<String, dynamic>> complementos = [];
  List<Map<String, dynamic>> platillosFiltrados = [];
  final HashSet<Map<String, dynamic>> _platillosSeleccionados = HashSet();
  late TabController tabController;

  List<Map<String, dynamic>> almuerzos = [];
  String strAlmuerzos = '';

  @override
  void initState() {
    super.initState();
    cantidad = widget.cantidad;
    tabController = TabController(vsync: this, length: 3);
    tabController.addListener(handleTabChange);

    for (int i = 0; i < cantidad!; i++) {
      almuerzos.add({
        'Seco': null,
        'Principio': null,
        'Bebida': null,
        'Sopa': null,
        'Complemento': null,
      });
    }

    //Reiniciamos el String
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(almuerzosStringProvider.notifier).state = '';
    });

    /// con esta funcion vamos a la base de datos y
    /// hacemos "fetch" a la informacion sobre todos
    /// los platillos que el negocio tenga a la venta
    readPlatillosData();

    WidgetsBinding.instance.addPostFrameCallback( (_) =>

    /// vacío el hashSet. Para que el comportamiento de la 
    /// página sea congruente con el hecho de que, al volver
    /// a entrar a seleccionar platillos, los platillos que 
    /// se seleccionen de nueva cuenta, sobreescribirán los antiguamente
    /// seleccionados
    ref.read(riverpodPlatillosHashSet.notifier).state = HashSet()
    );
  }

  //Función para reiniciar los filtros al cambiar de pestaña
  void handleTabChange() {
    platilloController.clear();
    setState(() {
      platillosFiltrados = [];
    });
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

  bool generarString(){
    strAlmuerzos = ""; //Se reinicia por si acaso
    for (int i = 0; i < almuerzos.length; i++) {
      Map<String, dynamic> almuerzo = almuerzos[i];
      if (almuerzo['Seco'] == null || almuerzo['Principio'] == null || almuerzo['Bebida'] == null) {
        showCustomErrorDialog(context, 
          "!Almuerzo #${i+1} Incompleto!\n\nProteina: ${almuerzo['Seco']}\nPrincipio: ${almuerzo['Principio']}\nBebida: ${almuerzo['Bebida']}"
        );
        return false;
      }
      String almuerzoString = '- ${almuerzo['Seco']} + ${almuerzo['Principio']} + ${almuerzo['Bebida']}';
      if (almuerzo['Sopa'] != null) {
        almuerzoString += ' + ${almuerzo['Sopa']}';
      }
      if (almuerzo['Complemento'] != null) {
        almuerzoString += ' + ${almuerzo['Complemento']}';
      }
      strAlmuerzos += '$almuerzoString.\n';
    }
     strAlmuerzos = strAlmuerzos.trim();
     return true;
  }

  void multiSeleccionarPlatillos(Map<String, dynamic> diccionarioPlatillo) {
    if (_platillosSeleccionados.contains(diccionarioPlatillo)) {
      //Si ya existe aumenta la cantidad en 1
      diccionarioPlatillo['cantidad'] = (diccionarioPlatillo['cantidad'] + 1);
    } else {
      //Si no lo contiene, genera la cantidad de uno y lo agrega
      diccionarioPlatillo['cantidad'] = 1;
      _platillosSeleccionados.add(diccionarioPlatillo);
    }
    //int cant = diccionarioPlatillo['cantidad'];
    //print(diccionarioPlatillo['nombre'] + ' cantidad' + '=$cant');
  }

  void multiDeSeleccionarPlatillos(Map<String, dynamic> diccionarioPlatillo) {
    if (_platillosSeleccionados.contains(diccionarioPlatillo)) {
      //Si el diccionario lo contiene le resta la cantidad en 1
      diccionarioPlatillo['cantidad'] = (diccionarioPlatillo['cantidad'] - 1);
      
      //int cant = diccionarioPlatillo['cantidad'];
      //print(diccionarioPlatillo['nombre'] + ' cantidad' + '=$cant');
      
      if(diccionarioPlatillo['cantidad']==0){
        //Si la cantidad es 0, se elimina del diccionario (pues no se esta seleccionando)
        _platillosSeleccionados.remove(diccionarioPlatillo);
      }
    }
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
    String categoria = diccionarioPlatillo['categoria_alimenticia'];

    return InkWell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(13.0),
                child: Image.network(
                  diccionarioPlatillo['imagen'],
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 10),
                    Text(
                      diccionarioPlatillo['nombre'],
                      style: const TextStyle(
                        fontSize: 16,
                        color: EsquemaDeColores.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      diccionarioPlatillo['descripcion'],
                      style: const TextStyle(
                        fontSize: 16,
                        color: EsquemaDeColores.onPrimary,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text(
                          'Precio: ',
                          style: TextStyle(
                            fontSize: 16,
                            color: EsquemaDeColores.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$${NumberFormat.decimalPattern("es_CO").format(diccionarioPlatillo['precio_unitario'])} COP',
                          style: const TextStyle(
                            fontSize: 16,
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
          Column(
            children: List.generate(
              (cantidad! / 2).ceil(),
              (index) {
                int almuerzoIndex1 = index * 2;
                int almuerzoIndex2 = almuerzoIndex1 + 1;
                return Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Checkbox(
                            value: almuerzos[almuerzoIndex1][categoria] == diccionarioPlatillo['nombre'],
                            onChanged: (bool? value) {
                              if (almuerzos[almuerzoIndex1][categoria] != diccionarioPlatillo['nombre'] && almuerzos[almuerzoIndex1][categoria] != null) {
                                String seleccionado = almuerzos[almuerzoIndex1][categoria];
                                int indice = almuerzoIndex1 + 1;
                                showCustomErrorDialog(
                                  context, 
                                  'Ya se selecciono un platillo para esta sección: \n\nAlmuerzo #$indice\nCategoria: $categoria\nPlatillo = $seleccionado'
                                );
                                return;
                              }
                                setState(() {
                                if (value == true) {
                                  // Si el checkbox se marca, asigna el nombre del platillo al almuerzo
                                  almuerzos[almuerzoIndex1][categoria] = diccionarioPlatillo['nombre'];
                                  multiSeleccionarPlatillos(diccionarioPlatillo);
                                  //print(almuerzos[almuerzoIndex1][categoria]);
                                } else {
                                  // Si el checkbox se desmarca, asigna null al almuerzo
                                  almuerzos[almuerzoIndex1][categoria] = null;
                                 multiDeSeleccionarPlatillos(diccionarioPlatillo);
                                  //print(almuerzos[almuerzoIndex1][categoria]);
                                }
                              });
                            },
                          ),
                          Expanded(
                            child: Text('Almuerzo #${almuerzoIndex1 + 1}',
                              style: const TextStyle(
                                color: EsquemaDeColores.onPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 17
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (almuerzoIndex2 < cantidad!)
                      Expanded(
                        child: Row(
                          children: [
                            Checkbox(
                              value: almuerzos[almuerzoIndex2][categoria] == diccionarioPlatillo['nombre'],
                              onChanged: (bool? value) {
                                
                                if (almuerzos[almuerzoIndex2][categoria] != diccionarioPlatillo['nombre'] && almuerzos[almuerzoIndex2][categoria] != null) {
                                  String seleccionado = almuerzos[almuerzoIndex2][categoria];
                                  int indice = almuerzoIndex2 + 1;
                                  showCustomErrorDialog(
                                    context, 
                                    'Ya se selecciono un platillo para esta sección: \n\nAlmuerzo #$indice\nCategoria: $categoria\nPlatillo = $seleccionado'
                                  );
                                  return;
                                }

                                setState(() {
                                if (value == true) {
                                  // Si el checkbox se marca, asigna el nombre del platillo al almuerzo
                                  almuerzos[almuerzoIndex2][categoria] = diccionarioPlatillo['nombre'];
                                  multiSeleccionarPlatillos(diccionarioPlatillo);
                                  //print(almuerzos[almuerzoIndex2][categoria]);
                                } else {
                                  // Si el checkbox se desmarca, asigna null al almuerzo
                                  almuerzos[almuerzoIndex2][categoria] = null;
                                  multiDeSeleccionarPlatillos(diccionarioPlatillo);
                                  //print(almuerzos[almuerzoIndex2][categoria]);
                                }
                              });
                              },
                            ),
                            Expanded(
                              child: Text('Almuerzo #${almuerzoIndex2 + 1}',
                                style: const TextStyle(
                                  color: EsquemaDeColores.onPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17
                                ), 
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
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
              preferredSize: const Size.fromHeight(40), // Eliminar espacio adicional
              child: Container(
                color: EsquemaDeColores.primary,
                child: TabBar(
                  controller: tabController,
                  tabs: const [
                    Tab(icon: Icon(Icons.local_dining, color: EsquemaDeColores.onPrimary)),
                    Tab(icon: Icon(Icons.rice_bowl, color: EsquemaDeColores.onPrimary) ),
                    Tab(icon: Icon(Icons.local_drink, color: EsquemaDeColores.onPrimary)),
                  ],
                ),
              ),
            ),
          ),
          body: TabBarView(
            controller: tabController,
            children: [
              _buildListView(platillos, 'seco'),
              _buildListView(principios, 'principios'),
              _buildListView(complementos, 'bebidas')
            ],
          ),
          bottomNavigationBar: Container(
            margin: const EdgeInsets.all(10),
            child: TextButton(
              onPressed: () {
                if(generarString()==false){
                  return;
                }
                ref.read(riverpodPlatillosHashSet.notifier).state =
                    _platillosSeleccionados;
                ref.read(almuerzosStringProvider.notifier).state = strAlmuerzos;
                //print(strAlmuerzos);
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
        )
      ); 
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
