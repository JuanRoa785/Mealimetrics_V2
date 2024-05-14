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

        children: ref.watch(riverpodListaPedidos).listaPedidos.map( (pedido) => pedidoCard(pedido)).toList(),

                 
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
                color: EsquemaDeColores.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> obtenerPedidosIniciales() async{

    String aux = '';

    final supabase = Supabase.instance.client;

    final listaDePedidosDeActualMesero = await supabase
      .from('Pedido')
      .select()
      .eq('id_mesero', _idMesero);


    for( var i = 0; i < listaDePedidosDeActualMesero.length; i++ ) {

      aux = '';

      print("\n\n++++++++++++++++++++++++++++ listaDePedidosActualMesero en indice $i tiene un id igual a: ${listaDePedidosDeActualMesero[i]['id']}  ++++++++++++++++++++++++++++\n\n");

      final platillosDeCadaPedido = await supabase
        .from('Relacion_Pedido_Platillo')
        .select('''
        id_platillo,
        cantidad
        ''')
        .eq('id_pedido', listaDePedidosDeActualMesero[i]['id']);


        print("\t\n\n------------------- Platillos para este pedido: $platillosDeCadaPedido ------------------- \n\n");

        for( var j = 0; j < platillosDeCadaPedido.length; j++ ){

          final nombreDeCadaPlatillo = await supabase
            .from('Platillo')
            .select('nombre')
            .eq('id', platillosDeCadaPedido[j]['id_platillo']);


          aux = '$aux${nombreDeCadaPlatillo[0]['nombre']} (X${platillosDeCadaPedido[j]['cantidad']}), ';

          print("\n~~~~~~~~~~ Nombre #${j}: ${nombreDeCadaPlatillo[0]['nombre']} con cantidad ${platillosDeCadaPedido[j]['cantidad']} ~~~~~~~~~~\n");

        }

        listaDePedidosDeActualMesero[i]['platillosListaString'] = aux;
        print('\n\Final text for pedido: $aux\n');

    }


    setState(() {

      ref.read(riverpodListaPedidos).set( listaDePedidosDeActualMesero );

    });
   
  }



  Future<void> obtenerIdMesero() async {

    final supabase = Supabase.instance.client;

    final User user = supabase.auth.currentUser!;

    setState(() {
      _idMesero = user.id;
    });

  }



}



