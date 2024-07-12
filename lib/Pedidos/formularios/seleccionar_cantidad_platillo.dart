// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealimetrics/Pedidos/Excepciones/cantidad_platillo.dart';
import 'package:mealimetrics/Pedidos/estados/cuantos_platillos_quiere.dart';
import 'package:mealimetrics/Styles/color_scheme.dart';
import 'package:mealimetrics/widgets/custom_alert.dart';

class SeleccionarCantidadPlatillos extends ConsumerStatefulWidget {
  const SeleccionarCantidadPlatillos({super.key});

  @override
  _SeleccionarCantidadPlatillosState createState() => _SeleccionarCantidadPlatillosState();
}

class _SeleccionarCantidadPlatillosState extends ConsumerState<SeleccionarCantidadPlatillos> {

  int _cantidadDePlatillos = 0;
  final cuantosPlatillosController = TextEditingController();
    @override
  void dispose() {
    
    super.dispose();

    // Clean up the controller when the widget is disposed.
    cuantosPlatillosController.dispose();
  }

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
          controller: cuantosPlatillosController,
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
            
            //print("La cantidad de platillos que desea es: $_cantidadDePlatillos");
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

            try{
              checkValues();
            }
            on AValueIsMissingException catch (e){

              showCustomErrorDialog(
                context, 
                'Por favor, rellene todos los campos. Campos faltantes:\n${e.mensaje}'
              );

              // FALTA IMPLEMENTAR PARA QUE EL OK SALTE UN ERROR SI HAY UN FRMATO DE NUMERO INVALIDO

              return;
            }
            catch (e){
              //print("Ha sucedido el erron ${e.toString()}");
            }
            
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


  checkValues(){

    bool aValueIsMissing = false;
    String mensaje = '';

    if( cuantosPlatillosController.text == ''){
      aValueIsMissing = true;
      mensaje = 'Cantidad de platillos\n';
    }


    if( aValueIsMissing ){
        
      mensaje = mensaje.substring(0, mensaje.length - 1);
      throw AValueIsMissingException(mensaje);

    }
  }
}