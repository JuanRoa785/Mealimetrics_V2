// ignore_for_file: use_build_context_synchronously

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:mealimetrics/styles/color_scheme.dart';
import 'package:mealimetrics/widgets/custom_alert.dart';
import 'package:mealimetrics/widgets/home_admin.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mealimetrics/widgets/home_widget.dart';
import 'dart:async';

class HomeChef extends StatefulWidget {
  const HomeChef({super.key});

  @override
  State<HomeChef> createState() => _HomeChefState();
}

class _HomeChefState extends State<HomeChef> {
  final supabase = Supabase.instance.client;
  final List<String> _listaDeEstados = ['Ordenado', 'Emplatado'];
  final List<String> _listaDeMesas = ['Todas', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];
  String? _mesaSeleccionada;
  List<Map<String, dynamic>> ordenados = [];
  List<Map<String, dynamic>> emplatados = [];
  Timer? _timer;

  @override
  void initState(){
    super.initState();

    obtenerPedidos();
 
    _startPeriodicTask();
    _mesaSeleccionada = _listaDeMesas[0];
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancelar el temporizador cuando se deshaga el widget
    super.dispose();
  }

  void _startPeriodicTask() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      obtenerPedidosPeriodicamente();
    });
  }

  void showCircularProgressIndicator() {
    showDialog(
      context: context, 
      builder: ((context) {
        return const AbsorbPointer(
          child: Center(
            child: CircularProgressIndicator(),
          )
        );
      })
    );
  }

  Future<void> obtenerPedidos() async {
    WidgetsBinding.instance.addPostFrameCallback( (_) => showCircularProgressIndicator() );
    final supabase = Supabase.instance.client;

    final pedidosOrdenados = await supabase
      .from('Pedido')
      .select()
      .eq('estado', 'Ordenado')
      .order('created_at', ascending: true);

    final pedidosEmplatados = await supabase
      .from('Pedido')
      .select()
      .eq('estado', 'Emplatado')
      .order('created_at', ascending: true);

    setState(() {
      ordenados = pedidosOrdenados;
      emplatados = pedidosEmplatados;
    });
  
    //print(pedidosNoEmplatados.length);
    //print(pedidosEmplatados.length);
    Navigator.pop( context );
  }

  void obtenerPedidosPeriodicamente() async {
    final supabase = Supabase.instance.client;
    
    final pedidosOrdenados = await supabase
      .from('Pedido')
      .select()
      .eq('estado', 'Ordenado')
      .order('created_at', ascending: true);

    final pedidosEmplatados = await supabase
      .from('Pedido')
      .select()
      .eq('estado', 'Emplatado')
      .order('created_at', ascending: true);

    if(pedidosEmplatados.length != emplatados.length || pedidosOrdenados.length != ordenados.length){
      setState(() {
        ordenados = pedidosOrdenados;
        emplatados = pedidosEmplatados;
      });
    }
  }

  List<Widget> _cargarPedidos(String tipo) {
    List<Map<String, dynamic>> pedidos;
    if(tipo == 'emplatado'){
      pedidos = emplatados;
    }
    else{
      pedidos = ordenados;
    }

    if (_mesaSeleccionada == 'Todas') {
      return pedidos.map((pedido) => pedidoCard(pedido)).toList();
    } else {
      List<Map<String, dynamic>> pedidosFiltrados = pedidos.where((pedido) => '${pedido['id_mesa']}' == _mesaSeleccionada.toString()).toList();
      //print('${pedidos[0]['id_mesa']} $_mesaSeleccionada');
      return pedidosFiltrados.map((pedido) => pedidoCard(pedido)).toList();
    }
  }

  Widget pedidoCard( Map<String, dynamic> pedido ){
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
            const SizedBox(
              height: 7.0,
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
                    items: _listaDeEstados.map((estado) => DropdownMenuItem<String>(
                                value: estado,
                                child: Text(estado),
                              ))
                          .toList(),
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

                      setState(() {
                        obtenerPedidos();
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
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: EsquemaDeColores.backgroundSecondary,
        title: const Text(
          'Home Chef',
          style: TextStyle(fontSize: 25,
          fontWeight: FontWeight.bold
            )
        ),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left:15),
          child: IconButton( // Aquí se crea el botón de flecha <- 
            icon: const Icon(Icons.logout_sharp,size: 28), // Icono de flecha hacia atrás
            onPressed: () {
              signOut(); //Cierra la sesion
            },
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0), 
            child: IconButton(
              icon: const Icon(Icons.account_circle_sharp, size: 35), 
              onPressed: () {
                Navigator.pushNamed(context, '/actualizarDatos');
              },
            ),
          ),
        ],
      ),
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
            ..._cargarPedidos('ordenado'),
            ..._cargarPedidos('emplatado'),
        ],        
      ),
    );
  }



  Future<void> signOut() async {
    final User? user = supabase.auth.currentUser;
    if (user?.id == "8554245a-6ee6-448c-89ee-742bd3bbf431") {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeAdmin()));
      return;
    }
    await supabase.auth.signOut();
    if(!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const Home()));
  }

}