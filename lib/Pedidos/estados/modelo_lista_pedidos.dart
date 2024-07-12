import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


//Primero, creo el modelo que guardará los datos
class RiverpodModel extends ChangeNotifier{

  List<Map<String, dynamic>> listaPedidos = [];

  RiverpodModel({
    required this.listaPedidos,
  });

  void addDictionary( Map<String, dynamic> diccionarioPedido ){
    listaPedidos.add( diccionarioPedido );
    notifyListeners();
  }

  void set( List<Map<String, dynamic>> lista ){
    listaPedidos = lista;
  }

  void cambiarEstadoPorId( int id, String estado ){

    final foundDictionary = listaPedidos.firstWhere(
      (element) {
        return element['id'] == id;
      }
    );

    foundDictionary['estado'] = estado;
  }

  void elimiarPedidoPorId( int id ){
    
    final foundDictionary = listaPedidos.firstWhere(
      (element) {
        return element['id'] == id;
      }
    );

    listaPedidos.remove( foundDictionary );
  }

}

//Luego creo el notifierprovider para manejar esos cambios
final riverpodListaPedidos = ChangeNotifierProvider<RiverpodModel>(
  (ref){
    return RiverpodModel( listaPedidos: [] );
  }
);