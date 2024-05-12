import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pedidos_list_view.dart';

class PedidosMain extends ConsumerWidget {
  // Crear una lista vacía de objetos de tipo diccionario
  static int valorMesa = 1;
  
  const PedidosMain( {super.key} );
  
  @override
  Widget build(BuildContext context, WidgetRef ref ) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: const Center(
        child: PedidosListView(),
      ),

      floatingActionButton: FloatingActionButton(
          onPressed: () {
            //Redirigir al formulario para crear un pedido
            //==========================OLD WAY===================================
            // Navigator.push(
            //   context, 
            //   MaterialPageRoute(
            //     builder: (context) => const SeleccionarPedido(),
            //     )
            // );
            //=============================================================
            Navigator.pushNamed(context, '/SeleccionarPedido');
          },
          
          backgroundColor: Colors.red, // Color de fondo del botón flotante
          child: const Icon(Icons.add), // Icono de la cruz
        ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // Ubicación en la parte inferior derecha

    );
  }

}