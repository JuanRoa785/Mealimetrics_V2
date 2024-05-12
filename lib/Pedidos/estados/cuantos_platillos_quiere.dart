import 'dart:collection';
import 'package:flutter_riverpod/flutter_riverpod.dart';


int cuantosPlatillosQuiere = 0;
HashSet<Map<String, dynamic>> listaPlatillos = HashSet();

final riverpodCuantosPlatillosQuiere = StateProvider<int>(
  (ref){
    return cuantosPlatillosQuiere;
  }
);

final riverpodPlatillosHashSet = StateProvider< HashSet<Map<String, dynamic>> >(
  (ref){
    return listaPlatillos;
  }
);