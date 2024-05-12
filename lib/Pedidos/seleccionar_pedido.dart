import 'package:flutter/material.dart';
import '..\\Styles\\color_scheme.dart';
import 'formularios\\pedido_formulario.dart';

class SeleccionarPedido extends StatelessWidget {
  const SeleccionarPedido( {super.key} );
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        title: const Text(
            'Tomar Pedido',
            style: TextStyle( color: EsquemaDeColores.onPrimary),
          ),

        backgroundColor: EsquemaDeColores.primary,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: PedidoFormulario(), // Mostrar el formulario de pedidos
      ),
    );
  }
}
