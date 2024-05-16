import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealimetrics/Pedidos/estados/cuantos_platillos_quiere.dart';
import 'package:mealimetrics/Pedidos/formularios/seleccionar_cantidad_platillo.dart';
import 'package:mealimetrics/Styles/color_scheme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';


class SeleccionarPlatillo extends ConsumerStatefulWidget {
  const SeleccionarPlatillo({super.key});

  @override
  _SeleccionarPlatilloState createState() => _SeleccionarPlatilloState();
}

class _SeleccionarPlatilloState extends ConsumerState<SeleccionarPlatillo> {

  //deleteMe?
    List<Map<String,dynamic>> _listaDiccionariosDePlatillos = [];
    final HashSet< Map<String,dynamic> > _platillosSeleccionados = HashSet();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    
    /// con esta funcion vamos a la base de datos y 
    /// hacemos "fetch" a la informacion sobre todos
    /// los platillos que el negocio tenga a la venta
    readPlatillosData();
  }

  
  // Para hacer read de los platillos en la bd
    Future<void> readPlatillosData() async {

      /// Primero, antes que nada, se añade una función para
      /// mostrar una barra circular de carga antes de mostrar 
      /// los pedidos en su respectiva lista de cards. Se usa
      /// "Widgets.Binding.instance.addPostFrameCallback" para
      /// asegurarse de que la función corra, inmediatamente
      /// después de que el widget sea construido/cargado
      WidgetsBinding.instance.addPostFrameCallback( (_) => showCircularProgressIndicator() );


      WidgetsFlutterBinding.ensureInitialized();

      final supabase = Supabase.instance.client;

      final dataPlatillo = await supabase
        .from('Platillo')
        .select();

      setState(() {
        _listaDiccionariosDePlatillos = dataPlatillo;

        /// Finalmente, al final de toda la función, se hace
        /// "pop" del contexto en el que nos encontrabamos...
        /// es decir, de la barra circular de carga en la que
        /// nos encontrabamos anteriormente
        Navigator.pop( context );
      });
    }


  ///Esta es para hacer la lógica de la selección de 
  ///los platillos. Si un platillo es seleccionado
  ///se añade al HashSet de platillos seleccionados
  ///pero esto, sólo, si no estaba previamente seleccionado
  void multiSeleccionarPlatillos( Map<String, dynamic> diccionarioPlatillo ){
    if( _platillosSeleccionados.contains(diccionarioPlatillo) ) {
      _platillosSeleccionados.remove(diccionarioPlatillo);
    }
    else{
      _platillosSeleccionados.add( diccionarioPlatillo );
      
    }

    setState((){
      for (var element in _platillosSeleccionados) {
          element.forEach(
            (key, value) { 
              print("El diccionario[$key] es igual a $value\n\n");
            } 
          );

        }
    });
  }


  
  Card platilloCard( Map<String, dynamic> diccionarioPlatillo ){
    
    return Card(
      
      elevation: 20,
      margin: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(13.0)
      ),
      color: EsquemaDeColores.secondary,

      child: Container(
        margin: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 12),
        height: 140.0,
        child: buildPlatilloCardInnerData( diccionarioPlatillo ),
      ),

    );

  }



  InkWell buildPlatilloCardInnerData( Map<String, dynamic> diccionarioPlatillo ){
    
    return InkWell(

      onTap: () async{

        if( !(_platillosSeleccionados.contains(diccionarioPlatillo)) ) {
          await showDialog(
            context: context, 
            builder: (BuildContext context) {
              return const SeleccionarCantidadPlatillos();
            },
          );

          diccionarioPlatillo['cantidad'] = ref.watch(riverpodCuantosPlatillosQuiere);
          
        }
        
        multiSeleccionarPlatillos( diccionarioPlatillo );

      },

      child: Stack(
        children: [
          Row(
            
            crossAxisAlignment: CrossAxisAlignment.center,
          
            children: [
          
              /// Base de datos, podrias darme la imagen del primer
              /// pedido?... Por supuesto, aqui esta el link... Bien,
              /// ahora con esto puedo construir una imagen.network
              ClipRRect(
                borderRadius: BorderRadius.circular(13.0),
                child: 
                Image.network( 
                  diccionarioPlatillo['imagen'],
                  width: 100,
                  height: 100,
                ),
          
              ),
          
              ///Ahora, ya que pusimos la imagen a la izquierda de la
              ///tarjeta, vamos a darle un pequeño espacio al elemento
              ///que irá a la derecha de la imagen
              const SizedBox(
                width: 10,
              ),
          
              /// Ahora le metemos un wdget d tipo expanded a la derecha
              /// de la image, pero, ¿Que es un expanded?, facil es un widget
              /// que sirve para ocupar todo el espacio disponible de su
              /// elemento padre. En este caso, tomará todo el espacio que hay
              /// a la derecha de la imagen (contando el sizedbox)
              Expanded(
                
                ///Dentro del expanded creamos una columna, porque la informacion
                ///se va mostrar de arriba pa abajo
                child: Column(

                  
                  crossAxisAlignment: CrossAxisAlignment.start,
          
                  ///Ahora, le decimos los textos que van a aparecer
                  ///primero los de más arriba y luego los de más abajo
                  children: <Widget>[
          
                    ///Le ponemos un poquito de "margin" improvisado arriba del todo
                    const SizedBox(
                      height: 10,
                    ),
          
                    ///El nombre del platillo
                    SizedBox(
                      width: double.maxFinite,
                      height: 20.0,
                      child: Text(
                        diccionarioPlatillo['nombre'],
                        style: const TextStyle( 
                          fontSize: 15,
                          color: EsquemaDeColores.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
          
                    ///Margin
                    const SizedBox(
                      height: 5,
                    ),
          
                    ///La descripción del platillo
                    Expanded(
                      child: SizedBox(
                        width: double.maxFinite,
                        child: Text( 
                          diccionarioPlatillo['descripcion'],
                          style: const TextStyle( 
                            fontSize: 15,
                            color: EsquemaDeColores.onPrimary, 
                          ),
                        ),
                      ),
                    ),
          
          
                    ///Margin
                    const SizedBox(
                      height: 5,
                    ),
          
                    SizedBox(
                      width: double.maxFinite,
                      height: 18.0,
                      child: Text( 
                        ///Aqui hago que el precio sea formateado con un separador de miles
                        ///de es_CO, es decir, de españo_Colombia. Así, el numero 
                        ///10x00000 se convertirá en 1.000.000
                        '\$${NumberFormat.decimalPattern("es_CO").format(diccionarioPlatillo['precio_unitario'])} COP',
                        style: const TextStyle( 
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: EsquemaDeColores.primary
                        ),
                      ),
                    ),


                  ],
          
                ),
          
              ),
          
            ],
          
          ),

          Visibility(
            
            visible: _platillosSeleccionados.contains( diccionarioPlatillo ),

            child: const Icon(
              Icons.check_circle,
              size: 30,
              color: EsquemaDeColores.primary,
            ),
          ),

        ],
      ),
    );

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


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: EsquemaDeColores.onPrimary
        ),
        centerTitle: true,
        title: const Text(
            'Seleccionar Platillo',
            style: TextStyle( color: EsquemaDeColores.onPrimary),
          ),

        backgroundColor: EsquemaDeColores.primary,
      ),

      body:ListView(

        children: _listaDiccionariosDePlatillos.map( 
          (platilloDiccionario) => platilloCard(platilloDiccionario) 
        ).toList(),

      ),

      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(10),

        child: TextButton(
          onPressed: (){
            ref.read(riverpodPlatillosHashSet.notifier).state = _platillosSeleccionados;
            
            Navigator.pop(context);
          },

          style: const ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(EsquemaDeColores.primary),
          ),

          child: const Text(
            'Listo',
            style: TextStyle(
              color: EsquemaDeColores.onPrimary,
            ),
          ),
        ),
      ),

    );
 
  }
}


