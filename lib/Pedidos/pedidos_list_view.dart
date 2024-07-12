// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:mealimetrics/widgets/custom_alert.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'estados\\modelo_lista_pedidos.dart';
import '..\\Styles\\color_scheme.dart';
import 'dart:async';


class PedidosListView extends ConsumerStatefulWidget{
  const PedidosListView( {super.key} );

  @override
  _PedidosListView createState() => _PedidosListView();
}

class _PedidosListView extends ConsumerState<PedidosListView>{
  final supabase = Supabase.instance.client;
  String _idMesero = '';
  final List<DropdownMenuItem<String>> _listaDeEstadosDePedido = buildListaDeEstados();
  final List<String> _listaDeMesas = ['Todas', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];
  String? _mesaSeleccionada;
  List<Map<String, dynamic>> noEmplatados = [];
  List<Map<String, dynamic>> emplatados = [];
  Timer? _timer;

  @override
  void initState(){
    super.initState();

    obtenerIdMesero();
    obtenerPedidos();
 
    _startPeriodicTask();
    _mesaSeleccionada = _listaDeMesas[0];
    //obtenerPedidosIniciales();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancelar el temporizador cuando se deshaga el widget
    super.dispose();
  }

  //Emulamos un funcionamiento en tiempo real 
  void _startPeriodicTask() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      obtenerPedidosPeriodicamente();
    });
  }

  @override
  Widget build( BuildContext context ){
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: 15.0,
          vertical: 23.0,
        ),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 const Text(
                  "Seleccionar Mesa: ",
                  style: TextStyle(
                    color: EsquemaDeColores.primary,
                    fontSize: 17,
                    fontWeight: FontWeight.bold
                    ),
                    textAlign: TextAlign.center,
                ),
                
                Center(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton2<String>(
                      items: _listaDeMesas
                          .map((mesa) => DropdownMenuItem<String>(
                                value: mesa,
                                child: Text(mesa),
                              ))
                          .toList(),
                      style: const TextStyle(
                        color: EsquemaDeColores.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                      alignment: Alignment.center,
                      value: _mesaSeleccionada,
                      onChanged: (String? value) {
                        setState(() {
                          _mesaSeleccionada = value;
                          obtenerPedidos();
                        });
                      },
                      buttonStyleData: const ButtonStyleData(
                        height: 40,
                      ),
                      iconStyleData: const IconStyleData(
                        iconSize: 20,
                        iconEnabledColor: EsquemaDeColores.primary,
                      ),
                      dropdownStyleData: DropdownStyleData(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            //...emplatados.map((pedido) => pedidoCard(pedido)),
            //...noEmplatados.map((pedido) => pedidoCard(pedido)),
            ..._cargarPedidos('emplatado'),
            ..._cargarPedidos('noEmplatado'),
        ],        
      ),
    );
  }

  List<Widget> _cargarPedidos(String tipo) {
    List<Map<String, dynamic>> pedidos;
    if(tipo == 'emplatado'){
      pedidos = emplatados;
    }
    else{
      pedidos = noEmplatados;
    }

    if (_mesaSeleccionada == 'Todas') {
      return pedidos.map((pedido) => pedidoCard(pedido)).toList();
    } else {
      List<Map<String, dynamic>> pedidosFiltrados = pedidos.where((pedido) => '${pedido['id_mesa']}' == _mesaSeleccionada.toString()).toList();
      //print('${pedidos[0]['id_mesa']} $_mesaSeleccionada');
      return pedidosFiltrados.map((pedido) => pedidoCard(pedido)).toList();
    }
  }

  //método para crear las card
  Widget pedidoCard(Map<String, dynamic> pedido){
    String aux = '${pedido["paraLlevar"]}';
    String paraLlevar = '${aux[0].toUpperCase()}${aux.substring(1)}';
    Color cardColor = pedido['estado'] == 'Emplatado' ? const Color.fromARGB(255, 255, 176, 29) : EsquemaDeColores.secondary;
    return Card(
      elevation: 20,
      margin: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
      color: cardColor,

      shape: OutlineInputBorder(
        borderRadius:  BorderRadius.circular(13.0),
        borderSide: BorderSide.none,
      ),

      child:Padding(
        
      padding: const EdgeInsets.all(12.0),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:[
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Cliente: ',
                        style: TextStyle(
                          color: EsquemaDeColores.onPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(text:" "),
                      TextSpan(
                        text: pedido["cliente"],
                        style: const TextStyle(
                          color: EsquemaDeColores.primary,
                          fontSize: 17,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 36, 
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle, 
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, size: 30.0, color:Colors.white), 
                    onPressed: () {
                      eliminarPedido(pedido);
                    },
                    padding: EdgeInsets.zero
                  ),
                ),
              ]
            ),
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: 'Mesero: ',
                    style: TextStyle(
                      color: EsquemaDeColores.onPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(text:" "),
                  TextSpan(
                    text: pedido["mesero"],
                    style: const TextStyle(
                      color: EsquemaDeColores.primary,
                      fontSize: 17,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 7.0,
            ),
            Row(
              children:[
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Mesa: ',
                        style: TextStyle(
                          color: EsquemaDeColores.onPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(text:" "),
                      TextSpan(
                        text: '${pedido["id_mesa"]}',
                        style: const TextStyle(
                          color: EsquemaDeColores.primary,
                          fontSize: 17,
                          //fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 12.0,
                ),
                const Text(
                  " - ", 
                  style: TextStyle(
                    color: EsquemaDeColores.onPrimary,
                    fontWeight: FontWeight.bold, 
                    fontSize: 16),
                ),
                const SizedBox(
                  width: 12.0,
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Para Llevar: ',
                        style: TextStyle(
                          color: EsquemaDeColores.onPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(text:" "),
                      TextSpan(
                        text: paraLlevar,
                        style: const TextStyle(
                          color: EsquemaDeColores.primary,
                          fontSize: 17,
                          //fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                ),
            ]),
            Row(
              children: <Widget>[
                const Text(
                  'Estado:',
                  style: TextStyle(
                    color: EsquemaDeColores.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16
                  ),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    items: _listaDeEstadosDePedido,
                    style: const TextStyle(
                      color: EsquemaDeColores.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 17, 
                    ),
                    alignment: Alignment.center,
                    value: pedido['estado'],
                    onChanged: (String? value) async {
                      final supabase =  Supabase.instance.client;

                      try{
                        await supabase
                        .from('Pedido')
                        .update({ 'estado': value })
                        .match({'id': pedido['id']});
                      }
                      catch (e){
                        showCustomErrorDialog(
                          context, 
                          e.toString()
                        );
                        return;
                      }

                      if (value == 'Servido') {
                        try{
                          await supabase
                          .from('Pedido')
                          .update({ 'tiempoPreparacion': calcularDiferenciaPedido(pedido) })
                          .match({'id': pedido['id']});
                        }
                        catch (e){
                          showCustomErrorDialog(
                            context, 
                            e.toString()
                          );
                          return;
                        }
                      }

                      if (value == 'Pagado') {
                        String fechaActual = '${DateTime.now()}';
                        List partesFecha = fechaActual.split(".");
                        try {
                          await supabase.from('Pedido').
                          update({
                            'fecha_pagado': '${partesFecha[0]}'
                          })
                          .match({'id': pedido['id']});
                        } catch (e) {
                          showCustomErrorDialog(context, e.toString());
                          return;
                        }
                      }

                      setState(() {
                        obtenerPedidos();
                        /*ref.watch(riverpodListaPedidos).cambiarEstadoPorId(pedido['id'], value!);
                        if( value == 'Pagado'){
                          ref.watch(riverpodListaPedidos).elimiarPedidoPorId(pedido['id']);
                        }*/
                      });
                    },
                    buttonStyleData: const ButtonStyleData(
                      height: 40,
                    ),
                    iconStyleData: const IconStyleData(
                      iconSize: 20,
                      iconEnabledColor: EsquemaDeColores.onPrimary,
                    ),
                    dropdownStyleData:DropdownStyleData(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    )
                  ),
                )
              ]
            ),
            const Text(
              'Almuerzos:',
              style: TextStyle(
                color: EsquemaDeColores.primary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${pedido["string_pedido"].replaceAll('/n', '\n')}',
              style: const TextStyle(
                color: EsquemaDeColores.onPrimary,
                fontSize: 16, 
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(
              height: 7.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Precio Total: ',
                        style: TextStyle(
                          color: EsquemaDeColores.onPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(text:" "),
                      TextSpan(
                        text: '\$${NumberFormat.decimalPattern("es_CO").format( pedido['precioTotal'] )} COP' ,
                        style: const TextStyle(
                          color: EsquemaDeColores.primary,
                          fontSize: 18,
                          //fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> eliminarPedido(Map<String, dynamic> pedido) async {
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
              "Eliminar este pedido es irreversible y su información no podrá ser recuperada.",
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
                //Eliminamos el pedido
                try {
                  await supabase
                    .from('Pedido')
                    .delete()
                    .match({ 'id': pedido['id'] });
                } catch (e) {
                  showCustomErrorDialog(context, e.toString());
                  return;
                }
                Navigator.of(context).pop();
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
                'Volver Atrás',
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

  String calcularDiferenciaPedido( Map<String, dynamic> pedido ){
    DateTime fechaActual = DateTime.now();
    String fechaCreacionStr = pedido['created_at'];
    DateTime fechaCreacion = DateTime.parse(fechaCreacionStr);
    
    // Extraer horas, minutos y segundos de las fechas
    int horaActual = fechaActual.hour;
    int minutoActual = fechaActual.minute;
    int segundoActual = fechaActual.second;
    int horaCreacion = fechaCreacion.hour;
    int minutoCreacion = fechaCreacion.minute;
    int segundoCreacion = fechaCreacion.second;
    
    // Calcular la diferencia de tiempo en horas, minutos y segundos
    int diferenciaHoras = horaActual - horaCreacion;
    int diferenciaMinutos = minutoActual - minutoCreacion;
    int diferenciaSegundos = segundoActual - segundoCreacion;
    
    // Ajustar la diferencia si los segundos son negativos
    if (diferenciaSegundos < 0) {
      diferenciaMinutos--;
      diferenciaSegundos += 60;
    }
    // Ajustar la diferencia si los minutos son negativos
    if (diferenciaMinutos < 0) {
      diferenciaHoras--;
      diferenciaMinutos += 60;
    }
    
    //print('Diferencia: $diferenciaHoras horas, $diferenciaMinutos minutos, $diferenciaSegundos segundos');
    //print('$diferenciaHoras:$diferenciaMinutos:$diferenciaSegundos');
    return '$diferenciaHoras:$diferenciaMinutos:$diferenciaSegundos';
  }

  Future<void> obtenerPedidos() async {
    WidgetsBinding.instance.addPostFrameCallback( (_) => showCircularProgressIndicator() );
    final supabase = Supabase.instance.client;

    final pedidosNoEmplatados = await supabase
      .from('Pedido')
      .select()
      .eq('id_mesero', _idMesero)
      .neq('estado', 'Emplatado')
      .neq('estado', 'Pagado')
      .order('created_at', ascending: true);

    final pedidosEmplatados = await supabase
      .from('Pedido')
      .select()
      .eq('id_mesero', _idMesero)
      .eq('estado', 'Emplatado')
      .order('created_at', ascending: true);

    setState(() {
      noEmplatados = pedidosNoEmplatados;
      emplatados = pedidosEmplatados;
    });
  
    //print(pedidosNoEmplatados.length);
    //print(pedidosEmplatados.length);
    Navigator.pop( context );
  }

  void obtenerPedidosPeriodicamente() async {
    final supabase = Supabase.instance.client;
    
    final pedidosNoEmplatados = await supabase
      .from('Pedido')
      .select()
      .eq('id_mesero', _idMesero)
      .neq('estado', 'Emplatado')
      .neq('estado', 'Pagado')
      .order('created_at', ascending: true);

    final pedidosEmplatados = await supabase
      .from('Pedido')
      .select()
      .eq('id_mesero', _idMesero)
      .eq('estado', 'Emplatado')
      .order('created_at', ascending: true);

    if(pedidosEmplatados.length != emplatados.length || pedidosNoEmplatados.length != noEmplatados.length){
      setState(() {
        noEmplatados = pedidosNoEmplatados;
        emplatados = pedidosEmplatados;
      });
    }
  }

  Future<void> obtenerPedidosIniciales() async {
    /// Primero, antes que nada, se añade una función para
    /// mostrar una barra circular de carga antes de mostrar 
    /// los pedidos en su respectiva lista de cards. Se usa
    /// "Widgets.Binding.instance.addPostFrameCallback" para
    /// asegurarse de que la función corra, inmediatamente
    /// después de que el widget sea construido/cargado
    WidgetsBinding.instance.addPostFrameCallback( (_) => showCircularProgressIndicator() );

    ///En esta variable se va a almacenar el string
    ///final que se va a poner en las cards de la aplicación.
    String aux = '';

    /// Primero, nos conectamos a la base de datos
    final supabase = Supabase.instance.client;

    /// Luego, se obtienen todas las columnas de la 
    /// tabla "Pedido" que le pertenezcan al mesero
    /// cuya sesión actual esté iniciada y conectada
    /// en el celular. Esto se encuentra a través del
    /// id del mesero
    final listaDePedidosDeActualMesero = await supabase
      .from('Pedido')
      .select()
      .eq('id_mesero', _idMesero)
      .neq('estado', 'Pagado');

    /// Ahora, vamos a recorrer todos estos pedidos 
    /// para sacar información de ellos
    for( var i = 0; i < listaDePedidosDeActualMesero.length; i++ ) {

      /// Se vacía el string para que se pueda reutilizar
      /// para el siguiente pedido
      aux = '';

      //print("\n\n++++++++++++++++++++++++++++ listaDePedidosActualMesero en indice $i tiene un estado igual a: ${listaDePedidosDeActualMesero[i]['estado']}  ++++++++++++++++++++++++++++\n\n");

      /// Para cada pedido, encontramos los platillos
      /// que se pidieron para ese pedido. Para esto
      /// para cada uno de los pedidos, lo buscamos
      /// en la tabla relacional que relaciona los
      /// pedidos con los platillos que se pidieron
      /// y se saca su id (para averiguar el nombre)
      /// y su cantidad.
      /// 
      /// EJEMPLO: Si en un pedido se pidieron una
      /// hamburguesa y un jugo, se consigue el id
      /// del pedido y, usando este, se buscan
      /// los platillos en la talba "Relacion_Pedido_Platillo"
      /// Pedido: ID = 1    ------> Platillos: id_1 =2 y id_2 = 3
      /// Pedido: ID = 1   -------> Cantidades:  id_1: cantidad = 1 id_2: cantidad= 2
      /// 
      final platillosDeCadaPedido = await supabase
        .from('Relacion_Pedido_Platillo')
        .select('''
        id_platillo,
        cantidad
        ''')
        .eq('id_pedido', listaDePedidosDeActualMesero[i]['id']);


        //print("\t\n\n------------------- Platillos para este pedido: $platillosDeCadaPedido ------------------- \n\n");


        /// Para cada uno de esos platillos se encuentra el nombre
        /// Esto se hace con una consulta a la tabla "Platillo" usando
        /// el id de cada platillo que compone el pedido
        for( var j = 0; j < platillosDeCadaPedido.length; j++ ){

          /// Se hace la consulta
          final nombreDeCadaPlatillo = await supabase
            .from('Platillo')
            .select('nombre')
            .eq('id', platillosDeCadaPedido[j]['id_platillo']);

          /// Se compone el string del nombre del platillo
          /// y la cantidad de este platillo, para cada uno
          /// de los platillos que componen el pedido:
          /// Ejemplo: HamburguesaClasica (X3), Jugo de Mora (X8),
          aux = '$aux${nombreDeCadaPlatillo[0]['nombre']} (X${platillosDeCadaPedido[j]['cantidad']}), ';

          //print("\n~~~~~~~~~~ Nombre #${j}: ${nombreDeCadaPlatillo[0]['nombre']} con cantidad ${platillosDeCadaPedido[j]['cantidad']} ~~~~~~~~~~\n");
        }

        aux = aux.substring(0, aux.length - 2);
        
        /// Se hace la asignación a una clave en la lista 
        /// de pedidos (estos pedidos son diccionarios).
        listaDePedidosDeActualMesero[i]['platillosListaString'] = aux;

        //print('\n\Final text for pedido: $aux\n');
    }

    setState(() {
      /// Finalmente, con la clave "platillosListaString"
      /// ya asignada al diccionario que contiene la información
      /// sobre cada pedido, se hace la asignación al riverpodListaPedidos
      ref.read(riverpodListaPedidos).set( listaDePedidosDeActualMesero );

      /// Finalmente, al final de toda la función, se hace
      /// "pop" del contexto en el que nos encontrabamos...
      /// es decir, de la barra circular de carga en la que
      /// nos encontrabamos anteriormente
      Navigator.pop( context );
    });
  }

  Future<void> obtenerIdMesero() async {
    final supabase = Supabase.instance.client;

    final User user = supabase.auth.currentUser!;

    setState(() {
      _idMesero = user.id;
    });
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
}

/// ====================================================================================
/// ====================================================================================

List<DropdownMenuItem<String>> buildListaDeEstados(){
    List<String> listaDeEstados = ['Ordenado', 'Emplatado', 'Servido', 'Pagado'];
    List<DropdownMenuItem<String>> retorno = [];

    for( var i = 0; i < listaDeEstados.length; i++ ){

      retorno.add(
        DropdownMenuItem(
          value: listaDeEstados[i],
          child: Text(listaDeEstados[i]),
        )
      );
    }
    return retorno;
  }