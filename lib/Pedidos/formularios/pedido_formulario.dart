import 'dart:collection';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealimetrics/Pedidos/estados/cuantos_platillos_quiere.dart';
import 'package:mealimetrics/Pedidos/estados/modelo_lista_pedidos.dart';
import 'package:mealimetrics/widgets/custom_alert.dart';
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

    obtenerNombreMesero();

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
                enabled: false,
                readOnly: true,
                textCapitalization: TextCapitalization.sentences,
                autofocus: true,
                                
                decoration: InputDecoration(
                  hintText: _mesero,
                  labelText: _mesero,
                  suffixIcon: const Icon( 
                    Icons.person,

                    color: EsquemaDeColores.secondary,
                    ),
                  border: OutlineInputBorder(
                    borderRadius:  BorderRadius.circular(13.0),
                  ),
                ),

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
                  
                  try{
                    verifyFormVariables();
                  }
                  on Exception catch (e) {
                    showCustomErrorDialog(
                      context, 
                      'Por favor, rellene todos los campos del formulario. Campos faltantes: ${e.mensaje}'
                    );

                    return;
                  }

                  /// Primero, establecemos la conexión con
                  /// la base de datos
                  final supabase = Supabase.instance.client;

                  /// Luego, se crea el id manual para poder
                  /// obtener los datos que se subieron
                  /// a la base de datos, después de haberlos 
                  /// subidos. Esto es así porque necesito que 
                  /// la base de datos le asigne automaticamente
                  /// el id y, luego, con este yo puedo crear
                  /// la relacion entre tabla pedido y platillos
                  final manualId = createRandomString(20);

                  
                  /// Creo el diccionario que va a servir
                  /// para subir los datos a la base de datos
                  /// y, tambien, para añadirlo al riverpodListaPedidos
                  Map<String, dynamic> diccionarioPedido = {
                    'cliente': _cliente,
                    'fecha_pagado':  ( DateTime.timestamp().toIso8601String() ),
                    'tiempoPreparacion': '15 min',
                    'mesero': _mesero,
                    'id_mesa': _mesa,
                    'paraLlevar': _paraLlevar,
                    'identificador_manual': manualId,
                    'precioTotal': calcularPrecioTotalPedido( ref.watch(riverpodPlatillosHashSet) ),
                    'id_mesero': supabase.auth.currentUser!.id,
                  };




                  /// Subo el diccionario anteriormente creado
                  /// a la base de datos
                  await supabase
                    .from('Pedido')
                    .insert( diccionarioPedido );

                  


                  /// Consigo el todas las columnas del pedido
                  /// recientemente subido a la base de datos
                  final dataPedido = await supabase
                    .from('Pedido')
                    .select()
                    .eq('identificador_manual', manualId)
                  ;

                  /// Relaciono el pedido con los platillos que 
                  /// se hayan ordenado, usando el id del pedido
                  relacionarPedidoPlatillo( dataPedido[0]['id'] , ref.watch(riverpodPlatillosHashSet)  );



                  /// Ahora, ese diccionario que creamos hace un
                  /// momento, se va a reemplazar por lo que sea
                  /// que hayamos guardado en la base de datos. Esto
                  /// porque hay variables que nos faltan y que
                  /// asigna la base de datos automaticamente
                  diccionarioPedido = dataPedido[0];

                
                  /// Ahora, ese diccionario que creamos hace un 
                  /// instante, lo vamos a meter en el riverpodListPedidos
                  /// PERO, antes se debe añadir una cosita que nos permite
                  /// mostrar en forma de string los platillos que se 
                  /// pidieron en este pedido. Este string se guardará en
                  /// la key 
                  diccionarioPedido['platillosListaString'] = toStringPlatillos( ref.watch(riverpodPlatillosHashSet) );



                  /// Ahora, sí vamos a insertar ese diccionario
                  /// dentro del riverpod
                  ref.read(riverpodListaPedidos).addDictionary( diccionarioPedido );



                  /// Imprimimos la variable para ver si todo bien
                 for( var i = 0; i < ref.watch(riverpodListaPedidos).listaPedidos.length; i++ )
                  {
                    print("\n\n================= riverpodListPedidos en indice $i es: ${ref.watch(riverpodListaPedidos).listaPedidos[i]} ================= \n\n");
                  }


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

    /// Primero, nos conectamos con la base de datos
    final supabase = Supabase.instance.client;


    /// Luego, creamos una lista que va a almacenar
    /// los dropdowmMenuItems que se crearan con el 
    /// id de las mesas que NO se encuentren ocupadas.
    final List<DropdownMenuItem<int>> mesaItems = [];


    /// Para obtener, unicamente, las mesas que no 
    /// se encuentren ocupadas, se hace una consulta
    /// a la base de datos que le pregunta a la 
    /// tabla "Mesa" por la columna "id" de aquellas
    /// mesas cuya columna "esta_ocupada" sea igual a 
    /// false
    final mesaData = await supabase
      .from('Mesa')
      .select('id')
      .eq('esta_ocupada', false);



    /// Tras esto, creamos una lista simple
    /// que se va a usar unicamente para
    /// ordenar los id de las mesas que no
    /// esten ocupadas de manera ascendente
    List listaDeIdDeMesa = [];



    /// Asignamos cada uno de los id a
    /// una posicion en la lista anteriormente
    /// creada
    for( var i = 0; i < mesaData.length; i++ )
    {
      listaDeIdDeMesa.add( mesaData[i]['id'] );
    }




    /// Luego, hacemos sort a la lista
    listaDeIdDeMesa.sort();

    for( var i = 0; i < listaDeIdDeMesa.length; i++ )
    {
      
      print('\n++++++++++++++++++++++++mesaData[$i][id] = ${mesaData[i]['id']}++++++++++++++++++++++++\n');
      
      /// Finalmente, añadimos secuencialmente o 
      /// consecutivamente a la lista de  dropdownmenuitem
      /// los elementos que se encuentren dentro de la
      /// lista que ordenamos ascendentemenete. De esta
      /// forma, siempre se desplegarán los elementos
      /// ordenados de manera ascendente
      mesaItems.add(
        DropdownMenuItem(
          value: listaDeIdDeMesa[i],
          child: Text('Mesa ${listaDeIdDeMesa[i]}'.toString()),
        ),
      );
    }

    print('mesaItems es: $mesaItems');

    setState(() {
      _tableDropDownMenuItems = mesaItems;
    });

  } 

    /// Debido a que este script solo debería ser alcanzable
  /// por una cuenta que sea de tipo "mesero", en esta varible
  /// se almacena el nombre del mesero que esté usando la cuenta.
  /// Revisar función obtenerNombreMesero()
  String nombreMesero = '';

  
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



    setState(() {
      /// Ahora, este nombre es asignado a la variable
      /// "nombreMesero" que le pertenece a este script.
      /// De esta forma se obtiene el nombre que este tiene
      /// en todo momento
      _mesero = nombreEmpleado[0]['nombre_completo'];
    });
    /// Finalmente, lo muestro con un print...
    /// porque sí. es facil de debugear
    print("\n\n======================= El mesero es: ${_mesero} =======================\n\n");

    

  }

  verifyFormVariables(){

    bool aValueIsMissing = false;
    String mensaje = '';

    if( _cliente == '' )
    {
      aValueIsMissing = true;
      mensaje = '${mensaje}Nombre del cliente - ';
    }
    if( _mesero == '' )
    {
      aValueIsMissing = true;
      mensaje = '${mensaje}Nombre del mesero - ';
    }
    if( _mesa == null )
    {
      aValueIsMissing = true;
      mensaje = '${mensaje}Número de la mesa - ';
    }
    if( _paraLlevar == null )
    {
      aValueIsMissing = true;
      mensaje = '$mensaje¿El platillo es para llevar? - ';
    }
    else if( ref.watch(riverpodPlatillosHashSet).isEmpty ){
      aValueIsMissing = true;
      mensaje = '${mensaje}No ha seleccionado ningún pedido - ';
    }

    mensaje = mensaje.substring(0, mensaje.length - 3);

    if( aValueIsMissing ){
      throw  AValuesIsMissingException(mensaje);
    }

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

  
  for(var element in hashSetDePlatillos) {
    aux = aux + '${element['nombre']} (X${element['cantidad']}), '.toString();
    
  }


    return aux;
}

int calcularPrecioTotalPedido(HashSet<Map<String,dynamic>> hashSetDePlatillos ){
  
  int precioTotal = 0;

  for( var element in hashSetDePlatillos ){

    precioTotal = precioTotal + toInt(  element['precio_unitario'] * element['cantidad'] )!;

  }

  print("\n\n===============================El precio total de los platillos es: ${precioTotal}===============================\n\n");

  return precioTotal;

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
          'cantidad': element['cantidad']
        })
      ;
    }
  );

  
}