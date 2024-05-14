import 'dart:async';

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

  /// Debido a que este script solo debería ser alcanzable
  /// por una cuenta que sea de tipo "mesero", en esta varible
  /// se almacena el nombre del mesero que esté usando la cuenta.
  /// Revisar función obtenerNombreMesero()
  String nombreMesero = '';

  
  @override
  void initState(){

    /// Esta es la funcion que se va ejecutar cada vez que
    /// se inicialice este script. Por lo tanto, debemos 
    /// llamar, antes que nada, al constructor padre que 
    /// está construido dentro del motor, de antemano
    super.initState();

    obtenerNombreMesero();

  }

  Future<void> obtenerNombreMesero() async {
    
    /// Primero, inicializo una conexión con la base de datos
    final supabase = Supabase.instance.client;
    
    /// Tras esto, uso esa conexión para ver si hay
    /// algún usuario cuya sesión esté actualmente activa.
    /// Es decir, si hay algun empleado usando la 
    /// aplicación en este momento
    final User user = supabase.auth.currentUser!;


    /// ese usuario tiene un ID asociado. uso ese
    /// id para buscar en la tabla "empleado" al
    /// usuario con este ID asociado. Cuando lo 
    /// encuentro, obtengo el ID persona asociado
    /// a este empleado
    final idPersonaDeEmpleado = await supabase
      .from('empleado')
      .select('id_persona')
      .eq('id_user', user.id);


    /// Con este ID_persona adquirido, hago una
    /// consulta en la base de datos en la tabla
    /// "persona" para averiguar cual es el nombre
    /// del empleado que tiene su sesión actualmente
    /// activa.
    final nombreEmpleado = await supabase
      .from('persona')
      .select('nombre_completo')
      .eq('id', idPersonaDeEmpleado[0]['id_persona']);

    /// Ahora, este nombre es asignado a la variable
    /// "nombreMesero" que le pertenece a este script.
    /// De esta forma se obtiene el nombre que este tiene
    /// en todo momento
    nombreMesero = nombreEmpleado[0]['nombre_completo'];


    /// Finalmente, lo muestro con un print...
    /// porque sí. es facil de debugear
    print("\n\n======================= El usuario es: ${nombreMesero} =======================\n\n");

    

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

