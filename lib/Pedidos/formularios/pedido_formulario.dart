import 'dart:collection';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealimetrics/Pedidos/estados/cuantos_platillos_quiere.dart';
import 'package:mealimetrics/Pedidos/estados/modelo_lista_pedidos.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '..\\..\\Styles\\color_scheme.dart';
import 'package:dropdown_button2/dropdown_button2.dart';


class PedidoFormulario extends ConsumerStatefulWidget {
  const PedidoFormulario( {super.key} );

  @override
  _PedidoFormularioState createState() => _PedidoFormularioState();
}

class _PedidoFormularioState extends ConsumerState<PedidoFormulario> {

  String _cliente = '';
  String _mesero = '';
  int? _mesa;
  List<DropdownMenuItem<int>> _tableDropDownMenuItems = [];
  bool? _paraLlevar;
  final List<DropdownMenuItem<bool>> _paraLlevarDropDownMenuItems = buildListaParaLlevar();

  @override
  void initState(){
    initialiceTableDropDownItems();
    super.initState();
  }


  @override
  Widget build( BuildContext context ){

    return Scaffold(

      body: ListView(

        padding: const EdgeInsets.symmetric(

          horizontal: 30.0,
          vertical: 15.0,

        ),

        children:  [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget> [
            
              const Text(

                'Nuevo Pedido',
                style: TextStyle(
                  fontSize: 25,
                  color: EsquemaDeColores.primary,
                  fontWeight: FontWeight.bold,
                ),

              ),
            
              const SizedBox(
                width: 300.0,
                height: 50.0,
                child: Divider(
                  color: EsquemaDeColores.onBackground,
                ),
              ),

              TextField(
                enableInteractiveSelection: false,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                                
                decoration: InputDecoration(
                  hintText: 'Cliente',
                  labelText: 'Nombre del Cliente',
                  suffixIcon: const Icon( 
                    Icons.person,
                    color: EsquemaDeColores.secondary,
                    ),
                  border: OutlineInputBorder(
                    borderRadius:  BorderRadius.circular(13.0),
                  ),
                ),

                onChanged: (cliente){
                  _cliente = cliente;
                  print("El nombre del cliente es: $_cliente");
                },
              ),

              const SizedBox(
                height: 15.0,
              ),

              TextField(
                enableInteractiveSelection: false,
                textCapitalization: TextCapitalization.sentences,
                autofocus: true,
                                
                decoration: InputDecoration(
                  hintText: 'Mesero',
                  labelText: 'Nombre del Mesero',
                  suffixIcon: const Icon( 
                    Icons.person,
                    color: EsquemaDeColores.secondary,
                    ),
                  border: OutlineInputBorder(
                    borderRadius:  BorderRadius.circular(13.0),
                  ),
                ),

                onChanged: (mesero){
                  _mesero = mesero;
                  print("El nombre del mesero es: $_mesero");
                },
              ),

              
              const SizedBox(
                height: 15.0,
              ),

              DropdownButtonFormField2(
                items: _tableDropDownMenuItems,	
                iconStyleData: const IconStyleData(
                  icon: Icon(Icons.table_bar),
                  iconEnabledColor: EsquemaDeColores.secondary,
                ),
                
                decoration: InputDecoration(
                  hintText: 'Mesa',
                  labelText: 'Número de la mesa',
                  border: OutlineInputBorder(
                    borderRadius:  BorderRadius.circular(13.0),
                  ),
                ),

                onChanged: (mesa){
                  _mesa = mesa;
                  print('La mesa es: $_mesa');
                },
              ),
              
              const SizedBox(
                height: 15.0,
              ),

              DropdownButtonFormField2(
                items: _paraLlevarDropDownMenuItems,	
                iconStyleData: const IconStyleData(
                  icon: Icon(Icons.pedal_bike),
                  iconEnabledColor: EsquemaDeColores.secondary,
                ),
                hint: const Text('¿Es para llevar?'),
                decoration: InputDecoration(
                  hintText: '¿Para Llevar?',
                  labelText: '¿Es para llevar?',
                  border: OutlineInputBorder(
                    borderRadius:  BorderRadius.circular(13.0),
                  ),
                ),

                onChanged: (paraLlevar){
                  _paraLlevar = paraLlevar;
                  print('El pedido es para llevar?: $_paraLlevar');
                },

              ),
              
              const SizedBox(
                height: 15.0,
              ),

              Stack(
                children: <Widget>[
                  SizedBox(
                    width: double.maxFinite, // Set the desired width
                    height: 50.0, // Set the desired height
                    child: ElevatedButton(

                      style: const ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(EsquemaDeColores.primary),
                      ),

                      onPressed: () {
                        // Button onPressed action
                        Navigator.pushNamed(context, '/SeleccionarPlatillo');
                      },
                      child: const Text(
                        'Seleccionar Platillo',
                        style: TextStyle(
                          fontSize: 17,
                          color: EsquemaDeColores.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  Visibility(
                    visible: ref.watch(riverpodPlatillosHashSet).isNotEmpty,   
                                 
                    child: Positioned.fill(

                      child: Align(
                        alignment: Alignment.centerLeft,
                        
                        child: Container(
                          margin: const EdgeInsets.only( left: 10 ),
                          child: const  Icon(
                            Icons.check_circle,
                            
                            size: 30,
                            color: EsquemaDeColores.secondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 15.0,
              ),

              Visibility(
                visible: ref.watch(riverpodPlatillosHashSet).isNotEmpty,                
                child: Text(
                  toStringPlatillos(ref.watch(riverpodPlatillosHashSet)),
                ),
              ),

              const SizedBox(
                height: 15.0,
              ),

              TextButton(
                
                onPressed: () async {
                  
                  final supabase = Supabase.instance.client;

                  Map<String, dynamic> diccionarioPedido = {
                  'cliente': _cliente,
                  'mesero': _mesero,
                  'mesa': _mesa,
                  'paraLlevar': _paraLlevar,
                  'platillosListaString': toStringPlatillos(ref.watch(riverpodPlatillosHashSet)),
                  };

                  final manualId = createRandomString(20);

                  await supabase
                    .from('Pedido')
                    .insert({
                      'cliente': diccionarioPedido['cliente'],
                      'fecha_pagado':  ( DateTime.timestamp().toIso8601String() ),
                      'tiempoPreparacion': '15 min',
                      'mesero': diccionarioPedido['mesero'],
                      'id_mesa': diccionarioPedido['mesa'],
                      'paraLlevar': diccionarioPedido['paraLlevar'],
                      'identificador_manual': manualId,
                  });


                  final dataPedidoId = await supabase
                    .from('Pedido')
                    .select('id')
                    .eq('identificador_manual', manualId)
                  ;


                  relacionarPedidoPlatillo( dataPedidoId[0]['id']  , ref.watch(riverpodPlatillosHashSet) );

                  //const meter a gregar a diccionario;
                  ref.read(riverpodListaPedidos).addDictionary( diccionarioPedido );


                  ref.read(riverpodPlatillosHashSet.notifier).state = HashSet();
                  Navigator.pop(context);
                },
                
                
                style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(EsquemaDeColores.secondary),
                  padding: MaterialStatePropertyAll( EdgeInsets.all(15) ),
                ),
                

                child: const Text(
                  'Crear Pedido',
                  style: TextStyle(
                    fontSize: 20,
                    color: EsquemaDeColores.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              
            ],
          ),
        ],

      ),

    );

  }


  Future<void> initialiceTableDropDownItems() async {

    WidgetsFlutterBinding.ensureInitialized();

    final supabase = Supabase.instance.client;

    final List<DropdownMenuItem<int>> mesaItems = [];

    final mesaData = await supabase
      .from('Mesa')
      .select('id');

    for( var i = 0; i < mesaData.length; i++ )
    {
        print('\n++++++++++++++++++++++++mesaData[$i][id] = ${mesaData[i]['id']}++++++++++++++++++++++++\n');
        mesaItems.add(
        DropdownMenuItem(
          value: mesaData[i]['id'],
          child: Text('Mesa ${mesaData[i]['id']}'.toString()),
        ),
      );

    }

    print('mesaItems es: $mesaItems');

    setState(() {
      _tableDropDownMenuItems = mesaItems;
    });

  } 


}


List<DropdownMenuItem<bool>> buildListaParaLlevar() {
  return const [
    DropdownMenuItem(
      value: true,
      child: Text('Sí'),
    ),
    DropdownMenuItem(
      value: false,
      child: Text('No'),
    ),
  ];
}

String toStringPlatillos(HashSet<Map<String,dynamic>> hashSetDePlatillos ){
  String aux = '';

  
    for (var element in hashSetDePlatillos) {
        aux = aux + '${element['nombre']} (X${element['cantidad']}), '.toString();
       }

    return aux;
}

String createRandomString(int length) {
  var randomizer = Random();
  String randomString = String.fromCharCodes(List.generate(length, (i)=> randomizer.nextInt(33) + 89));
    return randomString;
}

Future<void> relacionarPedidoPlatillo( int idPedido, HashSet<Map<String, dynamic>> diccionarioIdPlatillos ) async {
  final supabase = Supabase.instance.client;
  
  diccionarioIdPlatillos.forEach(
    (element) async { 
       await supabase
        .from('Relacion_Pedido_Platillo')
        .insert({
          'id_pedido': idPedido,
          'id_platillo': element['id'],
        })
      ;
    }
  );
}