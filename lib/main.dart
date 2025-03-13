import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mealimetrics/widgets/home_widget.dart';
import 'package:mealimetrics/widgets/actualizar_datos.dart';
import 'package:mealimetrics/styles/color_scheme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealimetrics/Pedidos/seleccionar_pedido.dart';
import 'package:mealimetrics/Pedidos/pedidos_main.dart';
import 'package:flutter/services.dart';

const supabaseUrl = 'https://fqsdytkispydwsmcbikh.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZxc2R5dGtpc3B5ZHdzbWNiaWtoIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0MTUzNzA4MywiZXhwIjoyMDU3MTEzMDgzfQ.HG8nwPE4ev9pDbSo_rX519Skd3jT-q2tDcWCtIYICVY';

Future<void> main() async {
//Inicializar Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
    realtimeClientOptions: const RealtimeClientOptions(
      logLevel: RealtimeLogLevel.info,
    ),
    storageOptions: const StorageClientOptions(
      retryAttempts: 10,
    ),
  );

  // Configurar las orientaciones preferidas - Solo vertical
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    const ProviderScope (
      child: MyApp()
    )
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});
  final ColorScheme myColorScheme = const MyColorScheme();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mealimetrics',
      debugShowCheckedModeBanner:false,
      theme: ThemeData(
        colorScheme: myColorScheme,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (_) => const Home(),
        '/actualizarDatos': (_) => const ActualizarDatos(),
        '/PedidosMain': (context) => const PedidosMain(),
        '/SeleccionarPedido': (context) => const SeleccionarPedido(),
        //'/SeleccionarPlatillo': (context) => const SeleccionarPlatillo(),
      },
    );
  }
}
