import 'dart:collection';
import 'package:flutter_riverpod/flutter_riverpod.dart';


int cuantosPlatillosQuiere = 0;
HashSet<Map<String, dynamic>> hashSetPlatillos = HashSet();

final riverpodCuantosPlatillosQuiere = StateProvider<int>(
  (ref){
    return cuantosPlatillosQuiere;
  }
);

final riverpodPlatillosHashSet = StateProvider< HashSet<Map<String, dynamic>> >(
  (ref){
    return hashSetPlatillos;
  }
);

final almuerzosStringProvider = StateProvider<String>(
  (ref) {
    return '';
  }
);