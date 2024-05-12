import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealimetrics/Pedidos/estados/cuantos_platillos_quiere.dart';
import 'package:mealimetrics/Styles/color_scheme.dart';

class SeleccionarCantidadPlatillos extends ConsumerStatefulWidget {
  const SeleccionarCantidadPlatillos({super.key});

  @override
  _SeleccionarCantidadPlatillosState createState() => _SeleccionarCantidadPlatillosState();
}

class _SeleccionarCantidadPlatillosState extends ConsumerState<SeleccionarCantidadPlatillos> {

  int _cantidadDePlatillos = 0;

  @override
  Widget build(BuildContext context) {
    return  SimpleDialog(
      backgroundColor: EsquemaDeColores.background,
      contentPadding: const EdgeInsets.all(10),
      title: const Text(
        '¿Cuantos platillos desea?',
        style: TextStyle(
          color: EsquemaDeColores.primary,
          fontWeight: FontWeight.bold,
          ),
      ),
      children: <Widget>[

        const SizedBox(
          height: 5,
        ),


        TextField(
          enableInteractiveSelection: false,
          keyboardType: TextInputType.number,
          autofocus: true,
          inputFormatters: <TextInputFormatter>[
             FilteringTextInputFormatter.digitsOnly
          ],
                          
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius:  BorderRadius.circular(13.0),
            ),
          ),

          onChanged: (numeroDePlatillos){
            _cantidadDePlatillos = int.parse( numeroDePlatillos );
            print("La cantidad de platillos que desea es: $_cantidadDePlatillos");
          },
        ),

        const SizedBox(
          height: 15,
        ),

        TextButton(
          
          style: const ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(EsquemaDeColores.primary),
          ),


          onPressed: (){
            
            ref.read(riverpodCuantosPlatillosQuiere.notifier).state = _cantidadDePlatillos;
            
            Navigator.pop(context);
          }, 
          child: const Text(
            'Ok',
            style: TextStyle(
              color: EsquemaDeColores.onPrimary
            ),
          ),
        ),

      ],
    );
  }
}