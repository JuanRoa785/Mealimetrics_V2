import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'estados\\modelo_lista_pedidos.dart';
import '..\\Styles\\color_scheme.dart';


class PedidosListView extends ConsumerStatefulWidget{
  const PedidosListView( {super.key} );

  @override
  _PedidosListView createState() => _PedidosListView();
}

class _PedidosListView extends ConsumerState<PedidosListView>{

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
              'Mesa: ${pedido["mesa"]}',
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
            Text(
              'Platillos: ${pedido['platillosListaString']}',
              style: const TextStyle(
                color: EsquemaDeColores.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
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
}

