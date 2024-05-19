import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'estados\\modelo_lista_pedidos.dart';
import '..\\Styles\\color_scheme.dart';


class PedidosListView extends ConsumerStatefulWidget{
  const PedidosListView( {super.key} );

  @override
  _PedidosListView createState() => _PedidosListView();
}

class _PedidosListView extends ConsumerState<PedidosListView>{

  String _idMesero = '';
  final List<DropdownMenuItem<String>> _listaDeEstadosDePedido = buildListaDeEstados();

  @override
  void initState(){
    super.initState();

    obtenerIdMesero();

    obtenerPedidosIniciales();

  }


  @override
  Widget build( BuildContext context ){
    return Scaffold(
      body: ListView(

        padding: const EdgeInsets.symmetric(
          horizontal: 15.0,
          vertical: 23.0,
        ),

        children: ref.watch(riverpodListaPedidos).listaPedidos.map( (pedido) => pedidoCard(pedido) ).toList(),
        

                 
      ),
    );
  }



  //método para crear las card
  Widget pedidoCard( Map<String, dynamic> pedido ){
    return Card(

      elevation: 20,
      margin: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
      color: EsquemaDeColores.secondary,

      shape: OutlineInputBorder(
        borderRadius:  BorderRadius.circular(13.0),
        borderSide: BorderSide.none,
      ),


      child:Padding(
        
        padding: const EdgeInsets.all(12.0),


        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Cliente: ${pedido["cliente"]}',
              style: const TextStyle(
                color: EsquemaDeColores.onPrimary,
              ),
            ),
            const SizedBox(
              height: 5.0,
            ),
            Text(
              'Mesero: ${pedido["mesero"]}',
              style: const TextStyle(
                color: EsquemaDeColores.onPrimary,
              ),
            ),
            const SizedBox(
              height: 5.0,
            ),
            Text(
              'Mesa: ${pedido["id_mesa"]}',
              style: const TextStyle(
                color: EsquemaDeColores.onPrimary,
              ),
            ),
            const SizedBox(
              height: 5.0,
            ),
            Text(
              'Para Llevar: ${pedido["paraLlevar"]}',
              style: const TextStyle(
                color: EsquemaDeColores.onPrimary,
              ),
            ),
            const SizedBox(
              height: 5.0,
            ),
            Row(
              children: <Widget>[
                const Text(
                  'Estado:',
                  style: TextStyle(
                    color: EsquemaDeColores.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                DropdownButton2<String>(
                  items: _listaDeEstadosDePedido,
                  value: pedido['estado'],
                  onChanged: (String? value){
                    setState(() async {

                      ref.watch(riverpodListaPedidos).cambiarEstadoPorId(pedido['id'], value!);


                      

                      print("\n\n\n\n\n===========Pedido cambiado: ${ref.read(riverpodListaPedidos).listaPedidos}===========\n\n\n\n\n");
                    });
                  },
                  
                ),
              ]
            ),
            const SizedBox(
              height: 5.0,
            ),
            Text(
              'Platillos: ${pedido['platillosListaString']}',
              style: const TextStyle(
                color: EsquemaDeColores.onPrimary,
              ),
            ),
            const SizedBox(
              height: 5.0,
            ),
            Text(
              'Precio Total: \$${NumberFormat.decimalPattern("es_CO").format( pedido['precioTotal'] )} COP ',
              style: const TextStyle(
                color: EsquemaDeColores.primary,
                fontWeight: FontWeight.bold,
                fontSize: 15
              ),
            ),
          ],
        ),
      ),
    );
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

      print("\n\n++++++++++++++++++++++++++++ listaDePedidosActualMesero en indice $i tiene un estado igual a: ${listaDePedidosDeActualMesero[i]['estado']}  ++++++++++++++++++++++++++++\n\n");

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


        print("\t\n\n------------------- Platillos para este pedido: $platillosDeCadaPedido ------------------- \n\n");


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

          print("\n~~~~~~~~~~ Nombre #${j}: ${nombreDeCadaPlatillo[0]['nombre']} con cantidad ${platillosDeCadaPedido[j]['cantidad']} ~~~~~~~~~~\n");

        }

        aux = aux.substring(0, aux.length - 2);
        
        /// Se hace la asignación a una clave en la lista 
        /// de pedidos (estos pedidos son diccionarios).
        listaDePedidosDeActualMesero[i]['platillosListaString'] = aux;

        print('\n\Final text for pedido: $aux\n');

      
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
    List<String> listaDeEstados = ['Ordenado', 'Preparándose', 'Servido', 'Pagado'];
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




