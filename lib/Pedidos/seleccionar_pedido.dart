import 'package:flutter/material.dart';
import 'package:mealimetrics/pages/home_mesero.dart';
import 'package:mealimetrics/styles/color_scheme.dart';
import 'formularios\\pedido_formulario.dart';

class SeleccionarPedido extends StatelessWidget {
  const SeleccionarPedido( {super.key} );
  
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        
        centerTitle: true,

        iconTheme: const IconThemeData(
          color: EsquemaDeColores.onPrimary
        ),
        
        title: const Text(
          'Tomar Pedido',
          style: TextStyle( color: EsquemaDeColores.onPrimary),
        ),

        backgroundColor: EsquemaDeColores.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeMesero()),
            );
          },
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: PedidoFormulario(), // Mostrar el formulario de pedidos
      ),
    );
  }
}
